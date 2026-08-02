import 'dart:async';
import 'dart:collection';
import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:sixam_mart/api/api_client.dart';
import 'package:sixam_mart/common/widgets/custom_button.dart';
import 'package:sixam_mart/common/widgets/custom_snackbar.dart';
import 'package:sixam_mart/features/checkout/widgets/payment_failed_dialog.dart';
import 'package:sixam_mart/features/location/domain/models/zone_response_model.dart';
import 'package:sixam_mart/features/order/domain/models/order_model.dart';
import 'package:sixam_mart/features/payment/domain/models/keepz_payment_option.dart';
import 'package:sixam_mart/features/splash/controllers/splash_controller.dart';
import 'package:sixam_mart/helper/address_helper.dart';
import 'package:sixam_mart/helper/route_helper.dart';
import 'package:sixam_mart/util/app_constants.dart';
import 'package:sixam_mart/util/dimensions.dart';
import 'package:sixam_mart/util/styles.dart';
import 'package:url_launcher/url_launcher.dart';

class KeepzNativePaymentScreen extends StatefulWidget {
  final OrderModel orderModel;
  final bool isCashOnDelivery;
  final String paymentMethod;
  final String guestId;
  final String contactNumber;
  final bool createAccount;
  final int? createUserId;
  final String? keepzMethodKey;

  const KeepzNativePaymentScreen({
    super.key,
    required this.orderModel,
    required this.isCashOnDelivery,
    required this.paymentMethod,
    required this.guestId,
    required this.contactNumber,
    this.createAccount = false,
    this.createUserId,
    this.keepzMethodKey,
  });

  @override
  State<KeepzNativePaymentScreen> createState() =>
      _KeepzNativePaymentScreenState();
}

class KeepzPaymentLauncher {
  static Future<String?> show({
    required OrderModel orderModel,
    required bool isCashOnDelivery,
    required String paymentMethod,
    required String guestId,
    required String contactNumber,
    required bool createAccount,
    int? createUserId,
    String? keepzMethodKey,
    Future<void> Function()? onPaymentSuccess,
  }) async {
    final BuildContext context = Get.overlayContext ?? Get.context!;
    final String? status = await showModalBottomSheet<String>(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      useSafeArea: true,
      isDismissible: false,
      enableDrag: false,
      sheetAnimationStyle: const AnimationStyle(
        duration: Duration(milliseconds: 320),
        reverseDuration: Duration(milliseconds: 220),
      ),
      builder: (BuildContext context) => _KeepzBottomSheetFlow(
        orderModel: orderModel,
        isCashOnDelivery: isCashOnDelivery,
        paymentMethod: paymentMethod,
        guestId: guestId,
        contactNumber: contactNumber,
        createAccount: createAccount,
        createUserId: createUserId,
        keepzMethodKey: keepzMethodKey,
      ),
    );

    if (status == 'superseded') {
      return null;
    }

    if (status != null) {
      if (status == 'success' && onPaymentSuccess != null) {
        await onPaymentSuccess();
      }
      _navigateOrderPaymentResult(
        status: status,
        orderId: orderModel.id.toString(),
        contactNumber: contactNumber,
        createAccount: createAccount,
        guestId: guestId,
      );
    }
    return status;
  }

  static Future<String?> _readClosedOrderPaymentStatus({
    required String orderId,
    required String guestId,
  }) async {
    final ApiClient apiClient = Get.find<ApiClient>();
    final String guestQuery = guestId.isNotEmpty
        ? '?guest_id=${Uri.encodeQueryComponent(guestId)}'
        : '';
    const List<int> retryDelaysMs = <int>[0, 500, 900, 1400];

    for (final int delayMs in retryDelaysMs) {
      if (delayMs > 0) {
        await Future<void>.delayed(Duration(milliseconds: delayMs));
      }

      final response = await apiClient.getData(
        '/api/v1/customer/order-payment/$orderId/status$guestQuery',
        handleError: false,
      );
      final dynamic body = response.body;

      if (body is Map) {
        final String state = body['state']?.toString().toLowerCase() ?? '';
        final String paymentStatus =
            body['payment_status']?.toString().toLowerCase() ?? '';

        if (state == 'paid' || paymentStatus == 'paid') {
          return 'success';
        }

        if (state == 'superseded') {
          return 'superseded';
        }

        if (state == 'terminal' || state == 'ready' || state == 'absent') {
          return 'fail';
        }
      }
    }

    return null;
  }

  static void _navigateOrderPaymentResult({
    required String status,
    required String orderId,
    required String contactNumber,
    required bool createAccount,
    required String guestId,
  }) {
    if (Get.isBottomSheetOpen == true) {
      Get.back();
    }

    if (status == 'superseded') {
      return;
    }

    if (status == 'success') {
      Get.offNamed(
        RouteHelper.getOrderSuccessRoute(
          orderId,
          contactNumber,
          createAccount: createAccount,
          guestId: guestId,
        ),
      );
      return;
    }

    Get.offNamed(
      RouteHelper.getDigitalPaymentFailedScreen(
        orderId,
        createAccount: createAccount,
      ),
    );
  }
}

class _KeepzBottomSheetFlow extends StatefulWidget {
  final OrderModel orderModel;
  final bool isCashOnDelivery;
  final String paymentMethod;
  final String guestId;
  final String contactNumber;
  final bool createAccount;
  final int? createUserId;
  final String? keepzMethodKey;

  const _KeepzBottomSheetFlow({
    required this.orderModel,
    required this.isCashOnDelivery,
    required this.paymentMethod,
    required this.guestId,
    required this.contactNumber,
    required this.createAccount,
    required this.createUserId,
    required this.keepzMethodKey,
  });

  @override
  State<_KeepzBottomSheetFlow> createState() => _KeepzBottomSheetFlowState();
}

class _KeepzBottomSheetFlowState extends State<_KeepzBottomSheetFlow>
    with WidgetsBindingObserver {
  String? _hostedUrl;
  String? _statusMessage;
  bool _isLoading = true;
  bool _awaitingExternalPayment = false;
  bool _checkingStatus = false;

  KeepzPaymentOption get _selectedOption =>
      KeepzPaymentOption.fromKey(widget.keepzMethodKey) ??
      KeepzPaymentOption.defaultOption;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      unawaited(_startSelectedPayment());
    });
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed && _awaitingExternalPayment) {
      unawaited(_resolveExternalPayment());
    }
  }

  Future<void> _startSelectedPayment() async {
    final KeepzPaymentOption option = _selectedOption;

    try {
      final _KeepzIntent intent = await _fetchIntent(
        flow: option.flow,
        provider: option.provider,
      );

      final bool shouldTryExternal =
          option.externalFirst && intent.action == 'external_non_browser';
      if (shouldTryExternal && await _openExternalBankApp(intent.url)) {
        if (!mounted) {
          return;
        }
        setState(() {
          _isLoading = false;
          _awaitingExternalPayment = true;
          _statusMessage =
              'გადახდის დასრულების შემდეგ დაბრუნდი აპში და სტატუსი გადამოწმდება.';
        });
        return;
      }

      if (mounted) {
        setState(() {
          _isLoading = false;
          _hostedUrl = intent.url;
        });
      }
    } catch (error) {
      if (mounted) {
        setState(() {
          _isLoading = false;
          _statusMessage = _readableError(error);
        });
      }
    }
  }

  Future<_KeepzIntent> _fetchIntent({
    required String flow,
    required String provider,
  }) async {
    final String customerId = widget.orderModel.userId == 0
        ? widget.guestId
        : widget.orderModel.userId.toString();

    final Map<String, String> queryParameters = <String, String>{
      'customer_id': customerId,
      'order_id': widget.orderModel.id.toString(),
      'payment_method': widget.paymentMethod,
      'payment_platform': 'app',
      'keepz_flow': flow,
    };

    if (provider.isNotEmpty) {
      queryParameters['keepz_provider'] = provider;
    }

    if (GetPlatform.isIOS) {
      queryParameters['callback'] = _buildIosPaymentReturnUrl();
    }

    final Uri uri = Uri.parse(
      '${AppConstants.baseUrl}/payment-mobile/keepz-intent',
    ).replace(queryParameters: queryParameters);

    final http.Response response = await http.get(uri);
    dynamic decodedBody;
    try {
      decodedBody = jsonDecode(response.body);
    } catch (_) {
      decodedBody = null;
    }

    if (response.statusCode != 200 || decodedBody is! Map<String, dynamic>) {
      throw _extractBackendMessage(decodedBody);
    }

    return _KeepzIntent.fromJson(decodedBody);
  }

  Future<bool> _openExternalBankApp(String url) async {
    final Uri? uri = Uri.tryParse(url);
    if (uri == null) {
      return false;
    }

    try {
      return await launchUrl(
        uri,
        mode: LaunchMode.externalNonBrowserApplication,
      );
    } catch (_) {
      return false;
    }
  }

  String _buildIosPaymentReturnUrl() {
    return Uri(
      scheme: AppConstants.customerPaymentReturnScheme,
      host: 'payment-return',
      path: '/order',
      queryParameters: <String, String>{
        'id': widget.orderModel.id.toString(),
        'contact_number': widget.contactNumber,
        'create_account': widget.createAccount.toString(),
        'guest_id': widget.createAccount
            ? (widget.createUserId?.toString() ?? widget.guestId)
            : widget.guestId,
      },
    ).toString();
  }

  Future<void> _resolveExternalPayment() async {
    if (_checkingStatus) {
      return;
    }

    setState(() {
      _checkingStatus = true;
    });

    final String? status =
        await KeepzPaymentLauncher._readClosedOrderPaymentStatus(
          orderId: widget.orderModel.id.toString(),
          guestId: widget.guestId,
        );

    if (!mounted) {
      return;
    }

    if (status != null) {
      Navigator.of(context).pop(status);
      return;
    }

    showCustomSnackBar(
      'გადახდა ჯერ არ დადასტურებულა. სტატუსი მოგვიანებით გადაამოწმე.',
    );

    if (mounted) {
      setState(() {
        _checkingStatus = false;
      });
    }
  }

  String _extractBackendMessage(dynamic decodedBody) {
    if (decodedBody is Map<String, dynamic>) {
      if ((decodedBody['message'] as String?)?.isNotEmpty ?? false) {
        return decodedBody['message'] as String;
      }

      final dynamic errors = decodedBody['errors'];
      if (errors is List && errors.isNotEmpty) {
        final dynamic firstError = errors.first;
        if (firstError is Map<String, dynamic> &&
            ((firstError['message'] as String?)?.isNotEmpty ?? false)) {
          return firstError['message'] as String;
        }
      }
    }

    return 'Keepz გადახდის ინიციალიზაცია ვერ მოხერხდა';
  }

  String _readableError(dynamic error) {
    if (error is String && error.isNotEmpty) {
      return error;
    }

    return 'გადახდა ვერ შესრულდა';
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 220),
      switchInCurve: Curves.easeOutCubic,
      switchOutCurve: Curves.easeInCubic,
      transitionBuilder: (Widget child, Animation<double> animation) {
        return FadeTransition(opacity: animation, child: child);
      },
      child: _hostedUrl != null
          ? _KeepzWebViewSheet(
              key: const ValueKey<String>('keepz-webview'),
              initialUrl: _hostedUrl!,
              resolvePaymentStatus: () =>
                  KeepzPaymentLauncher._readClosedOrderPaymentStatus(
                    orderId: widget.orderModel.id.toString(),
                    guestId: widget.guestId,
                  ),
            )
          : _KeepzLoadingSheet(
              key: const ValueKey<String>('keepz-loading'),
              option: _selectedOption,
              isLoading: _isLoading || _checkingStatus,
              statusMessage: _statusMessage,
              onRetry: () {
                setState(() {
                  _isLoading = true;
                  _statusMessage = null;
                });
                unawaited(_startSelectedPayment());
              },
              onCheckStatus: _resolveExternalPayment,
            ),
    );
  }
}

class _KeepzNativePaymentScreenState extends State<KeepzNativePaymentScreen>
    with WidgetsBindingObserver {
  String? _loadingKey;
  String? _statusMessage;
  bool _awaitingExternalPayment = false;
  bool _checkingStatus = false;
  bool _autoStarted = false;
  bool _preparingSheetOpen = false;
  double? _maximumCodOrderAmount;

  KeepzPaymentOption get _selectedOption =>
      KeepzPaymentOption.fromKey(widget.keepzMethodKey) ??
      KeepzPaymentOption.defaultOption;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _initData();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      unawaited(_startSelectedPayment());
    });
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed && _awaitingExternalPayment) {
      unawaited(_resolveClosedOrderPayment());
    }
  }

  void _initData() {
    for (final ZoneData zData
        in AddressHelper.getUserAddressFromSharedPref()?.zoneData ??
            <ZoneData>[]) {
      for (final Modules module in zData.modules ?? <Modules>[]) {
        if (module.id == Get.find<SplashController>().module?.id) {
          _maximumCodOrderAmount = module.pivot?.maximumCodOrderAmount;
          break;
        }
      }
    }
  }

  Future<void> _startSelectedPayment() async {
    if (_autoStarted || !mounted) {
      return;
    }

    _autoStarted = true;
    final KeepzPaymentOption option = _selectedOption;

    if (option.requiresPersonalNumber) {
      final String? personalNumber = await _requestInstallmentPersonalNumber();
      if (!mounted) {
        return;
      }
      if (personalNumber == null || personalNumber.isEmpty) {
        setState(() {
          _statusMessage =
              'გადახდა არ დაწყებულა. გასაგრძელებლად გახსენი გადახდა ხელახლა.';
        });
        return;
      }

      await _runPaymentAction(
        loadingKey: option.key,
        flow: option.flow,
        provider: option.provider,
        personalNumber: personalNumber,
        externalFirst: option.externalFirst,
      );
      return;
    }

    await _runPaymentAction(
      loadingKey: option.key,
      flow: option.flow,
      provider: option.provider,
      externalFirst: option.externalFirst,
    );
  }

  Future<void> _retrySelectedPayment() async {
    _autoStarted = false;
    await _startSelectedPayment();
  }

  Future<void> _runPaymentAction({
    required String loadingKey,
    required String flow,
    required String provider,
    required bool externalFirst,
    String? personalNumber,
  }) async {
    if (_loadingKey != null) {
      return;
    }

    setState(() {
      _loadingKey = loadingKey;
      _statusMessage = null;
    });

    await _openPreparingBottomSheet();

    try {
      final _KeepzIntent intent = await _fetchIntent(
        flow: flow,
        provider: provider,
        personalNumber: personalNumber,
      );

      final bool shouldTryExternal =
          externalFirst && intent.action == 'external_non_browser';
      if (shouldTryExternal && await _openExternalBankApp(intent.url)) {
        await _closePreparingBottomSheet();
        if (!mounted) {
          return;
        }
        setState(() {
          _awaitingExternalPayment = true;
          _statusMessage =
              'გადახდის დასრულების შემდეგ დაბრუნდი აპში და სტატუსი გადამოწმდება.';
        });
        return;
      }

      await _closePreparingBottomSheet();
      await _openHostedBottomSheet(intent.url);
    } catch (error) {
      await _closePreparingBottomSheet();
      showCustomSnackBar(_readableError(error));
    } finally {
      if (mounted) {
        setState(() {
          _loadingKey = null;
        });
      }
    }
  }

  Future<void> _openPreparingBottomSheet() async {
    if (_preparingSheetOpen || !mounted) {
      return;
    }

    _preparingSheetOpen = true;
    unawaited(
      Get.bottomSheet<void>(
        _KeepzPreparingSheet(option: _selectedOption),
        backgroundColor: Colors.transparent,
        isDismissible: false,
        enableDrag: false,
        isScrollControlled: true,
      ).whenComplete(() {
        _preparingSheetOpen = false;
      }),
    );

    await Future<void>.delayed(const Duration(milliseconds: 120));
  }

  Future<void> _closePreparingBottomSheet() async {
    if (_preparingSheetOpen && Get.isBottomSheetOpen == true) {
      Get.back();
      await Future<void>.delayed(const Duration(milliseconds: 120));
    }
  }

  Future<_KeepzIntent> _fetchIntent({
    required String flow,
    required String provider,
    String? personalNumber,
  }) async {
    final String customerId = widget.orderModel.userId == 0
        ? widget.guestId
        : widget.orderModel.userId.toString();

    final Map<String, String> queryParameters = <String, String>{
      'customer_id': customerId,
      'order_id': widget.orderModel.id.toString(),
      'payment_method': widget.paymentMethod,
      'payment_platform': 'app',
      'keepz_flow': flow,
      'keepz_provider': provider,
    };

    if (personalNumber != null && personalNumber.isNotEmpty) {
      queryParameters['personal_number'] = personalNumber;
      queryParameters['is_foreign'] = 'false';
    }

    if (GetPlatform.isIOS) {
      queryParameters['callback'] = _buildIosPaymentReturnUrl();
    }

    final Uri uri = Uri.parse(
      '${AppConstants.baseUrl}/payment-mobile/keepz-intent',
    ).replace(queryParameters: queryParameters);

    final http.Response response = await http.get(uri);
    dynamic decodedBody;
    try {
      decodedBody = jsonDecode(response.body);
    } catch (_) {
      decodedBody = null;
    }

    if (response.statusCode != 200 || decodedBody is! Map<String, dynamic>) {
      throw _extractBackendMessage(decodedBody);
    }

    return _KeepzIntent.fromJson(decodedBody);
  }

  Future<bool> _openExternalBankApp(String url) async {
    final Uri? uri = Uri.tryParse(url);
    if (uri == null) {
      return false;
    }

    try {
      return await launchUrl(
        uri,
        mode: LaunchMode.externalNonBrowserApplication,
      );
    } catch (_) {
      return false;
    }
  }

  Future<void> _openHostedBottomSheet(String url) async {
    if (!mounted) {
      return;
    }

    final String? status = await showModalBottomSheet<String>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      backgroundColor: Colors.transparent,
      isDismissible: false,
      enableDrag: false,
      builder: (BuildContext context) {
        return _KeepzWebViewSheet(
          initialUrl: url,
          resolvePaymentStatus: () =>
              KeepzPaymentLauncher._readClosedOrderPaymentStatus(
                orderId: widget.orderModel.id.toString(),
                guestId: widget.guestId,
              ),
        );
      },
    );

    if (!mounted) {
      return;
    }

    if (status != null) {
      _navigateOrderPaymentResult(status);
    }
  }

  Future<String?> _requestInstallmentPersonalNumber() {
    final TextEditingController controller = TextEditingController();

    return showModalBottomSheet<String>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setSheetState) {
            final String value = controller.text.trim();
            final bool isValid = value.length == 9 || value.length == 11;

            return Padding(
              padding: EdgeInsets.only(
                bottom: MediaQuery.of(context).viewInsets.bottom,
              ),
              child: Container(
                padding: const EdgeInsets.fromLTRB(20, 12, 20, 20),
                decoration: BoxDecoration(
                  color: Theme.of(context).cardColor,
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(Dimensions.radiusLarge),
                  ),
                ),
                child: SafeArea(
                  top: false,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Center(
                        child: Container(
                          width: 42,
                          height: 5,
                          decoration: BoxDecoration(
                            color: Theme.of(
                              context,
                            ).disabledColor.withValues(alpha: 0.35),
                            borderRadius: BorderRadius.circular(99),
                          ),
                        ),
                      ),
                      const SizedBox(height: 18),
                      Text(
                        'დაყავი 4 ნაწილად',
                        style: robotoBold.copyWith(
                          fontSize: Dimensions.fontSizeLarge,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'გაგრძელებისთვის შეიყვანე პირადი ნომერი.',
                        style: robotoRegular.copyWith(
                          color: Theme.of(context).hintColor,
                        ),
                      ),
                      const SizedBox(height: 16),
                      TextField(
                        controller: controller,
                        keyboardType: TextInputType.number,
                        inputFormatters: <TextInputFormatter>[
                          FilteringTextInputFormatter.digitsOnly,
                          LengthLimitingTextInputFormatter(11),
                        ],
                        decoration: InputDecoration(
                          labelText: 'პირადი ნომერი',
                          hintText: '9 ან 11 ციფრი',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(
                              Dimensions.radiusSmall,
                            ),
                          ),
                        ),
                        onChanged: (_) => setSheetState(() {}),
                      ),
                      const SizedBox(height: 16),
                      Row(
                        children: <Widget>[
                          Expanded(
                            child: OutlinedButton(
                              onPressed: () => Navigator.of(context).pop(),
                              child: const Text('დახურვა'),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: CustomButton(
                              buttonText: 'გაგრძელება',
                              onPressed: isValid
                                  ? () => Navigator.of(context).pop(value)
                                  : null,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        );
      },
    ).whenComplete(controller.dispose);
  }

  String _buildIosPaymentReturnUrl() {
    return Uri(
      scheme: AppConstants.customerPaymentReturnScheme,
      host: 'payment-return',
      path: '/order',
      queryParameters: <String, String>{
        'id': widget.orderModel.id.toString(),
        'contact_number': widget.contactNumber,
        'create_account': widget.createAccount.toString(),
        'guest_id': widget.createAccount
            ? (widget.createUserId?.toString() ?? widget.guestId)
            : widget.guestId,
      },
    ).toString();
  }

  Future<void> _resolveClosedOrderPayment() async {
    if (_checkingStatus || !Get.currentRoute.startsWith(RouteHelper.payment)) {
      return;
    }

    setState(() {
      _checkingStatus = true;
    });

    final String? status =
        await KeepzPaymentLauncher._readClosedOrderPaymentStatus(
          orderId: widget.orderModel.id.toString(),
          guestId: widget.guestId,
        );

    if (!mounted) {
      return;
    }

    if (status == 'success' || status == 'fail') {
      _navigateOrderPaymentResult(status!);
      return;
    }

    if (status == 'superseded') {
      setState(() {
        _checkingStatus = false;
        _statusMessage =
            'გადახდის მეთოდი შეიცვალა. წინა საბანკო გადახდა აღარ არის აქტიური.';
      });
      return;
    }

    setState(() {
      _checkingStatus = false;
      _statusMessage =
          'გადახდა ჯერ არ დადასტურებულა. საჭიროების შემთხვევაში სტატუსი ხელახლა გადაამოწმე.';
    });
  }

  void _navigateOrderPaymentResult(String status) {
    if (!Get.currentRoute.startsWith(RouteHelper.payment)) {
      return;
    }

    if (status == 'superseded') {
      if (mounted) {
        setState(() {
          _checkingStatus = false;
          _statusMessage =
              'გადახდის მეთოდი შეიცვალა. წინა საბანკო გადახდა აღარ არის აქტიური.';
        });
      }
      return;
    }

    if (status == 'success') {
      Get.offNamed(
        RouteHelper.getOrderSuccessRoute(
          widget.orderModel.id.toString(),
          widget.contactNumber,
          createAccount: widget.createAccount,
          guestId: widget.guestId,
        ),
      );
      return;
    }

    Get.offNamed(
      RouteHelper.getDigitalPaymentFailedScreen(
        widget.orderModel.id.toString(),
        createAccount: widget.createAccount,
      ),
    );
  }

  String _extractBackendMessage(dynamic decodedBody) {
    if (decodedBody is Map<String, dynamic>) {
      if ((decodedBody['message'] as String?)?.isNotEmpty ?? false) {
        return decodedBody['message'] as String;
      }

      final dynamic errors = decodedBody['errors'];
      if (errors is List && errors.isNotEmpty) {
        final dynamic firstError = errors.first;
        if (firstError is Map<String, dynamic> &&
            ((firstError['message'] as String?)?.isNotEmpty ?? false)) {
          return firstError['message'] as String;
        }
      }
    }

    return 'Keepz გადახდის ინიციალიზაცია ვერ მოხერხდა';
  }

  String _readableError(dynamic error) {
    if (error is String && error.isNotEmpty) {
      return error;
    }

    return 'გადახდა ვერ შესრულდა';
  }

  Future<bool?> _exitApp() {
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
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (bool didPop, dynamic result) async {
        await _exitApp();
      },
      child: Scaffold(
        backgroundColor: Theme.of(context).cardColor,
        body: SafeArea(
          child: Center(
            child: _statusMessage == null
                ? const SizedBox.shrink()
                : Padding(
                    padding: const EdgeInsets.all(Dimensions.paddingSizeLarge),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: <Widget>[
                        _StatusCard(
                          message: _statusMessage!,
                          checkingStatus: _checkingStatus,
                          onCheckStatus: _resolveClosedOrderPayment,
                        ),
                        const SizedBox(height: Dimensions.paddingSizeDefault),
                        CustomButton(
                          buttonText: 'გადახდის გახსნა',
                          isLoading: _loadingKey != null,
                          onPressed: _loadingKey == null
                              ? _retrySelectedPayment
                              : null,
                        ),
                      ],
                    ),
                  ),
          ),
        ),
      ),
    );
  }
}

class _KeepzPreparingSheet extends StatelessWidget {
  final KeepzPaymentOption option;

  const _KeepzPreparingSheet({required this.option});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,
      child: Container(
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 20),
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
          borderRadius: const BorderRadius.vertical(
            top: Radius.circular(Dimensions.radiusLarge),
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Container(
              width: 42,
              height: 5,
              decoration: BoxDecoration(
                color: Theme.of(context).disabledColor.withValues(alpha: 0.35),
                borderRadius: BorderRadius.circular(99),
              ),
            ),
            const SizedBox(height: 18),
            Row(
              children: <Widget>[
                Container(
                  width: 48,
                  height: 48,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: Theme.of(
                      context,
                    ).primaryColor.withValues(alpha: 0.08),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Image.asset(
                    option.iconAsset,
                    width: 34,
                    height: 34,
                    fit: BoxFit.contain,
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Text(
                        'გადახდის მეთოდი',
                        style: robotoRegular.copyWith(
                          color: Theme.of(context).hintColor,
                          fontSize: Dimensions.fontSizeSmall,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        option.title,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: robotoSemiBold.copyWith(
                          fontSize: Dimensions.fontSizeDefault,
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(
                  width: 24,
                  height: 24,
                  child: CircularProgressIndicator(
                    strokeWidth: 2.4,
                    valueColor: AlwaysStoppedAnimation<Color>(
                      Theme.of(context).primaryColor,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _KeepzLoadingSheet extends StatelessWidget {
  final KeepzPaymentOption option;
  final bool isLoading;
  final String? statusMessage;
  final VoidCallback onRetry;
  final VoidCallback onCheckStatus;

  const _KeepzLoadingSheet({
    super.key,
    required this.option,
    required this.isLoading,
    required this.statusMessage,
    required this.onRetry,
    required this.onCheckStatus,
  });

  @override
  Widget build(BuildContext context) {
    return FractionallySizedBox(
      heightFactor: 0.96,
      child: Container(
        clipBehavior: Clip.antiAlias,
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
          borderRadius: const BorderRadius.vertical(
            top: Radius.circular(Dimensions.radiusLarge),
          ),
        ),
        child: Column(
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 10, 6, 8),
              child: Row(
                children: <Widget>[
                  Icon(
                    Icons.lock_outline_rounded,
                    size: 20,
                    color: Theme.of(context).primaryColor,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'გადახდა',
                      style: robotoBold.copyWith(
                        fontSize: Dimensions.fontSizeDefault,
                      ),
                    ),
                  ),
                  IconButton(
                    onPressed: () => Navigator.of(context).pop(),
                    tooltip: 'დახურვა',
                    icon: const Icon(Icons.close_rounded),
                  ),
                ],
              ),
            ),
            Divider(
              height: 1,
              color: Theme.of(context).disabledColor.withValues(alpha: 0.18),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    Container(
                      width: 72,
                      height: 72,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Theme.of(
                          context,
                        ).primaryColor.withValues(alpha: 0.08),
                      ),
                      child: Icon(
                        Icons.credit_card_rounded,
                        size: 34,
                        color: Theme.of(context).primaryColor,
                      ),
                    ),
                    const SizedBox(height: 20),
                    Text(
                      option.title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: robotoSemiBold.copyWith(
                        fontSize: Dimensions.fontSizeLarge,
                      ),
                    ),
                    const SizedBox(height: 10),
                    if (isLoading) ...<Widget>[
                      SizedBox(
                        width: 26,
                        height: 26,
                        child: CircularProgressIndicator(
                          strokeWidth: 2.5,
                          valueColor: AlwaysStoppedAnimation<Color>(
                            Theme.of(context).primaryColor,
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        'გადახდის უსაფრთხო გვერდი იტვირთება',
                        textAlign: TextAlign.center,
                        style: robotoRegular.copyWith(
                          color: Theme.of(context).hintColor,
                        ),
                      ),
                    ],
                    if (statusMessage != null) ...<Widget>[
                      Text(
                        statusMessage!,
                        textAlign: TextAlign.center,
                        style: robotoRegular.copyWith(
                          color: Theme.of(context).textTheme.bodyLarge!.color,
                        ),
                      ),
                      const SizedBox(height: Dimensions.paddingSizeLarge),
                      Row(
                        children: <Widget>[
                          Expanded(
                            child: OutlinedButton(
                              onPressed: isLoading ? null : onCheckStatus,
                              child: const Text('სტატუსის შემოწმება'),
                            ),
                          ),
                          const SizedBox(width: Dimensions.paddingSizeSmall),
                          Expanded(
                            child: CustomButton(
                              buttonText: 'ხელახლა გახსნა',
                              isLoading: isLoading,
                              onPressed: isLoading ? null : onRetry,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _KeepzWebViewSheet extends StatefulWidget {
  final String initialUrl;
  final Future<String?> Function()? resolvePaymentStatus;

  const _KeepzWebViewSheet({
    super.key,
    required this.initialUrl,
    this.resolvePaymentStatus,
  });

  @override
  State<_KeepzWebViewSheet> createState() => _KeepzWebViewSheetState();
}

class _KeepzWebViewSheetState extends State<_KeepzWebViewSheet>
    with WidgetsBindingObserver {
  final GlobalKey _webViewKey = GlobalKey();
  InAppWebViewController? _controller;
  PullToRefreshController? _pullToRefreshController;
  bool _isLoading = true;
  bool _handledTerminalUrl = false;
  bool _externalAppOpened = false;
  bool _checkingReturnStatus = false;
  String? _loadError;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _pullToRefreshController =
        GetPlatform.isWeb ||
            !<TargetPlatform>{
              TargetPlatform.iOS,
              TargetPlatform.android,
            }.contains(defaultTargetPlatform)
        ? null
        : PullToRefreshController(
            onRefresh: () async {
              if (defaultTargetPlatform == TargetPlatform.android) {
                await _controller?.reload();
              } else {
                await _controller?.loadUrl(
                  urlRequest: URLRequest(url: await _controller?.getUrl()),
                );
              }
            },
          );
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed && _externalAppOpened) {
      unawaited(_resolvePaymentAfterExternalReturn());
    }
  }

  @override
  Widget build(BuildContext context) {
    return FractionallySizedBox(
      heightFactor: 0.96,
      child: Container(
        clipBehavior: Clip.antiAlias,
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
          borderRadius: const BorderRadius.vertical(
            top: Radius.circular(Dimensions.radiusLarge),
          ),
        ),
        child: Column(
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 10, 6, 8),
              child: Row(
                children: <Widget>[
                  Icon(
                    Icons.lock_outline_rounded,
                    size: 20,
                    color: Theme.of(context).primaryColor,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'გადახდა',
                      style: robotoBold.copyWith(
                        fontSize: Dimensions.fontSizeDefault,
                      ),
                    ),
                  ),
                  if (_checkingReturnStatus)
                    const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    ),
                  IconButton(
                    onPressed: () => Navigator.of(context).pop(),
                    tooltip: 'დახურვა',
                    icon: const Icon(Icons.close_rounded),
                  ),
                ],
              ),
            ),
            Expanded(
              child: Stack(
                children: <Widget>[
                  InAppWebView(
                    key: _webViewKey,
                    initialUrlRequest: URLRequest(
                      url: WebUri(widget.initialUrl),
                    ),
                    initialUserScripts: UnmodifiableListView<UserScript>([]),
                    pullToRefreshController: _pullToRefreshController,
                    initialSettings: InAppWebViewSettings(
                      isInspectable: kDebugMode,
                      useShouldOverrideUrlLoading: true,
                      mediaPlaybackRequiresUserGesture: false,
                      allowsInlineMediaPlayback: true,
                      useWideViewPort: true,
                      verticalScrollBarEnabled: true,
                      horizontalScrollBarEnabled: false,
                      supportZoom: false,
                      iframeAllow: 'camera; microphone',
                      iframeAllowFullscreen: true,
                    ),
                    onWebViewCreated: (InAppWebViewController controller) {
                      _controller = controller;
                    },
                    onLoadStart: (_, WebUri? url) {
                      _handleUrl(url?.toString());
                      if (mounted) {
                        setState(() {
                          _isLoading = true;
                          _loadError = null;
                        });
                      }
                    },
                    onLoadStop: (_, WebUri? url) {
                      _pullToRefreshController?.endRefreshing();
                      _handleUrl(url?.toString());
                      if (mounted) {
                        setState(() {
                          _isLoading = false;
                        });
                      }
                    },
                    shouldOverrideUrlLoading:
                        (
                          InAppWebViewController controller,
                          NavigationAction navigationAction,
                        ) async {
                          final WebUri? webUri = navigationAction.request.url;
                          final String? terminalStatus = _terminalStatus(
                            webUri?.toString(),
                          );
                          if (terminalStatus != null) {
                            _closeWithStatus(terminalStatus);
                            return NavigationActionPolicy.CANCEL;
                          }

                          final Uri? uri = Uri.tryParse(
                            webUri?.toString() ?? '',
                          );
                          if (uri != null &&
                              !<String>{
                                'http',
                                'https',
                                'file',
                                'chrome',
                                'data',
                                'javascript',
                                'about',
                              }.contains(uri.scheme)) {
                            bool launched = false;
                            try {
                              launched = await launchUrl(
                                uri,
                                mode: LaunchMode.externalApplication,
                              );
                              if (launched) {
                                _externalAppOpened = true;
                              }
                            } catch (_) {}

                            if (!launched) {
                              final Uri? fallback = _intentBrowserFallback(uri);
                              if (fallback != null) {
                                await controller.loadUrl(
                                  urlRequest: URLRequest(
                                    url: WebUri(fallback.toString()),
                                  ),
                                );
                              } else if (mounted) {
                                showCustomSnackBar(
                                  'შესაბამისი აპლიკაცია ვერ გაიხსნა',
                                );
                              }
                            }

                            return NavigationActionPolicy.CANCEL;
                          }

                          return NavigationActionPolicy.ALLOW;
                        },
                    onUpdateVisitedHistory: (_, WebUri? url, _) {
                      _handleUrl(url?.toString());
                    },
                    onReceivedError: (_, request, error) {
                      if (request.isForMainFrame == true) {
                        _setLoadError('გადახდის გვერდი ვერ ჩაიტვირთა');
                      }
                    },
                    onReceivedHttpError: (_, request, errorResponse) {
                      if (request.isForMainFrame == true) {
                        _setLoadError(
                          'გადახდის გვერდმა დააბრუნა შეცდომა (${errorResponse.statusCode})',
                        );
                      }
                    },
                    onProgressChanged: (_, int progress) {
                      if (progress == 100) {
                        _pullToRefreshController?.endRefreshing();
                      }
                    },
                    onConsoleMessage: (_, ConsoleMessage consoleMessage) {
                      if (kDebugMode) {
                        debugPrint(consoleMessage.message);
                      }
                    },
                  ),
                  if (_isLoading && _loadError == null)
                    Center(
                      child: CircularProgressIndicator(
                        valueColor: AlwaysStoppedAnimation<Color>(
                          Theme.of(context).primaryColor,
                        ),
                      ),
                    ),
                  if (_loadError != null)
                    Positioned.fill(
                      child: ColoredBox(
                        color: Theme.of(context).cardColor,
                        child: Center(
                          child: Padding(
                            padding: const EdgeInsets.all(
                              Dimensions.paddingSizeLarge,
                            ),
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: <Widget>[
                                Icon(
                                  Icons.cloud_off_outlined,
                                  size: 38,
                                  color: Theme.of(context).hintColor,
                                ),
                                const SizedBox(
                                  height: Dimensions.paddingSizeSmall,
                                ),
                                Text(
                                  _loadError!,
                                  textAlign: TextAlign.center,
                                  style: robotoMedium,
                                ),
                                const SizedBox(
                                  height: Dimensions.paddingSizeDefault,
                                ),
                                OutlinedButton.icon(
                                  onPressed: _retryPageLoad,
                                  icon: const Icon(Icons.refresh_rounded),
                                  label: const Text('ხელახლა ცდა'),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _handleUrl(String? url) {
    final String? status = _terminalStatus(url);
    if (status != null) {
      _closeWithStatus(status);
    }
  }

  Future<void> _resolvePaymentAfterExternalReturn() async {
    if (_checkingReturnStatus || widget.resolvePaymentStatus == null) {
      return;
    }

    _externalAppOpened = false;
    if (mounted) {
      setState(() {
        _checkingReturnStatus = true;
      });
    }

    String? status;
    try {
      await Future<void>.delayed(const Duration(milliseconds: 500));
      status = await widget.resolvePaymentStatus!.call();
    } catch (_) {
      status = null;
    }

    if (!mounted) {
      return;
    }

    setState(() {
      _checkingReturnStatus = false;
    });

    if (status != null) {
      _closeWithStatus(status);
    }
  }

  Uri? _intentBrowserFallback(Uri uri) {
    if (uri.scheme.toLowerCase() != 'intent') {
      return null;
    }

    final RegExpMatch? match = RegExp(
      r'S\.browser_fallback_url=([^;]+)',
    ).firstMatch(uri.toString());
    if (match == null) {
      return null;
    }

    final String fallbackUrl = Uri.decodeComponent(match.group(1)!);
    final Uri? fallback = Uri.tryParse(fallbackUrl);
    if (fallback == null ||
        fallback.scheme.toLowerCase() != 'https' ||
        fallback.host.isEmpty) {
      return null;
    }

    return fallback;
  }

  void _setLoadError(String message) {
    _pullToRefreshController?.endRefreshing();
    if (!mounted) {
      return;
    }

    setState(() {
      _isLoading = false;
      _loadError = message;
    });
  }

  Future<void> _retryPageLoad() async {
    if (mounted) {
      setState(() {
        _isLoading = true;
        _loadError = null;
      });
    }
    await _controller?.reload();
  }

  String? _terminalStatus(String? url) {
    if (url == null || url.isEmpty) {
      return null;
    }

    final Uri? uri = Uri.tryParse(url);
    if (uri != null &&
        uri.scheme == AppConstants.customerPaymentReturnScheme &&
        uri.host == 'payment-return') {
      return _normalizePaymentStatus(
        uri.queryParameters['status'] ?? uri.queryParameters['flag'],
      );
    }

    final Uri? baseUri = Uri.tryParse(AppConstants.baseUrl);
    if (uri != null && baseUri != null && _sameOrigin(uri, baseUri)) {
      final String basePath = baseUri.path == '/'
          ? ''
          : baseUri.path.replaceFirst(RegExp(r'/$'), '');
      final String path = uri.path.replaceFirst(RegExp(r'/$'), '');

      if (path == '$basePath/payment-success') {
        return 'success';
      }
      if (path == '$basePath/payment-fail') {
        return 'fail';
      }
      if (path == '$basePath/payment-cancel') {
        return 'cancel';
      }
    }

    return null;
  }

  bool _sameOrigin(Uri first, Uri second) {
    return first.scheme.toLowerCase() == second.scheme.toLowerCase() &&
        first.host.toLowerCase() == second.host.toLowerCase() &&
        first.port == second.port;
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

  void _closeWithStatus(String status) {
    if (_handledTerminalUrl) {
      return;
    }

    _handledTerminalUrl = true;
    Navigator.of(context).pop(status);
  }
}

class _StatusCard extends StatelessWidget {
  final String message;
  final bool checkingStatus;
  final VoidCallback onCheckStatus;

  const _StatusCard({
    required this.message,
    required this.checkingStatus,
    required this.onCheckStatus,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Theme.of(context).primaryColor.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(
            message,
            style: robotoRegular.copyWith(
              color: Theme.of(context).textTheme.bodyLarge!.color,
            ),
          ),
          const SizedBox(height: 10),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton(
              onPressed: checkingStatus ? null : onCheckStatus,
              child: checkingStatus
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Text('სტატუსის შემოწმება'),
            ),
          ),
        ],
      ),
    );
  }
}

class _KeepzIntent {
  final String url;
  final String action;

  const _KeepzIntent({required this.url, required this.action});

  factory _KeepzIntent.fromJson(Map<String, dynamic> json) {
    final String url = (json['url'] ?? '').toString().trim();
    final Uri? uri = Uri.tryParse(url);
    if (uri == null ||
        uri.scheme.toLowerCase() != 'https' ||
        uri.host.isEmpty) {
      throw const FormatException('Keepz returned an invalid payment URL');
    }

    return _KeepzIntent(
      url: url,
      action: (json['action'] ?? 'bottom_sheet_webview').toString(),
    );
  }
}
