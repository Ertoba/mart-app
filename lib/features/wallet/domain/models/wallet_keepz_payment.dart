/// Capability-gated native wallet flow. No redirect can declare a wallet paid.
class WalletKeepzPayment {
  final String paymentId;
  final String redirectUrl;

  const WalletKeepzPayment({
    required this.paymentId,
    required this.redirectUrl,
  });

  static final RegExp _uuid = RegExp(
    r'^[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}$',
    caseSensitive: false,
  );

  /// Old servers and all other gateways retain their existing payment flow.
  static WalletKeepzPayment? fromResponse({
    required String paymentMethod,
    required dynamic body,
    required String baseUrl,
  }) {
    if (paymentMethod != 'keepz' ||
        body is! Map ||
        body['embedded_keepz_wallet'] != true) {
      return null;
    }
    final String url = '${body['redirect_link'] ?? ''}';
    final Uri? uri = Uri.tryParse(url);
    final Uri? base = Uri.tryParse(baseUrl);
    final String id = uri?.queryParameters['payment_id'] ?? '';
    final String basePath = base?.path.replaceFirst(RegExp(r'/$'), '') ?? '';
    if (uri == null ||
        base == null ||
        uri.scheme != 'https' ||
        uri.host != base.host ||
        uri.port != base.port ||
        uri.userInfo.isNotEmpty ||
        uri.path.replaceFirst(RegExp(r'/$'), '') !=
            '$basePath/payment/keepz/pay' ||
        uri.queryParametersAll['payment_id']?.length != 1 ||
        !_uuid.hasMatch(id)) {
      throw const FormatException('Invalid wallet payment identity');
    }
    return WalletKeepzPayment(paymentId: id, redirectUrl: url);
  }

  String get statusPath => '/api/v1/customer/wallet/payment/$paymentId/status';

  String? verifiedStatus({required int? statusCode, required dynamic body}) {
    if (statusCode != 200 || body is! Map || body['payment_id'] != paymentId) {
      return null;
    }
    if (body['state'] == 'paid' &&
        body['wallet_credit_confirmed'] == true &&
        body['wallet_payment_status'] == 'success') {
      return 'success';
    }
    if (body['state'] == 'terminal' &&
        body['wallet_credit_confirmed'] == false) {
      return 'fail';
    }
    return null;
  }
}
