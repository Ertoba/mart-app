import 'dart:convert';
import 'package:flitt_mobile/flitt_mobile.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:sixam_mart/common/widgets/custom_snackbar.dart';
import 'package:sixam_mart/features/checkout/widgets/payment_failed_dialog.dart';
import 'package:sixam_mart/features/home/controllers/home_controller.dart';
import 'package:sixam_mart/features/location/domain/models/zone_response_model.dart';
import 'package:sixam_mart/features/order/domain/models/order_model.dart';
import 'package:sixam_mart/features/payment/screens/payment_screen.dart';
import 'package:sixam_mart/features/payment/screens/payment_webview_screen.dart';
import 'package:sixam_mart/features/splash/controllers/splash_controller.dart';
import 'package:sixam_mart/features/wallet/widgets/fund_payment_dialog_widget.dart';
import 'package:sixam_mart/helper/address_helper.dart';
import 'package:sixam_mart/helper/route_helper.dart';
import 'package:sixam_mart/util/app_constants.dart';

class FlittMobilePaymentScreen extends StatefulWidget {
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

  const FlittMobilePaymentScreen({
    super.key,
    required this.orderModel,
    required this.isCashOnDelivery,
    this.addFundUrl,
    required this.paymentMethod,
    required this.guestId,
    required this.contactNumber,
    this.subscriptionUrl,
    this.storeId,
    this.createAccount = false,
    this.createUserId,
  });

  @override
  State<FlittMobilePaymentScreen> createState() =>
      _FlittMobilePaymentScreenState();
}

class _FlittMobilePaymentScreenState extends State<FlittMobilePaymentScreen> {
  final GlobalKey _creditCardInputKey = GlobalKey();

  Cloudipsp? _cloudipsp;
  dynamic _googlePayConfig;
  PrivateCloudipspWebViewConfirmation? _webViewConfirmation;
  bool _isInitializing = true;
  bool _isProcessing = false;
  bool _supportsApplePay = false;
  bool _supportsGooglePay = false;
  bool _awaitingConfirmation = false;
  String? _initializationError;
  String? _paymentId;
  String? _token;
  double? _maximumCodOrderAmount;

  bool get _isOrderFlow {
    final bool addFundEmpty =
        widget.addFundUrl == null || widget.addFundUrl!.isEmpty;
    final bool subscriptionEmpty =
        widget.subscriptionUrl == null || widget.subscriptionUrl!.isEmpty;
    return addFundEmpty && subscriptionEmpty;
  }

  bool get _isSubscriptionFlow {
    final bool addFundEmpty =
        widget.addFundUrl == null || widget.addFundUrl!.isEmpty;
    return !_isOrderFlow &&
        addFundEmpty &&
        (widget.subscriptionUrl?.isNotEmpty ?? false);
  }

  @override
  void initState() {
    super.initState();
    _initData();
  }

  Future<void> _initData() async {
    if (_isOrderFlow) {
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

    await _initializeFlitt();
  }

  Future<void> _initializeFlitt() async {
    setState(() {
      _isInitializing = true;
      _initializationError = null;
      _awaitingConfirmation = false;
    });

    try {
      final _FlittIntent intent = await _fetchIntent();
      final cloudipsp = Cloudipsp(
        intent.merchantId,
        _handleWebViewConfirmation,
      );
      final bool supportsApplePay = await cloudipsp.supportsApplePay();
      final bool supportsGooglePay = await cloudipsp.supportsGooglePay();

      if (!mounted) {
        return;
      }

      setState(() {
        _cloudipsp = cloudipsp;
        _paymentId = intent.paymentId;
        _token = intent.token;
        _supportsApplePay = supportsApplePay;
        _supportsGooglePay = supportsGooglePay;
        _googlePayConfig = null;
        _isInitializing = false;
      });

      if (supportsGooglePay) {
        await _ensureGooglePayConfig();
      }
    } catch (error) {
      if (!mounted) {
        return;
      }

      setState(() {
        _isInitializing = false;
        _initializationError = _readableError(error);
      });
    }
  }

  Future<_FlittIntent> _fetchIntent() async {
    final String? directPaymentId =
        _extractPaymentIdFromUrl(widget.subscriptionUrl) ??
        _extractPaymentIdFromUrl(widget.addFundUrl);

    late final Uri uri;
    if (directPaymentId != null) {
      uri = Uri.parse('${AppConstants.baseUrl}/payment/flitt/mobile-intent')
          .replace(
            queryParameters: <String, String>{'payment_id': directPaymentId},
          );
    } else {
      final String customerId = widget.orderModel.userId == 0
          ? widget.guestId
          : widget.orderModel.userId.toString();
      uri = Uri.parse('${AppConstants.baseUrl}/payment-mobile/flitt-intent')
          .replace(
            queryParameters: <String, String>{
              'customer_id': customerId,
              'order_id': widget.orderModel.id.toString(),
              'payment_method': widget.paymentMethod,
            },
          );
    }

    final http.Response response = await http.get(uri);
    if (response.statusCode != 200) {
      throw _extractBackendMessage(response.body);
    }

    final dynamic decodedBody = jsonDecode(response.body);
    if (decodedBody is! Map<String, dynamic>) {
      throw 'Flitt გადახდის ინიციალიზაცია ვერ მოხერხდა';
    }

    return _FlittIntent.fromJson(decodedBody);
  }

  String? _extractPaymentIdFromUrl(String? url) {
    if (url == null || url.isEmpty) {
      return null;
    }

    final Uri? uri = Uri.tryParse(url);
    if (uri == null) {
      return null;
    }

    if (!uri.path.contains('/payment/flitt/pay')) {
      return null;
    }

    return uri.queryParameters['payment_id'];
  }

  String _extractBackendMessage(String body) {
    try {
      final dynamic decodedBody = jsonDecode(body);
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
    } catch (_) {}

    return 'Flitt გადახდის ინიციალიზაცია ვერ მოხერხდა';
  }

  Future<void> _ensureGooglePayConfig() async {
    if (_cloudipsp == null || _token == null || _googlePayConfig != null) {
      return;
    }

    _googlePayConfig = await _cloudipsp!.initializePaymentConfig(
      null,
      token: _token,
    );
  }

  void _handleWebViewConfirmation(CloudipspWebViewConfirmation confirmation) {
    if (confirmation is! PrivateCloudipspWebViewConfirmation || !mounted) {
      return;
    }

    setState(() {
      _webViewConfirmation = confirmation;
    });
  }

  Future<void> _closeConfirmation([dynamic error]) async {
    final PrivateCloudipspWebViewConfirmation? confirmation =
        _webViewConfirmation;

    if (confirmation != null && !confirmation.completer.isCompleted) {
      if (error != null) {
        confirmation.completer.completeError(error);
      } else {
        confirmation.completer.complete(null);
      }
    }

    if (!mounted) {
      return;
    }

    setState(() {
      _webViewConfirmation = null;
    });
  }

  Future<void> _payWithApplePay() async {
    if (_cloudipsp == null || _token == null) {
      return;
    }

    await _runPayment(() => _cloudipsp!.applePayToken(_token!));
  }

  Future<void> _payWithGooglePay() async {
    if (_cloudipsp == null || _token == null) {
      return;
    }

    try {
      await _ensureGooglePayConfig();
    } catch (error) {
      showCustomSnackBar(_readableError(error));
      return;
    }

    if (_googlePayConfig == null) {
      showCustomSnackBar('Google Pay დროებით მიუწვდომელია');
      return;
    }

    await _runPayment(
      () => _cloudipsp!.googlePayToken(_token!, _googlePayConfig),
    );
  }

  Future<void> _payWithCard() async {
    if (_cloudipsp == null || _token == null) {
      return;
    }

    final dynamic state = _creditCardInputKey.currentState;
    if (state is! CreditCardInputState) {
      showCustomSnackBar('ბარათის ფორმა მზად არ არის');
      return;
    }

    final CreditCard card = state.getCard();
    if (!card.isValid()) {
      showCustomSnackBar('შეიყვანე ბარათის სწორი მონაცემები');
      return;
    }

    await _runPayment(() => _cloudipsp!.payToken(card, _token!));
  }

  Future<void> _runPayment(Future<Receipt> Function() action) async {
    setState(() {
      _isProcessing = true;
    });

    try {
      await action();
      await _closeConfirmation();
      await _resolvePaymentResult();
    } catch (error) {
      if (!mounted) {
        return;
      }

      setState(() {
        _isProcessing = false;
        _webViewConfirmation = null;
      });
      showCustomSnackBar(_readableError(error));
    }
  }

  Future<void> _resolvePaymentResult() async {
    final String status = await _fetchPaymentStatus();

    if (!mounted) {
      return;
    }

    if (status == 'approved') {
      _handleSuccessfulPayment();
      return;
    }

    if (const <String>{'declined', 'expired', 'reversed'}.contains(status)) {
      _handleFailedPayment();
      return;
    }

    setState(() {
      _isProcessing = false;
      _awaitingConfirmation = true;
    });
    showCustomSnackBar(
      'გადახდა მოწმდება. სტატუსი კიდევ ერთხელ გადაამოწმე რამდენიმე წამში.',
      isError: false,
    );
  }

  Future<String> _fetchPaymentStatus() async {
    if (_paymentId == null) {
      return 'processing';
    }

    for (int attempt = 0; attempt < 6; attempt++) {
      final Uri uri = Uri.parse(
        '${AppConstants.baseUrl}/payment/flitt/mobile-status',
      ).replace(queryParameters: <String, String>{'payment_id': _paymentId!});

      final http.Response response = await http.get(uri);
      if (response.statusCode == 200) {
        final dynamic decodedBody = jsonDecode(response.body);
        if (decodedBody is Map<String, dynamic>) {
          final String status =
              (decodedBody['status']?.toString().toLowerCase() ?? 'processing');
          final bool isPaid = decodedBody['is_paid'] == true;

          if (isPaid || status == 'approved') {
            return 'approved';
          }

          if (const <String>{
            'declined',
            'expired',
            'reversed',
          }.contains(status)) {
            return status;
          }
        }
      }

      if (attempt < 5) {
        await Future<void>.delayed(const Duration(seconds: 2));
      }
    }

    return 'processing';
  }

  void _handleSuccessfulPayment() {
    if (_isOrderFlow) {
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

    if (_isSubscriptionFlow) {
      Get.find<HomeController>().saveRegistrationSuccessfulSharedPref(true);
      Get.find<HomeController>().saveIsStoreRegistrationSharedPref(true);
      Get.offAllNamed(
        RouteHelper.getSubscriptionSuccessRoute(
          status: 'success',
          fromSubscription: true,
          storeId: widget.storeId,
        ),
      );
      return;
    }

    Get.offNamed(
      RouteHelper.getWalletRoute(
        fundStatus: 'success',
        token: UniqueKey().toString(),
      ),
    );
  }

  void _handleFailedPayment() {
    if (_isOrderFlow) {
      Get.offNamed(
        RouteHelper.getDigitalPaymentFailedScreen(
          widget.orderModel.id.toString(),
          createAccount: widget.createAccount,
        ),
      );
      return;
    }

    if (_isSubscriptionFlow) {
      Get.offAllNamed(
        RouteHelper.getSubscriptionSuccessRoute(
          status: 'fail',
          fromSubscription: true,
          storeId: widget.storeId,
        ),
      );
      return;
    }

    Get.offNamed(
      RouteHelper.getWalletRoute(
        fundStatus: 'fail',
        token: UniqueKey().toString(),
      ),
    );
  }

  String _readableError(dynamic error) {
    if (error is CloudipspUserError) {
      if (error.code.toUpperCase() == 'CANCELED' ||
          error.code == 'UserCanceled') {
        return 'გადახდა გაუქმდა';
      }
      return error.message.isNotEmpty ? error.message : 'გადახდა ვერ შესრულდა';
    }

    if (error is CloudipspError) {
      return error.message.isNotEmpty ? error.message : 'გადახდა ვერ შესრულდა';
    }

    if (error is String && error.isNotEmpty) {
      return error;
    }

    return 'გადახდა ვერ შესრულდა';
  }

  Future<void> _openHostedCheckoutFallback() async {
    final Widget screen = AppConstants.payInWevView
        ? PaymentWebViewScreen(
            orderModel: widget.orderModel,
            isCashOnDelivery: widget.isCashOnDelivery,
            addFundUrl: widget.addFundUrl,
            paymentMethod: widget.paymentMethod,
            guestId: widget.guestId,
            contactNumber: widget.contactNumber,
            subscriptionUrl: widget.subscriptionUrl,
            storeId: widget.storeId,
            createAccount: widget.createAccount,
          )
        : PaymentScreen(
            orderModel: widget.orderModel,
            isCashOnDelivery: widget.isCashOnDelivery,
            addFundUrl: widget.addFundUrl,
            paymentMethod: widget.paymentMethod,
            guestId: widget.guestId,
            contactNumber: widget.contactNumber,
            subscriptionUrl: widget.subscriptionUrl,
            storeId: widget.storeId,
            createAccount: widget.createAccount,
            createUserId: widget.createUserId,
          );

    await Get.off<void>(() => screen);
  }

  Future<bool?> _exitApp() async {
    if (_isOrderFlow) {
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

    return Get.dialog(
      FundPaymentDialogWidget(
        isSubscription:
            widget.subscriptionUrl != null &&
            widget.subscriptionUrl!.isNotEmpty,
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
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          title: const Text('გადახდა'),
          centerTitle: true,
          elevation: 0,
          backgroundColor: _brandBackgroundStart(context),
          foregroundColor: Colors.white,
          leading: IconButton(
            onPressed: () => _exitApp(),
            icon: const Icon(Icons.arrow_back_ios),
          ),
        ),
        body: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: <Color>[
                _brandBackgroundStart(context),
                _brandBackgroundEnd(context),
              ],
            ),
          ),
          child: SafeArea(
            top: false,
            child: _isInitializing
                ? Center(
                    child: CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                    ),
                  )
                : _buildContent(context),
          ),
        ),
      ),
    );
  }

  Color _brandBackgroundStart(BuildContext context) {
    return Theme.of(context).primaryColor;
  }

  Color _brandBackgroundEnd(BuildContext context) {
    return Color.alphaBlend(
      Colors.black.withValues(alpha: 0.18),
      Theme.of(context).primaryColor,
    );
  }

  TextStyle? _sectionTextStyle(BuildContext context) {
    return Theme.of(context).textTheme.bodyMedium?.copyWith(
      color: Colors.white,
      fontWeight: FontWeight.w600,
    );
  }

  InputDecoration _cardInputDecoration(
    BuildContext context, {
    required String hintText,
  }) {
    return InputDecoration(
      hintText: hintText,
      hintStyle: Theme.of(context).textTheme.bodyLarge?.copyWith(
        color: Theme.of(context).hintColor.withValues(alpha: 0.9),
      ),
      filled: true,
      fillColor: Colors.white,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide.none,
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide.none,
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide(
          color: Colors.white.withValues(alpha: 0.75),
          width: 1.4,
        ),
      ),
    );
  }

  Widget _fieldLabel(BuildContext context, String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(text, style: _sectionTextStyle(context)),
    );
  }

  Widget _buildCardForm(BuildContext context) {
    return CreditCardInputLayout(
      key: _creditCardInputKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          _fieldLabel(context, 'ბარათის ნომერი'),
          CreditCardNumberField(
            decoration: _cardInputDecoration(
              context,
              hintText: '0000 0000 0000 0000',
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: <Widget>[
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    _fieldLabel(context, 'წელი'),
                    CreditCardExpYyField(
                      decoration: _cardInputDecoration(context, hintText: 'YY'),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    _fieldLabel(context, 'თვე'),
                    CreditCardExpMmField(
                      decoration: _cardInputDecoration(context, hintText: 'MM'),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          _fieldLabel(context, 'უსაფრთხოების კოდი'),
          CreditCardCvvField(
            decoration: _cardInputDecoration(context, hintText: 'CVV'),
          ),
        ],
      ),
    );
  }

  Widget _buildGooglePayAction(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 56,
      child: FilledButton(
        onPressed: _isProcessing ? null : _payWithGooglePay,
        style: FilledButton.styleFrom(
          backgroundColor: Colors.white,
          foregroundColor: Colors.black,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Icon(
              Icons.account_balance_wallet_rounded,
              color: _brandBackgroundStart(context),
              size: 22,
            ),
            const SizedBox(width: 10),
            Text(
              'Google Pay',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                color: Colors.black,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildApplePayAction(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 56,
      child: FilledButton(
        onPressed: _isProcessing ? null : _payWithApplePay,
        style: FilledButton.styleFrom(
          backgroundColor: Colors.black,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            const Icon(Icons.apple, size: 22),
            const SizedBox(width: 10),
            Text(
              'Apple Pay',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildContent(BuildContext context) {
    if (_initializationError != null) {
      return Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text(
              _initializationError!,
              textAlign: TextAlign.center,
              style: Theme.of(
                context,
              ).textTheme.bodyLarge?.copyWith(color: Colors.white),
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _openHostedCheckoutFallback,
                child: const Text('გახსენი Flitt-ის დაცული გვერდი'),
              ),
            ),
            const SizedBox(height: 12),
            TextButton(
              onPressed: _initializeFlitt,
              child: const Text(
                'თავიდან სცადე',
                style: TextStyle(color: Colors.white),
              ),
            ),
          ],
        ),
      );
    }

    return Stack(
      children: <Widget>[
        SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              Text(
                'Flitt',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'გადაიხადე უსაფრთხოდ Google Pay-ის, Apple Pay-ის და საბანკო ბარათით',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Colors.white.withValues(alpha: 0.9),
                ),
              ),
              const SizedBox(height: 24),

              if (_supportsGooglePay) ...<Widget>[
                _buildGooglePayAction(context),
                const SizedBox(height: 16),
              ],

              if (_supportsApplePay) ...<Widget>[
                _buildApplePayAction(context),
                const SizedBox(height: 16),
              ],

              if (_supportsGooglePay || _supportsApplePay) ...<Widget>[
                Row(
                  children: <Widget>[
                    Expanded(
                      child: Divider(
                        color: Colors.white.withValues(alpha: 0.35),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      child: Text(
                        'გადაიხადე ბარათით',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          letterSpacing: 0.6,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                      ),
                    ),
                    Expanded(
                      child: Divider(
                        color: Colors.white.withValues(alpha: 0.35),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
              ],

              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: Colors.white.withValues(alpha: 0.18),
                  ),
                ),
                child: _buildCardForm(context),
              ),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _isProcessing ? null : _payWithCard,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.black.withValues(alpha: 0.22),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                    side: BorderSide(
                      color: Colors.white.withValues(alpha: 0.25),
                    ),
                  ),
                  child: const Text('გადახდა'),
                ),
              ),
              if (_awaitingConfirmation) ...<Widget>[
                const SizedBox(height: 12),
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton(
                    onPressed: _isProcessing
                        ? null
                        : () async {
                            setState(() {
                              _isProcessing = true;
                            });
                            await _resolvePaymentResult();
                          },
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.white,
                      side: BorderSide(
                        color: Colors.white.withValues(alpha: 0.45),
                      ),
                    ),
                    child: const Text('სტატუსის შემოწმება'),
                  ),
                ),
              ],
            ],
          ),
        ),
        if (_isProcessing)
          Container(
            color: Colors.black.withValues(alpha: 0.08),
            child: Center(
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
              ),
            ),
          ),
        if (_webViewConfirmation != null)
          Positioned.fill(
            child: Material(
              color: Colors.black.withValues(alpha: 0.72),
              child: SafeArea(
                child: Column(
                  children: <Widget>[
                    Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 10,
                      ),
                      child: Row(
                        children: <Widget>[
                          IconButton(
                            onPressed: () => _closeConfirmation(
                              CloudipspUserError('CANCELED', 'გადახდა გაუქმდა'),
                            ),
                            icon: const Icon(Icons.close, color: Colors.white),
                          ),
                          Expanded(
                            child: Text(
                              '3D დადასტურება',
                              textAlign: TextAlign.center,
                              style: Theme.of(context).textTheme.titleMedium
                                  ?.copyWith(
                                    color: Colors.white,
                                    fontWeight: FontWeight.w700,
                                  ),
                            ),
                          ),
                          const SizedBox(width: 48),
                        ],
                      ),
                    ),
                    Expanded(
                      child: Container(
                        margin: const EdgeInsets.fromLTRB(12, 0, 12, 12),
                        clipBehavior: Clip.antiAlias,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: CloudipspWebView(
                          key: UniqueKey(),
                          confirmation: _webViewConfirmation!,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
      ],
    );
  }
}

class _FlittIntent {
  final String paymentId;
  final int merchantId;
  final String token;

  const _FlittIntent({
    required this.paymentId,
    required this.merchantId,
    required this.token,
  });

  factory _FlittIntent.fromJson(Map<String, dynamic> json) {
    return _FlittIntent(
      paymentId: json['payment_id'].toString(),
      merchantId: int.parse(json['merchant_id'].toString()),
      token: json['token'].toString(),
    );
  }
}
