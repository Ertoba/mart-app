import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:sixam_mart/features/order/domain/models/order_model.dart';

enum RouteLoadStatus { idle, loading, ready, noRoute, error }

enum RouteFailure {
  invalidCoordinates,
  transport,
  timeout,
  response,
  malformed,
}

class RoutePolylineException implements Exception {
  final RouteFailure failure;
  const RoutePolylineException(this.failure);
  @override
  String toString() => 'RoutePolylineException(${failure.name})';
}

/// Validate before constructing LatLng: its constructor clamps/wraps bad input.
LatLng? routeCoordinate(Object? latitude, Object? longitude) {
  final double? lat = double.tryParse(latitude?.toString() ?? '');
  final double? lng = double.tryParse(longitude?.toString() ?? '');
  if (lat == null ||
      lng == null ||
      !lat.isFinite ||
      !lng.isFinite ||
      lat < -90 ||
      lat > 90 ||
      lng < -180 ||
      lng > 180) {
    return null;
  }
  return LatLng(lat, lng);
}

class OrderRouteEndpoints {
  final LatLng origin;
  final LatLng destination;
  const OrderRouteEndpoints(this.origin, this.destination);

  /// Parcel delivery_address is the sender; receiver_details is the destination.
  /// A courier's changing position is a marker, not the order's route origin.
  static OrderRouteEndpoints? fromOrder(OrderModel order) {
    final bool parcel = order.orderType == 'parcel';
    final LatLng? origin = parcel
        ? routeCoordinate(
            order.deliveryAddress?.latitude,
            order.deliveryAddress?.longitude,
          )
        : routeCoordinate(order.store?.latitude, order.store?.longitude);
    final LatLng? destination = parcel
        ? routeCoordinate(
            order.receiverDetails?.latitude,
            order.receiverDetails?.longitude,
          )
        : routeCoordinate(
            order.deliveryAddress?.latitude,
            order.deliveryAddress?.longitude,
          );
    return origin == null || destination == null
        ? null
        : OrderRouteEndpoints(origin, destination);
  }
}

/// Only provider road geometry is accepted. Never invent a straight-line route.
List<LatLng> decodeRouteResponse(dynamic body) {
  if (body is! Map) throw const RoutePolylineException(RouteFailure.malformed);
  final dynamic status = body['status'];
  if (status == 'ZERO_RESULTS' || status == 'NOT_FOUND') return const [];
  if (status != null && status != 'OK') {
    throw const RoutePolylineException(RouteFailure.response);
  }
  String? encoded;
  if (body['routes'] is List) {
    final List routes = body['routes'];
    if (routes.isEmpty) return const [];
    final dynamic route = routes.first;
    if (route is! Map) {
      throw const RoutePolylineException(RouteFailure.malformed);
    }
    final dynamic v2 = route['polyline'];
    final dynamic legacy = route['overview_polyline'];
    final dynamic value = v2 is Map ? v2['encodedPolyline'] : null;
    final dynamic fallback = legacy is Map ? legacy['points'] : null;
    if ((value != null && value is! String) ||
        (fallback != null && fallback is! String)) {
      throw const RoutePolylineException(RouteFailure.malformed);
    }
    encoded = value as String? ?? fallback as String?;
  }
  final dynamic flat = body['encoded_polyline'];
  if (encoded == null && flat is String) encoded = flat;
  if (encoded == null || encoded.isEmpty || encoded.length > 200000) {
    throw const RoutePolylineException(RouteFailure.malformed);
  }
  return decodeRoutePolyline(encoded);
}

List<LatLng> decodeRoutePolyline(String encoded) {
  final List<LatLng> points = [];
  int index = 0, latitude = 0, longitude = 0;
  int readDelta() {
    int value = 0, shift = 0;
    while (true) {
      if (index >= encoded.length || shift > 30) {
        throw const RoutePolylineException(RouteFailure.malformed);
      }
      final int code = encoded.codeUnitAt(index++);
      if (code < 63 || code > 126) {
        throw const RoutePolylineException(RouteFailure.malformed);
      }
      final int part = code - 63;
      value |= (part & 0x1f) << shift;
      if (part < 0x20) return (value & 1) != 0 ? ~(value >> 1) : value >> 1;
      shift += 5;
    }
  }

  while (index < encoded.length) {
    latitude += readDelta();
    longitude += readDelta();
    final LatLng? point = routeCoordinate(latitude / 1e5, longitude / 1e5);
    if (point == null || points.length >= 20000) {
      throw const RoutePolylineException(RouteFailure.malformed);
    }
    points.add(point);
  }
  if (points.length < 2) {
    throw const RoutePolylineException(RouteFailure.malformed);
  }
  return List.unmodifiable(points);
}

typedef RouteFetcher =
    Future<List<LatLng>> Function({
      required LatLng origin,
      required LatLng destination,
    });

/// Screen-local state prevents one map/order from replacing another's geometry.
/// Identical endpoints (including frequent courier-marker updates) fetch once.
class RoutePolylineController extends ChangeNotifier {
  final RouteFetcher fetch;
  final Duration timeout;
  RoutePolylineController({
    required this.fetch,
    this.timeout = const Duration(seconds: 12),
  });
  RouteLoadStatus status = RouteLoadStatus.idle;
  RouteFailure? failure;
  List<LatLng> points = const [];
  String? _requestKey;
  int _generation = 0;
  bool _disposed = false;

  Future<void> load(
    LatLng? origin,
    LatLng? destination, {
    String scope = '',
    bool force = false,
  }) async {
    if (_disposed) return;
    final String key = '$scope:$origin:$destination';
    if (!force && key == _requestKey) return;
    _requestKey = key;
    final int generation = ++_generation;
    points = const [];
    failure = null;
    if (origin == null ||
        destination == null ||
        routeCoordinate(origin.latitude, origin.longitude) == null ||
        routeCoordinate(destination.latitude, destination.longitude) == null) {
      status = RouteLoadStatus.error;
      failure = RouteFailure.invalidCoordinates;
      notifyListeners();
      return;
    }
    status = RouteLoadStatus.loading;
    notifyListeners();
    try {
      final List<LatLng> result = await fetch(
        origin: origin,
        destination: destination,
      ).timeout(timeout);
      if (_disposed || generation != _generation) return;
      points = List.unmodifiable(result);
      status = points.length >= 2
          ? RouteLoadStatus.ready
          : RouteLoadStatus.noRoute;
    } on TimeoutException {
      if (_disposed || generation != _generation) return;
      status = RouteLoadStatus.error;
      failure = RouteFailure.timeout;
    } catch (error) {
      if (_disposed || generation != _generation) return;
      status = RouteLoadStatus.error;
      failure = error is RoutePolylineException
          ? error.failure
          : RouteFailure.transport;
    }
    // Fixed vocabulary only: no URLs, provider bodies, coordinates, keys or IDs.
    if (kDebugMode) {
      debugPrint(
        'route_polyline status=${status.name} reason=${failure?.name ?? 'none'}',
      );
    }
    notifyListeners();
  }

  @override
  void dispose() {
    _disposed = true;
    _generation++;
    super.dispose();
  }
}

LatLngBounds routeBounds(Iterable<LatLng> points) {
  final List<LatLng> values = points.toList();
  double south = values.first.latitude, north = south;
  double west = values.first.longitude, east = west;
  for (final LatLng point in values.skip(1)) {
    if (point.latitude < south) south = point.latitude;
    if (point.latitude > north) north = point.latitude;
    if (point.longitude < west) west = point.longitude;
    if (point.longitude > east) east = point.longitude;
  }
  return LatLngBounds(
    southwest: LatLng(south, west),
    northeast: LatLng(north, east),
  );
}
