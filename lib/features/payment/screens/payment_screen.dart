import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:sixam_mart/features/splash/controllers/splash_controller.dart';
import 'package:sixam_mart/features/order/controllers/order_controller.dart';
import 'package:sixam_mart/features/order/domain/models/order_model.dart';
import 'package:sixam_mart/features/location/domain/models/zone_response_model.dart';
import 'package:sixam_mart/helper/address_helper.dart';
import 'package:sixam_mart/helper/route_helper.dart';
import 'package:sixam_mart/util/app_constants.dart';
import 'package:sixam_mart/util/dimensions.dart';
import 'package:sixam_mart/common/widgets/custom_app_bar.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:sixam_mart/features/checkout/widgets/payment_failed_dialog.dart';
import 'package:sixam_mart/features/wallet/widgets/fund_payment_dialog_widget.dart';

class PaymentScreen extends StatefulWidget {
  final OrderModel orderModel;
  final bool isCashOnDelivery;
  final String? addFundUrl;
  final String paymentMethod;
  final String guestId;
  final String contactNumber;
  final String? subscriptionUrl;
  final int? storeId;
  final bool createAccount;
  final int? createUserId;
  const PaymentScreen({
    super.key,
    required this.orderModel,
    required this.isCashOnDelivery,
    this.addFundUrl,
    required this.paymentMethod,
    required this.guestId,
    required this.contactNumber,
    this.storeId,
    this.subscriptionUrl,
    this.createAccount = false,
    this.createUserId,
  });

  @override
  PaymentScreenState createState() => PaymentScreenState();
}

class PaymentScreenState extends State<PaymentScreen> {
  late String selectedUrl;
  double value = 0.0;
  final bool _isLoading = true;
  PullToRefreshController? pullToRefreshController;
  late MyInAppBrowser browser;
  double? _maximumCodOrderAmount;

  @override
  void initState() {
    super.initState();

    if (widget.addFundUrl == '' &&
        widget.addFundUrl!.isEmpty &&
        widget.subscriptionUrl == '' &&
        widget.subscriptionUrl!.isEmpty) {
      final Map<String, String> paymentQueryParameters = {
        'customer_id':
            (widget.orderModel.userId == 0
                    ? widget.guestId
                    : widget.orderModel.userId)
                .toString(),
        'order_id': widget.orderModel.id.toString(),
        'payment_method': widget.paymentMethod,
        'payment_platform': 'app',
      };

      if (GetPlatform.isIOS) {
        paymentQueryParameters['callback'] = _buildIosPaymentReturnUrl();
      }

      selectedUrl = Uri.parse(
        '${AppConstants.baseUrl}/payment-mobile',
      ).replace(queryParameters: paymentQueryParameters).toString();
    } else if (widget.subscriptionUrl != '' &&
        widget.subscriptionUrl!.isNotEmpty) {
      selectedUrl = widget.subscriptionUrl!;
    } else {
      selectedUrl = widget.addFundUrl!;
    }

    if (kDebugMode) {
      print('==========url=======> $selectedUrl');
    }

    _initData();
  }

  void _initData() async {
    if (widget.addFundUrl == '' &&
        widget.addFundUrl!.isEmpty &&
        widget.subscriptionUrl == '' &&
        widget.subscriptionUrl!.isEmpty) {
      for (ZoneData zData
          in AddressHelper.getUserAddressFromSharedPref()!.zoneData!) {
        for (Modules m in zData.modules!) {
          if (m.id == Get.find<SplashController>().module?.id) {
            _maximumCodOrderAmount = m.pivot!.maximumCodOrderAmount;
            break;
          }
        }
      }
    }

    browser = MyInAppBrowser(
      orderID: widget.orderModel.id.toString(),
      orderType: widget.orderModel.orderType,
      orderAmount: widget.orderModel.orderAmount,
      maxCodOrderAmount: _maximumCodOrderAmount,
      isCashOnDelivery: widget.isCashOnDelivery,
      addFundUrl: widget.addFundUrl,
      contactNumber: widget.contactNumber,
      storeId: widget.storeId,
      subscriptionUrl: widget.subscriptionUrl,
      createAccount: widget.createAccount,
      guestId: widget.guestId,
    );

    if (GetPlatform.isAndroid) {
      await InAppWebViewController.setWebContentsDebuggingEnabled(kDebugMode);

      bool swAvailable = await WebViewFeature.isFeatureSupported(
        WebViewFeature.SERVICE_WORKER_BASIC_USAGE,
      );
      bool swInterceptAvailable = await WebViewFeature.isFeatureSupported(
        WebViewFeature.SERVICE_WORKER_SHOULD_INTERCEPT_REQUEST,
      );

      if (swAvailable && swInterceptAvailable) {
        ServiceWorkerController serviceWorkerController =
            ServiceWorkerController.instance();
        await serviceWorkerController.setServiceWorkerClient(
          ServiceWorkerClient(
            shouldInterceptRequest: (request) async {
              if (kDebugMode) {
                print(request);
              }
              return null;
            },
          ),
        );
      }
    }

    await browser.openUrlRequest(
      urlRequest: URLRequest(url: WebUri(selectedUrl)),
      settings: InAppBrowserClassSettings(
        webViewSettings: InAppWebViewSettings(
          useShouldOverrideUrlLoading: true,
          useOnLoadResource: true,
        ),
        browserSettings: InAppBrowserSettings(
          hideUrlBar: true,
          hideToolbarTop: GetPlatform.isAndroid,
        ),
      ),
    );
  }

  String _buildIosPaymentReturnUrl() {
    return Uri(
      scheme: AppConstants.customerPaymentReturnScheme,
      host: 'payment-return',
      path: '/order',
      queryParameters: {
        'id': widget.orderModel.id.toString(),
        'contact_number': widget.contactNumber,
        'create_account': widget.createAccount.toString(),
        'guest_id': widget.createAccount
            ? (widget.createUserId?.toString() ?? widget.guestId)
            : widget.guestId,
      },
    ).toString();
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        _exitApp().then((value) => value!);
      },
      child: Scaffold(
        backgroundColor: Theme.of(context).primaryColor,
        appBar: CustomAppBar(
          title: 'payment'.tr,
          onBackPressed: () => _exitApp(),
        ),
        body: Center(
          child: SizedBox(
            width: Dimensions.webMaxWidth,
            child: Stack(
              children: [
                _isLoading
                    ? Center(
                        child: CircularProgressIndicator(
                          valueColor: AlwaysStoppedAnimation<Color>(
                            Theme.of(context).primaryColor,
                          ),
                        ),
                      )
                    : const SizedBox.shrink(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<bool?> _exitApp() async {
    if ((widget.addFundUrl == null || widget.addFundUrl!.isEmpty) &&
        (widget.subscriptionUrl == '' && widget.subscriptionUrl!.isEmpty)) {
      return Get.dialog(
        PaymentFailedDialog(
          orderID: widget.orderModel.id.toString(),
          orderAmount: widget.orderModel.orderAmount,
          maxCodOrderAmount: _maximumCodOrderAmount,
          orderType: widget.orderModel.orderType,
          isCashOnDelivery: widget.isCashOnDelivery,
          guestId: widget.createAccount
              ? widget.createUserId.toString()
              : widget.guestId,
        ),
      );
    } else {
      return Get.dialog(
        FundPaymentDialogWidget(
          isSubscription:
              widget.subscriptionUrl != null &&
              widget.subscriptionUrl!.isNotEmpty,
        ),
      );
    }
  }
}

class MyInAppBrowser extends InAppBrowser {
  final String orderID;
  final String? orderType;
  final double? orderAmount;
  final double? maxCodOrderAmount;
  final bool isCashOnDelivery;
  final String? addFundUrl;
  final String? subscriptionUrl;
  final String? contactNumber;
  final int? storeId;
  final bool createAccount;
  final String guestId;

  MyInAppBrowser({
    super.windowId,
    super.initialUserScripts,
    required this.orderID,
    required this.orderType,
    required this.orderAmount,
    required this.maxCodOrderAmount,
    required this.isCashOnDelivery,
    this.addFundUrl,
    this.subscriptionUrl,
    this.contactNumber,
    this.storeId,
    required this.createAccount,
    required this.guestId,
  });

  bool _canRedirect = true;
  bool _handledRedirect = false;

  @override
  Future onBrowserCreated() async {
    if (kDebugMode) {
      print("\n\nBrowser Created!\n\n");
    }
  }

  @override
  Future onLoadStart(url) async {
    if (kDebugMode) {
      print("\n\nStarted: $url\n\n");
    }
    _handlePaymentRedirect(url.toString());
  }

  @override
  Future onLoadStop(url) async {
    pullToRefreshController?.endRefreshing();
    if (kDebugMode) {
      print("\n\nStopped: $url\n\n");
    }
    _handlePaymentRedirect(url.toString());
  }

  // @override
  // Future<ServerTrustAuthResponse?>? onReceivedServerTrustAuthRequest(URLAuthenticationChallenge challenge) async {
  //   if (kDebugMode) {
  //     print("\n\n onReceivedServerTrustAuthRequest: ${challenge.toString()}\n\n");
  //   }
  //   return ServerTrustAuthResponse(action: ServerTrustAuthResponseAction.PROCEED);
  // }
  //
  // @override
  // Future<ShouldAllowDeprecatedTLSAction?>? shouldAllowDeprecatedTLS(URLAuthenticationChallenge challenge) async {
  //   if (kDebugMode) {
  //     print("\n\n shouldAllowDeprecatedTLS: ${challenge.protectionSpace.host}\n\n");
  //   }
  //   return ShouldAllowDeprecatedTLSAction.ALLOW;
  // }

  @override
  void onLoadError(url, code, message) {
    pullToRefreshController?.endRefreshing();
    if (kDebugMode) {
      print("Can't load [$url] Error: $message");
    }
  }

  @override
  void onProgressChanged(progress) {
    if (progress == 100) {
      pullToRefreshController?.endRefreshing();
    }
    if (kDebugMode) {
      print("Progress: $progress");
    }
  }

  @override
  void onExit() {
    if (kDebugMode) {
      print("\n\nBrowser closed!\n\n");
    }
    if (!_handledRedirect && _isOrderPayment()) {
      _handledRedirect = true;
      Future.microtask(_resolveClosedOrderPayment);
    }
  }

  void _handlePaymentRedirect(String url) {
    if (_handleOrderReturnUrl(url)) {
      return;
    }

    final bool terminalUrl = _isTerminalUrl(url);
    if (terminalUrl) {
      _handledRedirect = true;
    }

    Get.find<OrderController>().paymentRedirect(
      url: url,
      canRedirect: _canRedirect,
      onClose: () => close(),
      addFundUrl: addFundUrl,
      orderID: orderID,
      contactNumber: contactNumber,
      storeId: storeId,
      subscriptionUrl: subscriptionUrl,
      createAccount: createAccount,
      guestId: guestId,
    );

    if (terminalUrl) {
      _canRedirect = false;
    }
  }

  bool _handleOrderReturnUrl(String url) {
    if (!_isOrderPayment()) {
      return false;
    }

    final String? status = _extractOrderPaymentStatus(url);
    if (status == null) {
      return false;
    }

    if (_handledRedirect) {
      return true;
    }

    _handledRedirect = true;
    _canRedirect = false;
    close();
    _navigateOrderPaymentResult(status);
    return true;
  }

  String? _extractOrderPaymentStatus(String url) {
    final Uri? uri = Uri.tryParse(url);

    if (uri != null &&
        uri.scheme == AppConstants.customerPaymentReturnScheme &&
        uri.host == 'payment-return') {
      return _normalizePaymentStatus(
        _firstNonEmptyQueryValue(uri, 'status') ??
            _firstNonEmptyQueryValue(uri, 'flag'),
      );
    }

    final String baseUrl = AppConstants.baseUrl;
    if (url.startsWith('$baseUrl/payment-success')) {
      return 'success';
    }
    if (url.startsWith('$baseUrl/payment-fail')) {
      return 'fail';
    }
    if (url.startsWith('$baseUrl/payment-cancel')) {
      return 'cancel';
    }

    return null;
  }

  String? _firstNonEmptyQueryValue(Uri uri, String key) {
    final List<String>? values = uri.queryParametersAll[key];
    if (values == null || values.isEmpty) {
      return null;
    }
    for (final String value in values.reversed) {
      if (value.isNotEmpty) {
        return value;
      }
    }
    return null;
  }

  String? _normalizePaymentStatus(String? status) {
    switch (status?.toLowerCase()) {
      case 'success':
      case 'paid':
        return 'success';
      case 'fail':
      case 'failed':
      case 'failure':
        return 'fail';
      case 'cancel':
      case 'canceled':
      case 'cancelled':
        return 'cancel';
    }
    return null;
  }

  void _navigateOrderPaymentResult(String status) {
    Future.microtask(() {
      if (!Get.currentRoute.startsWith(RouteHelper.payment)) {
        return;
      }
      if (status == 'success') {
        Get.offNamed(
          RouteHelper.getOrderSuccessRoute(
            orderID,
            contactNumber,
            createAccount: createAccount,
            guestId: guestId,
          ),
        );
      } else {
        Get.offNamed(
          RouteHelper.getDigitalPaymentFailedScreen(
            orderID,
            createAccount: createAccount,
          ),
        );
      }
    });
  }

  Future<void> _resolveClosedOrderPayment() async {
    if (!Get.currentRoute.startsWith(RouteHelper.payment)) {
      return;
    }

    final OrderController orderController = Get.find<OrderController>();
    for (int attempt = 0; attempt < 3; attempt++) {
      await orderController.trackOrder(
        orderID,
        null,
        false,
        contactNumber: contactNumber,
      );
      final OrderModel? order = orderController.trackModel;

      if (order != null && _isPaidOrder(order)) {
        _navigateOrderPaymentResult('success');
        return;
      }

      if (order != null &&
          (order.orderStatus == 'failed' || order.orderStatus == 'canceled')) {
        _navigateOrderPaymentResult('fail');
        return;
      }

      if (attempt < 2) {
        await Future.delayed(const Duration(milliseconds: 800));
      }
    }

    _navigateOrderPaymentResult('fail');
  }

  bool _isPaidOrder(OrderModel order) {
    return order.paymentStatus == 'paid' ||
        order.paymentMethod == 'cash_on_delivery' ||
        order.paymentMethod == 'partial_payment' ||
        order.paymentMethod == 'wallet';
  }

  bool _isTerminalUrl(String url) {
    final String baseUrl = AppConstants.baseUrl;
    final bool forSubscription =
        subscriptionUrl != null &&
        subscriptionUrl!.isNotEmpty &&
        (addFundUrl == null || addFundUrl!.isEmpty);

    if (forSubscription) {
      return url.startsWith('$baseUrl/subscription-success') ||
          url.startsWith('$baseUrl/subscription-fail') ||
          url.startsWith('$baseUrl/subscription-cancel');
    }

    return url.startsWith('$baseUrl/payment-success') ||
        url.startsWith('$baseUrl/payment-fail') ||
        url.startsWith('$baseUrl/payment-cancel');
  }

  bool _isOrderPayment() {
    return (addFundUrl == null || addFundUrl!.isEmpty) &&
        (subscriptionUrl == null || subscriptionUrl!.isEmpty);
  }

  @override
  Future<NavigationActionPolicy> shouldOverrideUrlLoading(
    navigationAction,
  ) async {
    if (kDebugMode) {
      print("\n\nOverride ${navigationAction.request.url}\n\n");
    }
    if (_handleOrderReturnUrl(navigationAction.request.url.toString())) {
      return NavigationActionPolicy.CANCEL;
    }
    return NavigationActionPolicy.ALLOW;
  }

  @override
  void onLoadResource(resource) {
    if (kDebugMode) {
      print(
        "Started at: ${resource.startTime}ms ---> duration: ${resource.duration}ms ${resource.url ?? ''}",
      );
    }
  }

  @override
  void onConsoleMessage(consoleMessage) {
    if (kDebugMode) {
      print("""
    console output:
      message: ${consoleMessage.message}
      messageLevel: ${consoleMessage.messageLevel.toValue()}
   """);
    }
  }
}
