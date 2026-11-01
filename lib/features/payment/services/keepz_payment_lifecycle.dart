/// Resolves callback hints against the authoritative Backend payment state.
/// Neither a hosted page nor an app-link can declare an order paid.
class KeepzPaymentLifecycle {
  final Future<String?> Function() readPaymentStatus;
  bool _checking = false;
  bool _completed = false;

  KeepzPaymentLifecycle({required this.readPaymentStatus});

  bool get isChecking => _checking;
  bool get isCompleted => _completed;

  /// A null hint means an explicit status check or return from a bank app.
  Future<String?> resolve({String? terminalHint}) async {
    if (_completed || _checking) {
      return null;
    }
    if (terminalHint == 'cancel') {
      _completed = true;
      return 'cancel';
    }
    if (terminalHint != null &&
        terminalHint != 'success' &&
        terminalHint != 'fail') {
      return null;
    }

    _checking = true;
    try {
      final String? status = await readPaymentStatus();
      if (status == 'success' || status == 'fail' || status == 'superseded') {
        _completed = true;
        return status;
      }
      // Unknown/active payments remain in the sheet and can be checked again.
      return null;
    } catch (_) {
      return null;
    } finally {
      _checking = false;
    }
  }

  static String? backendStatus({
    required int? statusCode,
    required dynamic body,
  }) {
    if (statusCode != 200 || body is! Map) {
      return null;
    }
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
    return null;
  }

  static String? terminalHint(
    String? url, {
    required String baseUrl,
    required String returnScheme,
  }) {
    if (url == null || url.isEmpty) {
      return null;
    }
    final Uri? uri = Uri.tryParse(url);
    if (uri != null &&
        uri.scheme == returnScheme &&
        uri.host == 'payment-return') {
      return _normalizeStatus(
        uri.queryParameters['status'] ?? uri.queryParameters['flag'],
      );
    }

    final Uri? baseUri = Uri.tryParse(baseUrl);
    if (uri == null ||
        baseUri == null ||
        uri.scheme.toLowerCase() != baseUri.scheme.toLowerCase() ||
        uri.host.toLowerCase() != baseUri.host.toLowerCase() ||
        uri.port != baseUri.port) {
      return null;
    }
    final String basePath = baseUri.path == '/'
        ? ''
        : baseUri.path.replaceFirst(RegExp(r'/$'), '');
    final String path = uri.path.replaceFirst(RegExp(r'/$'), '');
    for (final String status in <String>['success', 'fail', 'cancel']) {
      if (path == '$basePath/payment-$status') {
        return status;
      }
    }
    return null;
  }

  static String? _normalizeStatus(String? status) {
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
}
