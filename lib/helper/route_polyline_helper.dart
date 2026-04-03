import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:sixam_mart/api/api_client.dart';
import 'package:sixam_mart/util/app_constants.dart';

class RoutePolylineHelper {
  static Future<List<LatLng>> getRoutePoints({
    required LatLng origin,
    required LatLng destination,
  }) async {
    if (!_isValid(origin) || !_isValid(destination)) {
      return [];
    }

    final response = await Get.find<ApiClient>().getData(
      '${AppConstants.directionUri}?origin_lat=${origin.latitude}&origin_lng=${origin.longitude}'
      '&destination_lat=${destination.latitude}&destination_lng=${destination.longitude}&mode=DRIVE',
      handleError: false,
    );

    if (response.statusCode == 200 && response.body is Map) {
      final routes = response.body['routes'];
      if (routes is List && routes.isNotEmpty) {
        final polyline = routes.first['polyline'];
        final encoded = polyline is Map ? polyline['encodedPolyline'] : null;
        if (encoded is String && encoded.isNotEmpty) {
          return _decodePolyline(encoded);
        }
      }
    }

    return [];
  }

  static bool _isValid(LatLng point) {
    return point.latitude != 0 && point.longitude != 0;
  }

  static List<LatLng> _decodePolyline(String encoded) {
    final List<LatLng> polylineCoordinates = <LatLng>[];
    int index = 0;
    int lat = 0;
    int lng = 0;

    while (index < encoded.length) {
      int b;
      int shift = 0;
      int result = 0;
      do {
        b = encoded.codeUnitAt(index++) - 63;
        result |= (b & 0x1f) << shift;
        shift += 5;
      } while (b >= 0x20);
      final int deltaLat = (result & 1) != 0 ? ~(result >> 1) : (result >> 1);
      lat += deltaLat;

      shift = 0;
      result = 0;
      do {
        b = encoded.codeUnitAt(index++) - 63;
        result |= (b & 0x1f) << shift;
        shift += 5;
      } while (b >= 0x20);
      final int deltaLng = (result & 1) != 0 ? ~(result >> 1) : (result >> 1);
      lng += deltaLng;

      polylineCoordinates.add(LatLng(lat / 1E5, lng / 1E5));
    }

    return polylineCoordinates;
  }
}
