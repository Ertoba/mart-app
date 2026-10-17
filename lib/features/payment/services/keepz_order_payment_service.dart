import 'package:get/get.dart';
import 'package:sixam_mart/api/api_client.dart';
import 'package:sixam_mart/util/app_constants.dart';

class KeepzOrderActionResult {
  final String state;
  final String message;

  const KeepzOrderActionResult({required this.state, required this.message});

  bool get isReady => state == 'ready';
  bool get isPaid => state == 'paid';
  bool get isSuccess => state == 'success';
}

class KeepzOrderPaymentService {
  static Future<KeepzOrderActionResult> prepareRetry({
    required String orderId,
    required String guestId,
  }) async {
    return _postAction(
      orderId: orderId,
      guestId: guestId,
      action: 'prepare-retry',
      successState: 'ready',
      fallbackMessage:
          'წინა გადახდის სტატუსი უსაფრთხოდ ვერ დადასტურდა. სცადე მოგვიანებით.',
    );
  }

  static Future<KeepzOrderActionResult> switchToCod({
    required String orderId,
    required String guestId,
  }) async {
    return _postAction(
      orderId: orderId,
      guestId: guestId,
      action: 'switch-to-cod',
      successState: 'success',
      fallbackMessage: 'ადგილზე გადახდაზე უსაფრთხოდ გადასვლა ვერ მოხერხდა.',
    );
  }

  static Future<bool> cancelOrder({
    required String orderId,
    required String guestId,
  }) async {
    final ApiClient apiClient = Get.find<ApiClient>();
    final Map<String, String> body = <String, String>{
      '_method': 'put',
      'order_id': orderId,
      'reason': 'Checkout address changed before Keepz payment',
      'silent_payment_replacement': '1',
    };
    if (guestId.isNotEmpty) {
      body['guest_id'] = guestId;
    }

    final response = await apiClient.postData(
      AppConstants.orderCancelUri,
      body,
      handleError: false,
    );
    return response.statusCode == 200;
  }

  static Future<KeepzOrderActionResult> _postAction({
    required String orderId,
    required String guestId,
    required String action,
    required String successState,
    required String fallbackMessage,
  }) async {
    final ApiClient apiClient = Get.find<ApiClient>();
    final Map<String, String> body = <String, String>{};
    if (guestId.isNotEmpty) {
      body['guest_id'] = guestId;
    }

    final response = await apiClient.postData(
      '/api/v1/customer/order-payment/$orderId/$action',
      body,
      handleError: false,
    );
    final dynamic payload = response.body;
    final String state = payload is Map
        ? payload['state']?.toString().toLowerCase() ?? ''
        : '';
    final String paymentStatus = payload is Map
        ? payload['payment_status']?.toString().toLowerCase() ?? ''
        : '';
    final String errorCode = _errorCode(payload);

    if (state == 'paid' ||
        paymentStatus == 'paid' ||
        errorCode == 'order_already_paid') {
      return const KeepzOrderActionResult(
        state: 'paid',
        message: 'შეკვეთა უკვე გადახდილია.',
      );
    }

    if (response.statusCode == 200) {
      return KeepzOrderActionResult(
        state: successState,
        message: _message(payload, ''),
      );
    }

    return KeepzOrderActionResult(
      state: state.isNotEmpty ? state : 'blocked',
      message: _message(payload, fallbackMessage),
    );
  }

  static String _errorCode(dynamic payload) {
    if (payload is! Map) {
      return '';
    }
    final dynamic errors = payload['errors'];
    if (errors is List && errors.isNotEmpty && errors.first is Map) {
      return (errors.first as Map)['code']?.toString() ?? '';
    }
    return '';
  }

  static String _message(dynamic payload, String fallback) {
    if (payload is Map) {
      final String direct = payload['message']?.toString() ?? '';
      if (direct.isNotEmpty) {
        return direct;
      }
      final dynamic errors = payload['errors'];
      if (errors is List && errors.isNotEmpty && errors.first is Map) {
        final String errorMessage =
            (errors.first as Map)['message']?.toString() ?? '';
        if (errorMessage.isNotEmpty) {
          return errorMessage;
        }
      }
    }
    return fallback;
  }
}
