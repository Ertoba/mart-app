/// Backend presentation contract shared by cart and route-driven payments.
class KeepzPaymentIntent {
  final String url;
  final String action;

  const KeepzPaymentIntent({required this.url, required this.action});

  factory KeepzPaymentIntent.fromJson(Map<String, dynamic> json) {
    final String url = (json['url'] ?? '').toString().trim();
    final Uri? uri = Uri.tryParse(url);
    if (uri == null ||
        uri.scheme.toLowerCase() != 'https' ||
        uri.host.isEmpty) {
      throw const FormatException('Keepz returned an invalid payment URL');
    }

    return KeepzPaymentIntent(
      url: url,
      action: (json['action'] ?? 'bottom_sheet_webview').toString(),
    );
  }

  // A hosted checkout stays in the sheet on every platform. Only an explicit
  // bank-app intent may attempt a non-browser handoff.
  bool shouldOpenBankApp({required bool externalFirst}) =>
      externalFirst && action == 'external_non_browser';
}
