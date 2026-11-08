/// A placed parcel awaiting payment. Closing payment never un-places the order.
class ParcelPaymentOrder {
  final String orderId;
  final String? message;
  final int? createUserId;

  const ParcelPaymentOrder({
    required this.orderId,
    this.message,
    this.createUserId,
  });
}

class ParcelPaymentDraftChanged implements Exception {
  const ParcelPaymentDraftChanged();
}

/// Retains the placed order across dismiss/failure/retry and serializes taps.
/// Signatures stay in memory only; never log or persist checkout payloads.
class ParcelPaymentSession {
  ParcelPaymentOrder? _pending;
  String? _signature;
  Future<String>? _active;

  ParcelPaymentOrder? get pending => _pending;

  bool matches(String signature) => _signature == signature;

  /// Only matching authoritative Backend state can release a pending order
  /// without a successful sheet. A canceled order alone is insufficient: an
  /// earlier bank attempt might still be active or unknown.
  bool releaseResolvedOrder({required int? statusCode, required dynamic body}) {
    if (_active != null ||
        _pending == null ||
        statusCode != 200 ||
        body is! Map) {
      return false;
    }
    if (body['order_id']?.toString() != _pending!.orderId) return false;
    final String state = body['state']?.toString().toLowerCase() ?? '';
    final String payment =
        body['payment_status']?.toString().toLowerCase() ?? '';
    final String order = body['order_status']?.toString().toLowerCase() ?? '';
    final bool paid = state == 'paid' && payment == 'paid';
    final bool safelyCanceled =
        state == 'ready' && payment == 'unpaid' && order == 'canceled';
    if (!paid && !safelyCanceled) return false;
    _pending = null;
    _signature = null;
    return true;
  }

  Future<String> run({
    required String signature,
    required Future<ParcelPaymentOrder?> Function() createOrder,
    required Future<String?> Function(ParcelPaymentOrder order) showPayment,
  }) {
    if (_active != null) return _active!;
    return _active =
        _run(
          signature: signature,
          createOrder: createOrder,
          showPayment: showPayment,
        ).whenComplete(() {
          _active = null;
        });
  }

  Future<String> _run({
    required String signature,
    required Future<ParcelPaymentOrder?> Function() createOrder,
    required Future<String?> Function(ParcelPaymentOrder order) showPayment,
  }) async {
    if (_pending != null && _signature != signature) {
      // A changed address/amount must not silently pay the old parcel or create
      // another order. The user can finish/cancel it from their order list.
      throw const ParcelPaymentDraftChanged();
    }
    final ParcelPaymentOrder? order = _pending ?? await createOrder();
    if (order == null) return '';
    _pending = order;
    _signature = signature;
    final String? status = await showPayment(order);
    if (status == 'success') {
      _pending = null;
      _signature = null;
    }
    return order.orderId;
  }
}
