import 'dart:async';
import 'dart:collection';
import 'dart:math' as math;

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
import 'package:sixam_mart/features/store/domain/models/store_model.dart';
import 'package:sixam_mart/helper/address_helper.dart';
import 'package:sixam_mart/helper/auth_helper.dart';
import 'package:sixam_mart/helper/marker_helper.dart';
import 'package:sixam_mart/helper/pusher_helper.dart';
import 'package:sixam_mart/helper/responsive_helper.dart';
import 'package:sixam_mart/helper/route_polyline_helper.dart';
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
  Set<Polyline> _polylines = HashSet<Polyline>();
  Timer? _timer;
  final PusherHelper _pusherHelper = PusherHelper();
  bool _isDisposed = false;
  bool showChatPermission = true;
  bool isHovered = false;
  String? _routeKey;
  OrderModel? _localTrackModel;
  Timer? _deliveryMarkerAnimationTimer;
  LatLng? _deliveryMarkerPosition;
  BitmapDescriptor? _deliveryMarkerIcon;
  String? _deliveryMarkerSnippet;
  double _deliveryMarkerRotation = 0;
  List<LatLng> _routePolylinePoints = const <LatLng>[];
  double? _deliveryMarkerRouteDistance;
  LatLng? _lastDeliveryLocationTarget;
  DateTime? _lastDeliveryLocationReceivedAt;
  int _offRouteLocationCount = 0;

  static const Duration _deliveryMarkerMinAnimationDuration = Duration(
    milliseconds: 1200,
  );
  static const Duration _deliveryMarkerMaxAnimationDuration = Duration(
    seconds: 8,
  );
  static const Duration _deliveryMarkerFrameDuration = Duration(
    milliseconds: 50,
  );
  static const double _deliveryMarkerJitterDistance = 3;
  static const double _deliveryMarkerDefaultMetersPerSecond = 8;
  static const double _deliveryMarkerWalkingSpeedThreshold = 3;
  static const double _deliveryMarkerWalkingMetersPerSecond = 2.2;
  static const double _deliveryMarkerMaxMetersPerSecond = 12;
  static const double _deliveryMarkerTeleportDistance = 5000;
  static const double _routeSnapCorridorDistance = 45;
  static const double _routeHardOffRouteDistance = 90;
  static const double _routeBacktrackAllowance = 25;
  static const double _routeForwardWindowMin = 120;
  static const double _routeForwardWindowMax = 1000;
  static const double _routeForwardWindowMultiplier = 4;
  static const double _routeDensifySegmentLength = 8;
  static const int _offRouteFallbackThreshold = 3;

  void _loadData() async {
    await Get.find<LocationController>().getCurrentLocation(
      true,
      notify: false,
      defaultLatLng: LatLng(
        double.parse(AddressHelper.getUserAddressFromSharedPref()!.latitude!),
        double.parse(AddressHelper.getUserAddressFromSharedPref()!.longitude!),
      ),
    );
    await Get.find<OrderController>().trackOrder(
      widget.orderID,
      null,
      true,
      contactNumber: widget.contactNumber,
    );

    if (Get.find<SplashController>().configModel!.websocketEnabled!) {
      await _startLiveTracking();
    } else {
      _timerTrackOrder();
    }
  }

  bool _canTrackDeliveryman(OrderModel? trackModel) {
    return trackModel?.orderStatus != 'delivered' &&
        trackModel?.orderStatus != 'failed' &&
        trackModel?.orderStatus != 'canceled';
  }

  bool get _isWebsocketTrackingEnabled =>
      Get.find<SplashController>().configModel?.websocketEnabled ?? false;

  Future<void> _startLiveTracking() async {
    _timer?.cancel();
    try {
      await PusherHelper.initializePusher();
    } catch (error) {
      debugPrint('[PUSHER] initialize failed: $error');
    }
    if (_isDisposed || !mounted) return;

    await _refreshDeliveryMarkerFromTrack();
    if (_isDisposed || !mounted) return;

    _trackWithPusher();
    _startDeliveryLocationFallbackTimer();
  }

  void _trackWithPusher() {
    final tm = Get.find<OrderController>().trackModel;
    bool canTrackDeliveryman = _canTrackDeliveryman(tm);
    debugPrint(
      '[PUSHER] _trackWithPusher: order=${tm?.id} status=${tm?.orderStatus} deliveryMan=${tm?.deliveryMan?.id} canTrack=$canTrackDeliveryman',
    );

    if (!canTrackDeliveryman) {
      _timer?.cancel();
      _pusherHelper.pusherDisconnectPusher();
      return;
    }

    if (tm != null && tm.deliveryMan != null) {
      _pusherHelper.pusherDriverStatus(
        deliverymanId: tm.deliveryMan!.id.toString(),
        onLocationReceived: (RecordLocationBodyModel dmLocation) {
          if (_isDisposed || !mounted) return;
          debugPrint(
            '[PUSHER] location received lat=${dmLocation.latitude} lng=${dmLocation.longitude}',
          );
          updateDeliverymanMarker(dmLocation);
        },
      );
    }
  }

  void _startDeliveryLocationFallbackTimer() {
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 10), (timer) async {
      if (_isDisposed || !mounted) {
        timer.cancel();
        return;
      }

      if (Get.currentRoute.contains(RouteHelper.orderDetails) ||
          Get.currentRoute.contains(RouteHelper.orderTracking)) {
        await _refreshDeliveryMarkerFromTrack();
      } else {
        timer.cancel();
      }
    });
  }

  Future<void> _refreshDeliveryMarkerFromTrack() async {
    if (_isDisposed || !mounted || widget.orderID == null) return;

    await Get.find<OrderController>().timerTrackOrder(
      widget.orderID.toString(),
      contactNumber: widget.contactNumber,
    );

    if (_isDisposed || !mounted) return;
    final OrderModel? trackModel = Get.find<OrderController>().trackModel;
    if (trackModel == null || trackModel.id?.toString() != widget.orderID) {
      return;
    }

    if (!_canTrackDeliveryman(trackModel)) {
      _timer?.cancel();
      _pusherHelper.pusherDisconnectPusher();
      return;
    }

    final DeliveryMan? deliveryMan = trackModel.deliveryMan;
    if (deliveryMan == null) return;

    debugPrint(
      '[PUSHER] fallback location lat=${deliveryMan.lat} lng=${deliveryMan.lng}',
    );
    await updateDeliverymanMarker(
      RecordLocationBodyModel(
        latitude: deliveryMan.lat,
        longitude: deliveryMan.lng,
        location: deliveryMan.location,
      ),
    );
  }

  void _timerTrackOrder() {
    if (Get.find<OrderController>().trackModel?.orderStatus != 'delivered' &&
        Get.find<OrderController>().trackModel?.orderStatus != 'failed' &&
        Get.find<OrderController>().trackModel?.orderStatus != 'canceled') {
      Get.find<OrderController>().timerTrackOrder(
        widget.orderID.toString(),
        contactNumber: widget.contactNumber,
      );
      _timer?.cancel();
      _timer = Timer.periodic(const Duration(seconds: 10), (timer) async {
        if (Get.currentRoute.contains(RouteHelper.orderDetails) ||
            Get.currentRoute.contains(RouteHelper.orderTracking)) {
          await Get.find<OrderController>().timerTrackOrder(
            widget.orderID.toString(),
            contactNumber: widget.contactNumber,
          );

          if (!mounted) return;
          final OrderModel? trackModel = Get.find<OrderController>().trackModel;
          if (trackModel == null) return;
          if (trackModel.id?.toString() != widget.orderID) {
            return;
          }
          updateMarker(
            trackModel.store,
            trackModel.deliveryMan,
            trackModel.orderType == 'take_away'
                ? Get.find<LocationController>().position.latitude == 0
                      ? trackModel.deliveryAddress
                      : AddressModel(
                          latitude: Get.find<LocationController>()
                              .position
                              .latitude
                              .toString(),
                          longitude: Get.find<LocationController>()
                              .position
                              .longitude
                              .toString(),
                          address: Get.find<LocationController>().address,
                        )
                : trackModel.deliveryAddress,
            trackModel.orderType == 'take_away',
            trackModel.orderType == 'parcel',
            trackModel.moduleType == 'food',
          );
        } else {
          _timer?.cancel();
        }
      });
    } else {
      Get.find<OrderController>().timerTrackOrder(
        widget.orderID.toString(),
        contactNumber: widget.contactNumber,
      );
    }
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);

    _loadData();
  }

  @override
  void didChangeAppLifecycleState(final AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      if (_isWebsocketTrackingEnabled) {
        _startLiveTracking();
      } else {
        _timerTrackOrder();
      }
    } else if (state == AppLifecycleState.paused) {
      _timer?.cancel();
      _deliveryMarkerAnimationTimer?.cancel();
    }
  }

  @override
  void dispose() {
    _isDisposed = true;
    _timer?.cancel();
    _deliveryMarkerAnimationTimer?.cancel();
    _pusherHelper.pusherDisconnectPusher();
    _controller?.dispose();
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
      endDrawer: const MenuDrawer(),
      endDrawerEnableOpenDragGesture: false,
      body: GetBuilder<OrderController>(
        builder: (orderController) {
          OrderModel? track;
          if (orderController.trackModel != null &&
              orderController.trackModel!.id?.toString() == widget.orderID) {
            _localTrackModel = orderController.trackModel;

            if (_localTrackModel!.orderType != 'parcel') {
              if (_localTrackModel!.store!.storeBusinessModel == 'commission') {
                showChatPermission = true;
              } else if (_localTrackModel!.store!.storeSubscription != null &&
                  _localTrackModel!.store!.storeBusinessModel ==
                      'subscription') {
                showChatPermission =
                    _localTrackModel!.store!.storeSubscription!.chat == 1;
              } else {
                showChatPermission = false;
              }
            } else {
              showChatPermission = AuthHelper.isLoggedIn();
            }
          }
          track = _localTrackModel;

          return track != null
              ? SingleChildScrollView(
                  physics: isHovered || !ResponsiveHelper.isDesktop(context)
                      ? const NeverScrollableScrollPhysics()
                      : const AlwaysScrollableScrollPhysics(),
                  child: FooterView(
                    child: Center(
                      child: SizedBox(
                        width: Dimensions.webMaxWidth,
                        height: ResponsiveHelper.isDesktop(context)
                            ? 700
                            : MediaQuery.of(context).size.height * 0.85,
                        child: Stack(
                          children: [
                            MouseRegion(
                              onEnter: (event) => onEntered(true),
                              onExit: (event) => onEntered(false),
                              child: GoogleMap(
                                initialCameraPosition: CameraPosition(
                                  target: LatLng(
                                    double.parse(
                                      track.deliveryAddress!.latitude!,
                                    ),
                                    double.parse(
                                      track.deliveryAddress!.longitude!,
                                    ),
                                  ),
                                  zoom: 16,
                                ),
                                minMaxZoomPreference:
                                    const MinMaxZoomPreference(0, 16),
                                zoomControlsEnabled: false,
                                markers: _markers,
                                polylines: _polylines,
                                onMapCreated: (GoogleMapController controller) {
                                  _controller = controller;
                                  _isLoading = false;
                                  setMarker(
                                    track!.orderType == 'parcel'
                                        ? Store(
                                            latitude:
                                                track.receiverDetails!.latitude,
                                            longitude: track
                                                .receiverDetails!
                                                .longitude,
                                            address:
                                                track.receiverDetails!.address,
                                            name: track
                                                .receiverDetails!
                                                .contactPersonName,
                                          )
                                        : track.store,
                                    track.deliveryMan,
                                    track.orderType == 'take_away'
                                        ? Get.find<LocationController>()
                                                      .position
                                                      .latitude ==
                                                  0
                                              ? track.deliveryAddress
                                              : AddressModel(
                                                  latitude:
                                                      Get.find<
                                                            LocationController
                                                          >()
                                                          .position
                                                          .latitude
                                                          .toString(),
                                                  longitude:
                                                      Get.find<
                                                            LocationController
                                                          >()
                                                          .position
                                                          .longitude
                                                          .toString(),
                                                  address:
                                                      Get.find<
                                                            LocationController
                                                          >()
                                                          .address,
                                                )
                                        : track.deliveryAddress,
                                    track.orderType == 'take_away',
                                    track.orderType == 'parcel',
                                    track.moduleType == 'food',
                                  );
                                },
                                style: Get.isDarkMode
                                    ? Get.find<ThemeController>().darkMap
                                    : Get.find<ThemeController>().lightMap,
                              ),
                            ),

                            _isLoading
                                ? const Center(
                                    child: CircularProgressIndicator(),
                                  )
                                : const SizedBox(),

                            Positioned(
                              top: Dimensions.paddingSizeSmall,
                              left: Dimensions.paddingSizeSmall,
                              right: Dimensions.paddingSizeSmall,
                              child: TrackingStepperWidget(
                                status: track.orderStatus,
                                takeAway: track.orderType == 'take_away',
                              ),
                            ),

                            Positioned(
                              right: 15,
                              bottom:
                                  track.orderType != 'take_away' &&
                                      track.deliveryMan == null
                                  ? 150
                                  : 220,
                              child: InkWell(
                                onTap: () => _checkPermission(() async {
                                  AddressModel address =
                                      await Get.find<LocationController>()
                                          .getCurrentLocation(
                                            false,
                                            mapController: _controller,
                                          );
                                  setMarker(
                                    track!.orderType == 'parcel'
                                        ? Store(
                                            latitude:
                                                track.receiverDetails!.latitude,
                                            longitude: track
                                                .receiverDetails!
                                                .longitude,
                                            address:
                                                track.receiverDetails!.address,
                                            name: track
                                                .receiverDetails!
                                                .contactPersonName,
                                          )
                                        : track.store,
                                    track.deliveryMan,
                                    track.orderType == 'take_away'
                                        ? Get.find<LocationController>()
                                                      .position
                                                      .latitude ==
                                                  0
                                              ? track.deliveryAddress
                                              : AddressModel(
                                                  latitude:
                                                      Get.find<
                                                            LocationController
                                                          >()
                                                          .position
                                                          .latitude
                                                          .toString(),
                                                  longitude:
                                                      Get.find<
                                                            LocationController
                                                          >()
                                                          .position
                                                          .longitude
                                                          .toString(),
                                                  address:
                                                      Get.find<
                                                            LocationController
                                                          >()
                                                          .address,
                                                )
                                        : track.deliveryAddress,
                                    track.orderType == 'take_away',
                                    track.orderType == 'parcel',
                                    track.moduleType == 'food',
                                    currentAddress: address,
                                    fromCurrentLocation: true,
                                  );
                                }),
                                child: Container(
                                  padding: const EdgeInsets.all(
                                    Dimensions.paddingSizeSmall,
                                  ),
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(50),
                                    color: Colors.white,
                                  ),
                                  child: Icon(
                                    Icons.my_location_outlined,
                                    color: Theme.of(context).primaryColor,
                                    size: 25,
                                  ),
                                ),
                              ),
                            ),

                            Positioned(
                              bottom: Dimensions.paddingSizeSmall,
                              left: Dimensions.paddingSizeSmall,
                              right: Dimensions.paddingSizeSmall,
                              child: TrackDetailsViewWidget(
                                status: track.orderStatus,
                                track: track,
                                showChatPermission: showChatPermission,
                                callback: () async {
                                  bool takeAway =
                                      track?.orderType == 'take_away';
                                  _timer?.cancel();
                                  await Get.toNamed(
                                    RouteHelper.getChatRoute(
                                      notificationBody: takeAway
                                          ? NotificationBodyModel(
                                              restaurantId: track!.store!.id,
                                              orderId: int.parse(
                                                widget.orderID!,
                                              ),
                                            )
                                          : NotificationBodyModel(
                                              deliverymanId:
                                                  track!.deliveryMan!.id,
                                              orderId: int.parse(
                                                widget.orderID!,
                                              ),
                                            ),
                                      user: User(
                                        id: takeAway
                                            ? track.store!.id
                                            : track.deliveryMan!.id,
                                        fName: takeAway
                                            ? track.store!.name
                                            : track.deliveryMan!.fName,
                                        lName: takeAway
                                            ? ''
                                            : track.deliveryMan!.lName,
                                        imageFullUrl: takeAway
                                            ? track.store!.logoFullUrl
                                            : track.deliveryMan!.imageFullUrl,
                                      ),
                                    ),
                                  );
                                  _timerTrackOrder();
                                },
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                )
              : const Center(child: CircularProgressIndicator());
        },
      ),
    );
  }

  void setMarker(
    Store? store,
    DeliveryMan? deliveryMan,
    AddressModel? addressModel,
    bool takeAway,
    bool parcel,
    bool isRestaurant, {
    AddressModel? currentAddress,
    bool fromCurrentLocation = false,
  }) async {
    try {
      BitmapDescriptor restaurantImageData =
          await MarkerHelper.convertAssetToBitmapDescriptor(
            width: 30,
            imagePath: parcel
                ? Images.userMarker
                : isRestaurant
                ? Images.restaurantMarker
                : Images.markerStore,
          );

      BitmapDescriptor deliveryBoyImageData =
          await MarkerHelper.convertAssetToBitmapDescriptor(
            width: 30,
            imagePath: Images.deliveryManMarker,
          );
      BitmapDescriptor destinationImageData =
          await MarkerHelper.convertAssetToBitmapDescriptor(
            width: 30,
            imagePath: Images.userMarker,
          );

      /// Animate to coordinate
      LatLngBounds? bounds;
      double rotation = 0;
      if (_controller != null) {
        if (double.parse(addressModel!.latitude!) <
            double.parse(store!.latitude!)) {
          bounds = LatLngBounds(
            southwest: LatLng(
              double.parse(addressModel.latitude!),
              double.parse(addressModel.longitude!),
            ),
            northeast: LatLng(
              double.parse(store.latitude!),
              double.parse(store.longitude!),
            ),
          );
          rotation = 0;
        } else {
          bounds = LatLngBounds(
            southwest: LatLng(
              double.parse(store.latitude!),
              double.parse(store.longitude!),
            ),
            northeast: LatLng(
              double.parse(addressModel.latitude!),
              double.parse(addressModel.longitude!),
            ),
          );
          rotation = 180;
        }
      }
      LatLng centerBounds = LatLng(
        (bounds!.northeast.latitude + bounds.southwest.latitude) / 2,
        (bounds.northeast.longitude + bounds.southwest.longitude) / 2,
      );

      if (fromCurrentLocation && currentAddress != null) {
        LatLng currentLocation = LatLng(
          double.parse(currentAddress.latitude!),
          double.parse(currentAddress.longitude!),
        );
        _controller!.moveCamera(
          CameraUpdate.newCameraPosition(
            CameraPosition(
              target: currentLocation,
              zoom: GetPlatform.isWeb ? 7 : 15,
            ),
          ),
        );
      }

      if (!fromCurrentLocation) {
        _controller!.moveCamera(
          CameraUpdate.newCameraPosition(
            CameraPosition(
              target: centerBounds,
              zoom: GetPlatform.isWeb ? 10 : 17,
            ),
          ),
        );
        if (!ResponsiveHelper.isWeb()) {
          zoomToFit(
            _controller,
            bounds,
            centerBounds,
            padding: GetPlatform.isWeb ? 15 : 3,
          );
        }
      }

      /// user for normal order , but sender for parcel order
      _markers = HashSet<Marker>();

      ///current location marker set
      if (currentAddress != null) {
        _markers.add(
          Marker(
            markerId: const MarkerId('current_location'),
            visible: true,
            draggable: false,
            zIndexInt: 2,
            flat: true,
            anchor: const Offset(0.5, 0.5),
            position: LatLng(
              double.parse(currentAddress.latitude!),
              double.parse(currentAddress.longitude!),
            ),
            icon: destinationImageData,
          ),
        );
        if (!mounted) return;
        setState(() {});
      }

      if (currentAddress == null) {
        addressModel != null
            ? _markers.add(
                Marker(
                  markerId: const MarkerId('destination'),
                  position: LatLng(
                    double.parse(addressModel.latitude!),
                    double.parse(addressModel.longitude!),
                  ),
                  infoWindow: InfoWindow(
                    title: parcel ? 'sender'.tr : 'Destination'.tr,
                    snippet: addressModel.address,
                  ),
                  icon: destinationImageData,
                ),
              )
            : const SizedBox();
      }

      ///store for normal order , but receiver for parcel order
      store != null
          ? _markers.add(
              Marker(
                markerId: const MarkerId('store'),
                position: LatLng(
                  double.parse(store.latitude!),
                  double.parse(store.longitude!),
                ),
                infoWindow: InfoWindow(
                  title: parcel
                      ? 'receiver'.tr
                      : Get.find<SplashController>()
                            .configModel!
                            .moduleConfig!
                            .module!
                            .showRestaurantText!
                      ? 'store'.tr
                      : 'store'.tr,
                  snippet: store.address,
                ),
                icon: restaurantImageData,
              ),
            )
          : const SizedBox();

      if (deliveryMan != null) {
        final LatLng deliveryManPosition = LatLng(
          double.parse(deliveryMan.lat ?? '0'),
          double.parse(deliveryMan.lng ?? '0'),
        );
        _deliveryMarkerPosition = deliveryManPosition;
        _deliveryMarkerIcon = deliveryBoyImageData;
        _deliveryMarkerSnippet = deliveryMan.location;
        _deliveryMarkerRotation = rotation;
        _markers.add(
          _buildDeliveryMarker(
            position: deliveryManPosition,
            icon: deliveryBoyImageData,
            snippet: deliveryMan.location,
            rotation: rotation,
          ),
        );
      }

      await _updateRoutePolyline(
        store: store,
        addressModel: addressModel,
        currentAddress: currentAddress,
        parcel: parcel,
      );
    } catch (_) {}
    if (!mounted) return;
    setState(() {});
  }

  Future<void> updateDeliverymanMarker(
    RecordLocationBodyModel dmLocation,
  ) async {
    if (_isDisposed || !mounted) return;

    final LatLng? targetPosition = _latLngFromDeliverymanLocation(dmLocation);
    if (targetPosition == null) return;
    final DateTime receivedAt = DateTime.now();
    final double? observedSpeed = _deliveryLocationObservedSpeed(
      targetPosition,
      receivedAt,
    );

    final BitmapDescriptor deliveryBoyImageData =
        await _getDeliveryMarkerIcon();
    if (_isDisposed || !mounted) return;

    final LatLng? startPosition =
        _deliveryMarkerPosition ?? _currentDeliveryMarkerPosition();
    if (startPosition == null) {
      _rememberDeliveryLocation(targetPosition, receivedAt);
      final _RouteProjection? initialProjection = _projectToRoute(
        targetPosition,
      );
      if (initialProjection != null &&
          initialProjection.distanceFromRoute <= _routeHardOffRouteDistance) {
        _setDeliveryMarkerPosition(
          position: _latLngAtRouteDistance(initialProjection.routeDistance),
          icon: deliveryBoyImageData,
          snippet: dmLocation.location,
          rotation: _routeBearingAtDistance(
            initialProjection.routeDistance,
            true,
          ),
          routeDistance: initialProjection.routeDistance,
        );
        return;
      }

      _setDeliveryMarkerPosition(
        position: targetPosition,
        icon: deliveryBoyImageData,
        snippet: dmLocation.location,
        rotation: _deliveryMarkerRotation,
      );
      return;
    }

    final double distance = Geolocator.distanceBetween(
      startPosition.latitude,
      startPosition.longitude,
      targetPosition.latitude,
      targetPosition.longitude,
    );

    if (distance <= _deliveryMarkerJitterDistance) {
      _deliveryMarkerPosition = startPosition;
      _deliveryMarkerIcon = deliveryBoyImageData;
      _deliveryMarkerSnippet = dmLocation.location;
      _rememberDeliveryLocation(targetPosition, receivedAt);
      return;
    }

    final double rotation = Geolocator.bearingBetween(
      startPosition.latitude,
      startPosition.longitude,
      targetPosition.latitude,
      targetPosition.longitude,
    );

    if (distance >= _deliveryMarkerTeleportDistance) {
      _setDeliveryMarkerPosition(
        position: targetPosition,
        icon: deliveryBoyImageData,
        snippet: dmLocation.location,
        rotation: rotation,
      );
      _rememberDeliveryLocation(targetPosition, receivedAt);
      return;
    }

    final _RouteTravelResult routeTravelResult = _routeTravelBetween(
      startPosition,
      targetPosition,
    );
    final Duration animationDuration = _deliveryMarkerAnimationDurationFor(
      routeTravelResult.travel?.distance ?? distance,
      observedSpeed: observedSpeed,
    );
    debugPrint(
      '[TRACKING] marker distance=${distance.toStringAsFixed(1)}m '
      'speed=${observedSpeed?.toStringAsFixed(2) ?? "-"}mps '
      'route=${routeTravelResult.travel != null} '
      'rawFallback=${routeTravelResult.allowRawFallback} '
      'offRoute=$_offRouteLocationCount '
      'duration=${animationDuration.inMilliseconds}ms',
    );

    if (routeTravelResult.travel == null &&
        !routeTravelResult.allowRawFallback) {
      _deliveryMarkerIcon = deliveryBoyImageData;
      _deliveryMarkerSnippet = dmLocation.location;
      _rememberDeliveryLocation(targetPosition, receivedAt);
      return;
    }

    _animateDeliveryMarker(
      from: startPosition,
      to: targetPosition,
      icon: deliveryBoyImageData,
      snippet: dmLocation.location,
      rotation: rotation,
      duration: animationDuration,
      routeTravel: routeTravelResult.travel,
    );
    _rememberDeliveryLocation(targetPosition, receivedAt);
  }

  void updateMarker(
    Store? store,
    DeliveryMan? deliveryMan,
    AddressModel? addressModel,
    bool takeAway,
    bool parcel,
    bool isRestaurant, {
    AddressModel? currentAddress,
    bool fromCurrentLocation = false,
  }) async {
    if (_isDisposed || !mounted) return;
    try {
      BitmapDescriptor restaurantImageData =
          await MarkerHelper.convertAssetToBitmapDescriptor(
            width: 30,
            imagePath: parcel
                ? Images.userMarker
                : isRestaurant
                ? Images.restaurantMarker
                : Images.markerStore,
          );

      BitmapDescriptor deliveryBoyImageData =
          await MarkerHelper.convertAssetToBitmapDescriptor(
            width: 30,
            imagePath: Images.deliveryManMarker,
          );
      BitmapDescriptor destinationImageData =
          await MarkerHelper.convertAssetToBitmapDescriptor(
            width: 30,
            imagePath: Images.userMarker,
          );

      double rotation = 0;
      if (_controller != null && addressModel != null && store != null) {
        if (double.parse(addressModel.latitude!) <
            double.parse(store.latitude!)) {
          rotation = 0;
        } else {
          rotation = 180;
        }
      }

      /// user for normal order , but sender for parcel order
      _markers = HashSet<Marker>();

      ///current location marker set
      if (currentAddress != null) {
        _markers.add(
          Marker(
            markerId: const MarkerId('current_location'),
            visible: true,
            draggable: false,
            zIndexInt: 2,
            flat: true,
            anchor: const Offset(0.5, 0.5),
            position: LatLng(
              double.parse(currentAddress.latitude!),
              double.parse(currentAddress.longitude!),
            ),
            icon: destinationImageData,
          ),
        );
        if (_isDisposed || !mounted) return;
        setState(() {});
      }

      if (currentAddress == null) {
        addressModel != null
            ? _markers.add(
                Marker(
                  markerId: const MarkerId('destination'),
                  position: LatLng(
                    double.parse(addressModel.latitude!),
                    double.parse(addressModel.longitude!),
                  ),
                  infoWindow: InfoWindow(
                    title: parcel ? 'sender'.tr : 'Destination'.tr,
                    snippet: addressModel.address,
                  ),
                  icon: destinationImageData,
                ),
              )
            : const SizedBox();
      }

      ///store for normal order , but receiver for parcel order
      store != null
          ? _markers.add(
              Marker(
                markerId: const MarkerId('store'),
                position: LatLng(
                  double.parse(store.latitude!),
                  double.parse(store.longitude!),
                ),
                infoWindow: InfoWindow(
                  title: parcel
                      ? 'receiver'.tr
                      : Get.find<SplashController>()
                            .configModel!
                            .moduleConfig!
                            .module!
                            .showRestaurantText!
                      ? 'store'.tr
                      : 'store'.tr,
                  snippet: store.address,
                ),
                icon: restaurantImageData,
              ),
            )
          : const SizedBox();

      if (deliveryMan != null) {
        final LatLng deliveryManPosition = LatLng(
          double.parse(deliveryMan.lat ?? '0'),
          double.parse(deliveryMan.lng ?? '0'),
        );
        _deliveryMarkerPosition = deliveryManPosition;
        _deliveryMarkerIcon = deliveryBoyImageData;
        _deliveryMarkerSnippet = deliveryMan.location;
        _deliveryMarkerRotation = rotation;
        _markers.add(
          _buildDeliveryMarker(
            position: deliveryManPosition,
            icon: deliveryBoyImageData,
            snippet: deliveryMan.location,
            rotation: rotation,
          ),
        );
      }

      await _updateRoutePolyline(
        store: store,
        addressModel: addressModel,
        currentAddress: currentAddress,
        parcel: parcel,
      );
    } catch (_) {}
    if (_isDisposed || !mounted) return;
    setState(() {});
  }

  Future<BitmapDescriptor> _getDeliveryMarkerIcon() async {
    final BitmapDescriptor? icon = _deliveryMarkerIcon;
    if (icon != null) {
      return icon;
    }

    final BitmapDescriptor deliveryBoyImageData =
        await MarkerHelper.convertAssetToBitmapDescriptor(
          width: 30,
          imagePath: Images.deliveryManMarker,
        );
    _deliveryMarkerIcon = deliveryBoyImageData;
    return deliveryBoyImageData;
  }

  Marker _buildDeliveryMarker({
    required LatLng position,
    required BitmapDescriptor icon,
    required String? snippet,
    required double rotation,
  }) {
    return Marker(
      markerId: const MarkerId('delivery_boy'),
      position: position,
      infoWindow: InfoWindow(title: 'delivery_man'.tr, snippet: snippet),
      rotation: rotation,
      icon: icon,
      zIndexInt: 3,
    );
  }

  LatLng? _latLngFromDeliverymanLocation(RecordLocationBodyModel dmLocation) {
    final double? latitude = double.tryParse(dmLocation.latitude ?? '');
    final double? longitude = double.tryParse(dmLocation.longitude ?? '');

    if (latitude == null ||
        longitude == null ||
        (latitude == 0 && longitude == 0)) {
      return null;
    }

    return LatLng(latitude, longitude);
  }

  LatLng? _currentDeliveryMarkerPosition() {
    for (final Marker marker in _markers) {
      if (marker.markerId.value == 'delivery_boy') {
        return marker.position;
      }
    }
    return null;
  }

  void _animateDeliveryMarker({
    required LatLng from,
    required LatLng to,
    required BitmapDescriptor icon,
    required String? snippet,
    required double rotation,
    required Duration duration,
    _RouteTravel? routeTravel,
  }) {
    _deliveryMarkerAnimationTimer?.cancel();
    _deliveryMarkerSnippet = snippet;
    _deliveryMarkerRotation = rotation;

    final int durationMs = math.max(1, duration.inMilliseconds);
    final DateTime startedAt = DateTime.now();
    _deliveryMarkerAnimationTimer = Timer.periodic(
      _deliveryMarkerFrameDuration,
      (Timer timer) {
        if (_isDisposed || !mounted) {
          timer.cancel();
          return;
        }

        final double progress = DateTime.now()
            .difference(startedAt)
            .inMilliseconds
            .toDouble();
        final double t = (progress / durationMs).clamp(0.0, 1.0).toDouble();
        final double movementT = t;
        final LatLng position;
        final double markerRotation;
        final double? markerRouteDistance;
        if (routeTravel != null) {
          final double routeDistance =
              routeTravel.fromDistance +
              ((routeTravel.toDistance - routeTravel.fromDistance) * movementT);
          position = _latLngAtRouteDistance(routeDistance);
          markerRotation = _routeBearingAtDistance(
            routeDistance,
            routeTravel.forward,
          );
          markerRouteDistance = routeDistance;
        } else {
          position = _lerpLatLng(from, to, movementT);
          markerRotation = rotation;
          markerRouteDistance = null;
        }

        _setDeliveryMarkerPosition(
          position: position,
          icon: icon,
          snippet: snippet,
          rotation: markerRotation,
          routeDistance: markerRouteDistance,
        );

        if (t >= 1) {
          timer.cancel();
          if (_deliveryMarkerAnimationTimer == timer) {
            _deliveryMarkerAnimationTimer = null;
          }
        }
      },
    );
  }

  LatLng _lerpLatLng(LatLng from, LatLng to, double t) {
    return LatLng(
      from.latitude + (to.latitude - from.latitude) * t,
      from.longitude + (to.longitude - from.longitude) * t,
    );
  }

  Duration _deliveryMarkerAnimationDurationFor(
    double distance, {
    double? observedSpeed,
  }) {
    final double minSeconds =
        _deliveryMarkerMinAnimationDuration.inMilliseconds /
        Duration.millisecondsPerSecond;
    final double maxSeconds =
        _deliveryMarkerMaxAnimationDuration.inMilliseconds /
        Duration.millisecondsPerSecond;
    final double animationSpeed = _deliveryMarkerAnimationSpeedFor(
      observedSpeed,
    );
    final double seconds = (distance / animationSpeed)
        .clamp(minSeconds, maxSeconds)
        .toDouble();
    return Duration(milliseconds: (seconds * 1000).round());
  }

  double _deliveryMarkerAnimationSpeedFor(double? observedSpeed) {
    if (observedSpeed == null || observedSpeed <= 0) {
      return _deliveryMarkerDefaultMetersPerSecond;
    }
    if (observedSpeed <= _deliveryMarkerWalkingSpeedThreshold) {
      return _deliveryMarkerWalkingMetersPerSecond;
    }
    return observedSpeed
        .clamp(
          _deliveryMarkerWalkingMetersPerSecond,
          _deliveryMarkerMaxMetersPerSecond,
        )
        .toDouble();
  }

  double? _deliveryLocationObservedSpeed(LatLng target, DateTime receivedAt) {
    final LatLng? previousTarget = _lastDeliveryLocationTarget;
    final DateTime? previousReceivedAt = _lastDeliveryLocationReceivedAt;
    if (previousTarget == null || previousReceivedAt == null) {
      return null;
    }

    final int elapsedMs = receivedAt
        .difference(previousReceivedAt)
        .inMilliseconds;
    if (elapsedMs < 1000 || elapsedMs > 60000) {
      return null;
    }

    final double distance = Geolocator.distanceBetween(
      previousTarget.latitude,
      previousTarget.longitude,
      target.latitude,
      target.longitude,
    );
    return distance / (elapsedMs / Duration.millisecondsPerSecond);
  }

  void _rememberDeliveryLocation(LatLng target, DateTime receivedAt) {
    _lastDeliveryLocationTarget = target;
    _lastDeliveryLocationReceivedAt = receivedAt;
  }

  _RouteTravelResult _routeTravelBetween(LatLng from, LatLng to) {
    if (_routePolylinePoints.length < 2) {
      return const _RouteTravelResult(allowRawFallback: true);
    }

    final double directDistance = Geolocator.distanceBetween(
      from.latitude,
      from.longitude,
      to.latitude,
      to.longitude,
    );
    final _RouteProjection? fromProjection = _projectToRoute(from);
    final double? fromDistance =
        _deliveryMarkerRouteDistance ?? fromProjection?.routeDistance;
    if (fromDistance == null) {
      return const _RouteTravelResult(allowRawFallback: true);
    }

    final double forwardWindow = math
        .max(
          _routeForwardWindowMin,
          directDistance * _routeForwardWindowMultiplier,
        )
        .clamp(_routeForwardWindowMin, _routeForwardWindowMax)
        .toDouble();
    final _RouteProjection? toProjection = _projectToRoute(
      to,
      minRouteDistance: math.max(0, fromDistance - _routeBacktrackAllowance),
      maxRouteDistance: fromDistance + forwardWindow,
    );

    if (toProjection == null ||
        toProjection.distanceFromRoute > _routeHardOffRouteDistance) {
      _offRouteLocationCount++;
      return _RouteTravelResult(
        allowRawFallback: _offRouteLocationCount >= _offRouteFallbackThreshold,
      );
    }

    if (toProjection.distanceFromRoute > _routeSnapCorridorDistance) {
      _offRouteLocationCount++;
    } else {
      _offRouteLocationCount = 0;
    }

    final double routeDistance = (toProjection.routeDistance - fromDistance)
        .abs();
    if (routeDistance <= _deliveryMarkerJitterDistance) {
      return const _RouteTravelResult(allowRawFallback: false);
    }

    return _RouteTravelResult(
      travel: _RouteTravel(
        fromDistance: fromDistance,
        toDistance: toProjection.routeDistance,
      ),
      allowRawFallback: false,
    );
  }

  _RouteProjection? _projectToRoute(
    LatLng point, {
    double? minRouteDistance,
    double? maxRouteDistance,
  }) {
    if (_routePolylinePoints.length < 2) {
      return null;
    }

    double traveledDistance = 0;
    _RouteProjection? bestProjection;
    for (int i = 0; i < _routePolylinePoints.length - 1; i++) {
      final LatLng segmentStart = _routePolylinePoints[i];
      final LatLng segmentEnd = _routePolylinePoints[i + 1];
      final double segmentLength = Geolocator.distanceBetween(
        segmentStart.latitude,
        segmentStart.longitude,
        segmentEnd.latitude,
        segmentEnd.longitude,
      );

      if (segmentLength <= 0) {
        continue;
      }

      final _MeterPoint localStart = _toLocalMeters(segmentStart, point);
      final _MeterPoint localEnd = _toLocalMeters(segmentEnd, point);
      final double dx = localEnd.x - localStart.x;
      final double dy = localEnd.y - localStart.y;
      final double segmentLengthSquared = (dx * dx) + (dy * dy);
      if (segmentLengthSquared <= 0) {
        traveledDistance += segmentLength;
        continue;
      }

      final double t =
          ((-(localStart.x * dx) - (localStart.y * dy)) / segmentLengthSquared)
              .clamp(0.0, 1.0)
              .toDouble();
      final double projectedX = localStart.x + (dx * t);
      final double projectedY = localStart.y + (dy * t);
      final double distanceFromRoute = math.sqrt(
        (projectedX * projectedX) + (projectedY * projectedY),
      );
      final double projectionRouteDistance =
          traveledDistance + (segmentLength * t);
      if ((minRouteDistance != null &&
              projectionRouteDistance < minRouteDistance) ||
          (maxRouteDistance != null &&
              projectionRouteDistance > maxRouteDistance)) {
        traveledDistance += segmentLength;
        continue;
      }
      final _RouteProjection projection = _RouteProjection(
        routeDistance: projectionRouteDistance,
        distanceFromRoute: distanceFromRoute,
      );

      if (bestProjection == null ||
          projection.distanceFromRoute < bestProjection.distanceFromRoute) {
        bestProjection = projection;
      }

      traveledDistance += segmentLength;
    }

    return bestProjection;
  }

  LatLng _latLngAtRouteDistance(double routeDistance) {
    if (_routePolylinePoints.isEmpty) {
      return _deliveryMarkerPosition ?? const LatLng(0, 0);
    }
    if (_routePolylinePoints.length < 2) {
      return _routePolylinePoints.first;
    }

    double traveledDistance = 0;
    for (int i = 0; i < _routePolylinePoints.length - 1; i++) {
      final LatLng segmentStart = _routePolylinePoints[i];
      final LatLng segmentEnd = _routePolylinePoints[i + 1];
      final double segmentLength = Geolocator.distanceBetween(
        segmentStart.latitude,
        segmentStart.longitude,
        segmentEnd.latitude,
        segmentEnd.longitude,
      );

      if (segmentLength <= 0) {
        continue;
      }

      if (routeDistance <= traveledDistance + segmentLength) {
        final double t = ((routeDistance - traveledDistance) / segmentLength)
            .clamp(0.0, 1.0)
            .toDouble();
        return _lerpLatLng(segmentStart, segmentEnd, t);
      }

      traveledDistance += segmentLength;
    }

    return _routePolylinePoints.last;
  }

  double _routeBearingAtDistance(double routeDistance, bool forward) {
    const double sampleDistance = 10;
    final LatLng start = _latLngAtRouteDistance(
      forward ? routeDistance : routeDistance + sampleDistance,
    );
    final LatLng end = _latLngAtRouteDistance(
      forward ? routeDistance + sampleDistance : routeDistance - sampleDistance,
    );
    final double sampleGap = Geolocator.distanceBetween(
      start.latitude,
      start.longitude,
      end.latitude,
      end.longitude,
    );

    if (sampleGap <= 1) {
      return _deliveryMarkerRotation;
    }

    return Geolocator.bearingBetween(
      start.latitude,
      start.longitude,
      end.latitude,
      end.longitude,
    );
  }

  _MeterPoint _toLocalMeters(LatLng point, LatLng origin) {
    const double earthRadius = 6371000;
    final double originLatRadians = origin.latitude * math.pi / 180;
    return _MeterPoint(
      x:
          (point.longitude - origin.longitude) *
          math.pi /
          180 *
          earthRadius *
          math.cos(originLatRadians),
      y: (point.latitude - origin.latitude) * math.pi / 180 * earthRadius,
    );
  }

  List<LatLng> _densifyRoutePoints(List<LatLng> routePoints) {
    if (routePoints.length < 2) {
      return routePoints;
    }

    final List<LatLng> densifiedPoints = <LatLng>[routePoints.first];
    for (int i = 0; i < routePoints.length - 1; i++) {
      final LatLng segmentStart = routePoints[i];
      final LatLng segmentEnd = routePoints[i + 1];
      final double segmentLength = Geolocator.distanceBetween(
        segmentStart.latitude,
        segmentStart.longitude,
        segmentEnd.latitude,
        segmentEnd.longitude,
      );
      final int steps = math.max(
        1,
        (segmentLength / _routeDensifySegmentLength).ceil(),
      );

      for (int step = 1; step <= steps; step++) {
        densifiedPoints.add(
          _lerpLatLng(segmentStart, segmentEnd, step / steps),
        );
      }
    }

    return densifiedPoints;
  }

  void _setDeliveryMarkerPosition({
    required LatLng position,
    required BitmapDescriptor icon,
    required String? snippet,
    required double rotation,
    double? routeDistance,
  }) {
    _deliveryMarkerPosition = position;
    _deliveryMarkerIcon = icon;
    _deliveryMarkerSnippet = snippet;
    _deliveryMarkerRotation = rotation;
    _deliveryMarkerRouteDistance = routeDistance;

    _markers.removeWhere((m) => m.markerId.value == 'delivery_boy');
    _markers.add(
      _buildDeliveryMarker(
        position: position,
        icon: icon,
        snippet: _deliveryMarkerSnippet,
        rotation: _deliveryMarkerRotation,
      ),
    );

    if (_isDisposed || !mounted) return;
    setState(() {});
  }

  Future<void> _updateRoutePolyline({
    required Store? store,
    required AddressModel? addressModel,
    required AddressModel? currentAddress,
    required bool parcel,
  }) async {
    final LatLng? routeOrigin = _getRouteOrigin(store, addressModel, parcel);
    final LatLng? routeDestination = _getRouteDestination(
      store,
      addressModel,
      currentAddress,
      parcel,
    );

    if (routeOrigin == null || routeDestination == null) {
      _routeKey = null;
      _routePolylinePoints = const <LatLng>[];
      _deliveryMarkerRouteDistance = null;
      _offRouteLocationCount = 0;
      _polylines = HashSet<Polyline>();
      return;
    }

    final String nextRouteKey = _buildRouteKey(routeOrigin, routeDestination);
    if (_routeKey == nextRouteKey && _polylines.isNotEmpty) {
      return;
    }

    final List<LatLng> routePoints = await RoutePolylineHelper.getRoutePoints(
      origin: routeOrigin,
      destination: routeDestination,
    );

    if (!mounted) {
      return;
    }

    _routeKey = nextRouteKey;
    _routePolylinePoints = _densifyRoutePoints(routePoints);
    _deliveryMarkerRouteDistance = null;
    _offRouteLocationCount = 0;
    _polylines = routePoints.isEmpty
        ? HashSet<Polyline>()
        : HashSet<Polyline>.from([
            Polyline(
              polylineId: const PolylineId('order_route'),
              color: const Color(0xFF4285F4),
              width: 5,
              geodesic: true,
              points: routePoints,
            ),
          ]);
  }

  LatLng? _getRouteOrigin(
    Store? store,
    AddressModel? addressModel,
    bool parcel,
  ) {
    if (parcel) {
      return _latLngFromAddress(addressModel);
    }
    return _latLngFromStore(store);
  }

  LatLng? _getRouteDestination(
    Store? store,
    AddressModel? addressModel,
    AddressModel? currentAddress,
    bool parcel,
  ) {
    if (parcel) {
      return _latLngFromStore(store);
    }
    return _latLngFromAddress(currentAddress ?? addressModel);
  }

  LatLng? _latLngFromStore(Store? store) {
    if (store?.latitude == null || store?.longitude == null) {
      return null;
    }
    final double? lat = double.tryParse(store!.latitude!);
    final double? lng = double.tryParse(store.longitude!);
    if (lat == null || lng == null || (lat == 0 && lng == 0)) {
      return null;
    }
    return LatLng(lat, lng);
  }

  LatLng? _latLngFromAddress(AddressModel? address) {
    if (address?.latitude == null || address?.longitude == null) {
      return null;
    }
    final double? lat = double.tryParse(address!.latitude!);
    final double? lng = double.tryParse(address.longitude!);
    if (lat == null || lng == null || (lat == 0 && lng == 0)) {
      return null;
    }
    return LatLng(lat, lng);
  }

  String _buildRouteKey(LatLng origin, LatLng destination) {
    return '${origin.latitude.toStringAsFixed(6)},${origin.longitude.toStringAsFixed(6)}'
        '->${destination.latitude.toStringAsFixed(6)},${destination.longitude.toStringAsFixed(6)}';
  }

  Future<void> zoomToFit(
    GoogleMapController? controller,
    LatLngBounds? bounds,
    LatLng centerBounds, {
    double padding = 0.5,
  }) async {
    bool keepZoomingOut = true;

    while (keepZoomingOut) {
      final LatLngBounds screenBounds = await controller!.getVisibleRegion();
      if (fits(bounds!, screenBounds)) {
        keepZoomingOut = false;
        final double zoomLevel = await controller.getZoomLevel() - padding;
        controller.moveCamera(
          CameraUpdate.newCameraPosition(
            CameraPosition(target: centerBounds, zoom: zoomLevel),
          ),
        );
        break;
      } else {
        // Zooming out by 0.1 zoom level per iteration
        final double zoomLevel = await controller.getZoomLevel() - 0.1;
        controller.moveCamera(
          CameraUpdate.newCameraPosition(
            CameraPosition(target: centerBounds, zoom: zoomLevel),
          ),
        );
      }
    }
  }

  bool fits(LatLngBounds fitBounds, LatLngBounds screenBounds) {
    final bool northEastLatitudeCheck =
        screenBounds.northeast.latitude >= fitBounds.northeast.latitude;
    final bool northEastLongitudeCheck =
        screenBounds.northeast.longitude >= fitBounds.northeast.longitude;

    final bool southWestLatitudeCheck =
        screenBounds.southwest.latitude <= fitBounds.southwest.latitude;
    final bool southWestLongitudeCheck =
        screenBounds.southwest.longitude <= fitBounds.southwest.longitude;

    return northEastLatitudeCheck &&
        northEastLongitudeCheck &&
        southWestLatitudeCheck &&
        southWestLongitudeCheck;
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

class _RouteTravel {
  const _RouteTravel({required this.fromDistance, required this.toDistance});

  final double fromDistance;
  final double toDistance;

  double get distance => (toDistance - fromDistance).abs();
  bool get forward => toDistance >= fromDistance;
}

class _RouteTravelResult {
  const _RouteTravelResult({this.travel, required this.allowRawFallback});

  final _RouteTravel? travel;
  final bool allowRawFallback;
}

class _RouteProjection {
  const _RouteProjection({
    required this.routeDistance,
    required this.distanceFromRoute,
  });

  final double routeDistance;
  final double distanceFromRoute;
}

class _MeterPoint {
  const _MeterPoint({required this.x, required this.y});

  final double x;
  final double y;
}
