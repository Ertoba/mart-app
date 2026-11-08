import 'dart:async';
import 'dart:collection';

import 'package:geolocator/geolocator.dart';
import 'package:sixam_mart/common/controllers/theme_controller.dart';
import 'package:sixam_mart/common/widgets/custom_snackbar.dart';
import 'package:sixam_mart/common/widgets/footer_view.dart';
import 'package:sixam_mart/features/location/controllers/location_controller.dart';
import 'package:sixam_mart/features/location/widgets/permission_dialog_widget.dart';
import 'package:sixam_mart/features/splash/controllers/splash_controller.dart';
import 'package:sixam_mart/features/notification/domain/models/notification_body_model.dart';
import 'package:sixam_mart/features/address/domain/models/address_model.dart';
import 'package:sixam_mart/features/chat/domain/models/conversation_model.dart';
import 'package:sixam_mart/features/order/controllers/order_controller.dart';
import 'package:sixam_mart/features/order/domain/models/order_model.dart';
import 'package:sixam_mart/features/order/helper/route_polyline.dart';
import 'package:sixam_mart/features/order/widgets/route_status_indicator.dart';
import 'package:sixam_mart/helper/auth_helper.dart';
import 'package:sixam_mart/helper/marker_helper.dart';
import 'package:sixam_mart/helper/pusher_helper.dart';
import 'package:sixam_mart/helper/responsive_helper.dart';
import 'package:sixam_mart/helper/route_helper.dart';
import 'package:sixam_mart/util/dimensions.dart';
import 'package:sixam_mart/util/images.dart';
import 'package:sixam_mart/common/widgets/custom_app_bar.dart';
import 'package:sixam_mart/common/widgets/menu_drawer.dart';
import 'package:sixam_mart/features/order/widgets/track_details_view_widget.dart';
import 'package:sixam_mart/features/order/widgets/tracking_stepper_widget.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class OrderTrackingScreen extends StatefulWidget {
  final String? orderID;
  final String? contactNumber;
  const OrderTrackingScreen({
    super.key,
    required this.orderID,
    this.contactNumber,
  });

  @override
  OrderTrackingScreenState createState() => OrderTrackingScreenState();
}

class OrderTrackingScreenState extends State<OrderTrackingScreen>
    with WidgetsBindingObserver {
  GoogleMapController? _controller;
  bool _isLoading = true;
  Set<Marker> _markers = HashSet<Marker>();
  Timer? _timer;
  bool showChatPermission = true;
  bool isHovered = false;
  late final RoutePolylineController _route;
  Future<List<BitmapDescriptor>>? _markerIcons;
  int _markerGeneration = 0;
  int _riderGeneration = 0;
  String? _markerKey;
  bool _polling = false;

  void _loadData() async {
    // An existing order route must not wait for GPS permission or a GPS fix.
    await Get.find<OrderController>().trackOrder(
      widget.orderID,
      null,
      true,
      contactNumber: widget.contactNumber,
    );

    if (!mounted) return;
    _loadRoute();
    if (Get.find<SplashController>().configModel?.websocketEnabled == true) {
      _trackWithPusher();
    }
    // Status/assignment changes still need polling when websocket GPS is enabled.
    _timerTrackOrder();
  }

  void _trackWithPusher() {
    bool canTrackDeliveryman =
        Get.find<OrderController>().trackModel?.orderStatus != 'delivered' &&
        Get.find<OrderController>().trackModel?.orderStatus != 'failed' &&
        Get.find<OrderController>().trackModel?.orderStatus != 'canceled';
    if (Get.find<OrderController>().trackModel != null &&
        Get.find<OrderController>().trackModel!.deliveryMan != null &&
        canTrackDeliveryman) {
      Get.find<OrderController>().timerTrackOrder(
        widget.orderID.toString(),
        contactNumber: widget.contactNumber,
      );

      PusherHelper().pusherDriverStatus(
        deliverymanId: Get.find<OrderController>().trackModel!.deliveryMan!.id
            .toString(),
        onLocationReceived: (RecordLocationBodyModel dmLocation) {
          updateDeliverymanMarker(dmLocation);
        },
      );
    }
  }

  void _timerTrackOrder() {
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 10), (timer) async {
      if (!mounted || !Get.currentRoute.contains(RouteHelper.orderTracking)) {
        timer.cancel();
        return;
      }
      if (_polling) return;
      _polling = true;
      try {
        await Get.find<OrderController>().timerTrackOrder(
          widget.orderID.toString(),
          contactNumber: widget.contactNumber,
        );
        if (!mounted) return;
        await _refreshMap();
        final status = Get.find<OrderController>().trackModel?.orderStatus;
        if (status == 'delivered' ||
            status == 'failed' ||
            status == 'canceled') {
          timer.cancel();
        }
      } finally {
        _polling = false;
      }
    });
  }

  @override
  void initState() {
    super.initState();
    _route = RoutePolylineController(
      fetch: Get.find<OrderController>()
          .orderServiceInterface
          .getDirectionPolyline,
    )..addListener(_routeChanged);
    WidgetsBinding.instance.addObserver(this);

    PusherHelper.initializePusher();
    _loadData();
  }

  @override
  void didChangeAppLifecycleState(final AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _timerTrackOrder();
    } else if (state == AppLifecycleState.paused) {
      _timer?.cancel();
    }
  }

  @override
  void dispose() {
    _route.dispose();
    _controller?.dispose();
    _timer?.cancel();
    PusherHelper().pusherDisconnectPusher();
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  void onEntered(bool isHovered) {
    setState(() {
      this.isHovered = isHovered;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(title: 'order_tracking'.tr),
      endDrawer: const MenuDrawer(),endDrawerEnableOpenDragGesture: false,
      body: GetBuilder<OrderController>(builder: (orderController) {
        OrderModel? track;
        if(orderController.trackModel != null) {
          track = orderController.trackModel;
          _scheduleMapRefresh(track!);

          if(track.orderType != 'parcel') {
            if (track.store?.storeBusinessModel == 'commission') {
              showChatPermission = true;
            } else if (track.store?.storeSubscription != null && track.store?.storeBusinessModel == 'subscription') {
              showChatPermission = track.store!.storeSubscription!.chat == 1;
            } else {
              showChatPermission = false;
            }
          } else {
            showChatPermission = AuthHelper.isLoggedIn();
          }
        }

        return track != null ? SingleChildScrollView(
          physics: isHovered || !ResponsiveHelper.isDesktop(context) ? const NeverScrollableScrollPhysics() : const AlwaysScrollableScrollPhysics(),
          child: FooterView(
            child: Center(child: SizedBox(width: Dimensions.webMaxWidth, height: ResponsiveHelper.isDesktop(context) ? 700 : MediaQuery.of(context).size.height * 0.85, child: Stack(children: [

              MouseRegion(
                onEnter: (event) => onEntered(true),
                onExit: (event) => onEntered(false),
                child: GoogleMap(
                  initialCameraPosition: CameraPosition(target:
                    routeCoordinate(track.deliveryAddress?.latitude, track.deliveryAddress?.longitude) ?? const LatLng(0, 0), zoom: 16),
                  minMaxZoomPreference: const MinMaxZoomPreference(0, 16),
                  zoomControlsEnabled: false,
                  markers: _markers,
                  polylines: _route.points.length > 1 ? {
                    Polyline(polylineId: const PolylineId('tracking_route'), points: _route.points,
                      width: 5, color: Theme.of(context).primaryColor),
                  } : <Polyline>{},
                  onMapCreated: (GoogleMapController controller) {
                    _controller = controller;
                    _isLoading = false;
                    _refreshMap(fit: true);
                  },
                  style: Get.isDarkMode ? Get.find<ThemeController>().darkMap : Get.find<ThemeController>().lightMap,
                ),
              ),

              _isLoading ? const Center(child: CircularProgressIndicator()) : const SizedBox(),

              Positioned(top: 74, left: 12, right: 12,
                child: Align(alignment: Alignment.topCenter, child: RouteStatusIndicator(
                  status: _route.status, onRetry: () => _loadRoute(force: true)))),

              Positioned(
                top: Dimensions.paddingSizeSmall, left: Dimensions.paddingSizeSmall, right: Dimensions.paddingSizeSmall,
                child: TrackingStepperWidget(status: track.orderStatus, takeAway: track.orderType == 'take_away'),
              ),

              Positioned(
                right: 15, bottom: track.orderType != 'take_away' && track.deliveryMan == null ? 150 : 220,
                child: InkWell(
                  onTap: () => _checkPermission(() async {
                    AddressModel address = await Get.find<LocationController>().getCurrentLocation(false, mapController: _controller);
                    if (mounted) await _refreshMap(currentAddress: address);
                  }),
                  child: Container(
                    padding: const EdgeInsets.all( Dimensions.paddingSizeSmall),
                    decoration: BoxDecoration(borderRadius: BorderRadius.circular(50), color: Colors.white),
                    child: Icon(Icons.my_location_outlined, color: Theme.of(context).primaryColor, size: 25),
                  ),
                ),
              ),

              Positioned(
                bottom: Dimensions.paddingSizeSmall, left: Dimensions.paddingSizeSmall, right: Dimensions.paddingSizeSmall,
                child: TrackDetailsViewWidget(status: track.orderStatus, track: track, showChatPermission: showChatPermission, callback: () async{
                  bool takeAway = track?.orderType == 'take_away';
                  _timer?.cancel();
                  await Get.toNamed(RouteHelper.getChatRoute(
                    notificationBody: takeAway ? NotificationBodyModel(restaurantId: track!.store!.id, orderId: int.parse(widget.orderID!))
                        : NotificationBodyModel(deliverymanId: track!.deliveryMan!.id, orderId: int.parse(widget.orderID!)),
                    user: User(
                      id: takeAway ? track.store!.id : track.deliveryMan!.id,
                      fName: takeAway ? track.store!.name : track.deliveryMan!.fName,
                      lName: takeAway ? '' : track.deliveryMan!.lName,
                      imageFullUrl: takeAway ? track.store!.logoFullUrl : track.deliveryMan!.imageFullUrl,
                    ),
                  ));
                  _timerTrackOrder();
                }),
              ),

            ]))),
          ),
        ) : const Center(child: CircularProgressIndicator());
      }),
    );
  }

  Future<List<BitmapDescriptor>> _icons() => _markerIcons ??= Future.wait([
    MarkerHelper.convertAssetToBitmapDescriptor(
      width: 30,
      imagePath: Images.markerStore,
    ),
    MarkerHelper.convertAssetToBitmapDescriptor(
      width: 30,
      imagePath: Images.deliveryManMarker,
    ),
    MarkerHelper.convertAssetToBitmapDescriptor(
      width: 30,
      imagePath: Images.userMarker,
    ),
  ]);

  void _loadRoute({bool force = false}) {
    final order = Get.find<OrderController>().trackModel;
    final endpoints = order == null
        ? null
        : OrderRouteEndpoints.fromOrder(order);
    _route.load(
      endpoints?.origin,
      endpoints?.destination,
      scope: widget.orderID ?? '',
      force: force,
    );
  }

  void _routeChanged() {
    if (!mounted) return;
    setState(() {});
    if (_route.status == RouteLoadStatus.ready) _fitMap();
  }

  Future<void> _fitMap() async {
    final points = [
      ..._markers.map((marker) => marker.position),
      ..._route.points,
    ];

    if (!mounted || _controller == null || points.isEmpty) return;
    try {
      if (points.every((point) => point == points.first)) {
        await _controller!.moveCamera(
          CameraUpdate.newLatLngZoom(points.first, 15),
        );
      } else {
        await _controller!.moveCamera(
          CameraUpdate.newLatLngBounds(routeBounds(points), 80),
        );
      }
    } catch (_) {
      // Map lifecycle errors do not invalidate an otherwise valid route.
    }
  }

  void _scheduleMapRefresh(OrderModel order) {
    final endpoints = OrderRouteEndpoints.fromOrder(order);
    final key =
        '${order.id}:${endpoints?.origin}:${endpoints?.destination}:'
        '${order.deliveryMan?.lat}:${order.deliveryMan?.lng}';
    if (_markerKey == key) return;
    _markerKey = key;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) _refreshMap();
    });
  }

  Future<void> _refreshMap({
    bool fit = false,
    AddressModel? currentAddress,
  }) async {
    final int generation = ++_markerGeneration;
    final order = Get.find<OrderController>().trackModel;
    if (order == null || order.id.toString() != widget.orderID) return;
    final endpoints = OrderRouteEndpoints.fromOrder(order);
    _loadRoute();
    var storeIcon = BitmapDescriptor.defaultMarkerWithHue(
      BitmapDescriptor.hueAzure,
    );
    var riderIcon = BitmapDescriptor.defaultMarkerWithHue(
      BitmapDescriptor.hueOrange,
    );
    var destinationIcon = BitmapDescriptor.defaultMarkerWithHue(
      BitmapDescriptor.hueGreen,
    );
    try {
      final icons = await _icons();
      storeIcon = icons[0];
      riderIcon = icons[1];
      destinationIcon = icons[2];
    } catch (_) {
      // Default markers remain usable when asset decoding fails.
    }
    if (!mounted || generation != _markerGeneration) return;
    final Set<Marker> markers = {};
    if (endpoints != null) {
      markers.add(
        Marker(
          markerId: const MarkerId('origin'),
          position: endpoints.origin,
          icon: storeIcon,
          infoWindow: InfoWindow(
            title: order.orderType == 'parcel' ? 'sender'.tr : 'store'.tr,
          ),
        ),
      );
      markers.add(
        Marker(
          markerId: const MarkerId('destination'),
          position: endpoints.destination,
          icon: destinationIcon,
          infoWindow: InfoWindow(
            title: order.orderType == 'parcel'
                ? 'receiver'.tr
                : 'destination'.tr,
          ),
        ),
      );
    }
    final rider = routeCoordinate(
      order.deliveryMan?.lat,
      order.deliveryMan?.lng,
    );
    if (rider != null) {
      markers.add(
        Marker(
          markerId: const MarkerId('delivery_boy'),
          position: rider,
          icon: riderIcon,
          infoWindow: InfoWindow(title: 'delivery_man'.tr),
        ),
      );
    }
    final current = routeCoordinate(
      currentAddress?.latitude,
      currentAddress?.longitude,
    );

    if (current != null) {
      markers.add(
        Marker(
          markerId: const MarkerId('current_location'),
          position: current,
          icon: destinationIcon,
        ),
      );
    }
    final firstMarkers = _markers.isEmpty;
    setState(() {
      _markers = markers;
      _isLoading = false;
    });
    if (current != null && _controller != null) {
      try {
        await _controller!.moveCamera(CameraUpdate.newLatLngZoom(current, 15));
      } catch (_) {}
    } else if (fit || firstMarkers) {
      await _fitMap();
    }
  }

  Future<void> updateDeliverymanMarker(
    RecordLocationBodyModel dmLocation,
  ) async {
    final position = routeCoordinate(dmLocation.latitude, dmLocation.longitude);
    if (position == null) return;
    final generation = ++_riderGeneration;
    var icon = BitmapDescriptor.defaultMarkerWithHue(
      BitmapDescriptor.hueOrange,
    );
    try {
      icon = (await _icons())[1];
    } catch (_) {}
    if (!mounted || generation != _riderGeneration) return;
    setState(() {
      _markers.removeWhere((marker) => marker.markerId.value == 'delivery_boy');
      _markers.add(
        Marker(
          markerId: const MarkerId('delivery_boy'),
          position: position,
          icon: icon,
          infoWindow: InfoWindow(title: 'delivery_man'.tr),
        ),
      );
    });
    // Deliberately no provider request or camera refit for a GPS-only update.
  }

  void _checkPermission(Function onTap) async {
    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }
    if (permission == LocationPermission.denied) {
      showCustomSnackBar('you_have_to_allow'.tr);
    } else if (permission == LocationPermission.deniedForever) {
      Get.dialog(const PermissionDialogWidget());
    } else {
      onTap();
    }
  }
}
