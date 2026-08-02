from pathlib import Path
import re


def replace_once(text: str, old: str, new: str, label: str) -> str:
    count = text.count(old)
    if count != 1:
        raise SystemExit(f"{label}: expected 1 match, found {count}")
    return text.replace(old, new, 1)


def sub_once(text: str, pattern: str, replacement: str, label: str) -> str:
    updated, count = re.subn(pattern, replacement, text, count=1, flags=re.S)
    if count != 1:
        raise SystemExit(f"{label}: expected 1 match, found {count}")
    return updated


path = Path("lib/features/payment/screens/keepz_native_payment_screen.dart")
text = path.read_text()

text = replace_once(
    text,
    "import 'package:sixam_mart/common/widgets/custom_button.dart';",
    "import 'package:sixam_mart/api/api_client.dart';\nimport 'package:sixam_mart/common/widgets/custom_button.dart';",
    "ApiClient import",
)
text = replace_once(
    text,
    "import 'package:sixam_mart/features/order/controllers/order_controller.dart';\n",
    "",
    "unused OrderController import",
)

text = replace_once(
    text,
    """    if (status != null) {
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
""",
    """    if (status == 'superseded') {
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
""",
    "launcher superseded handling",
)

authoritative_reader = """  static Future<String?> _readClosedOrderPaymentStatus({
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

        if (state == 'terminal' ||
            state == 'ready' ||
            state == 'absent') {
          return 'fail';
        }
      }
    }

    return null;
  }

"""
text = sub_once(
    text,
    r"  static Future<String\?> _readClosedOrderPaymentStatus\(\{.*?\n  \}\n\n  static bool _isPaidOrder\(OrderModel order\) \{.*?\n  \}\n\n(?=  static void _navigateOrderPaymentResult)",
    authoritative_reader,
    "authoritative status reader",
)

call_arg = "contactNumber: widget.contactNumber,"
call_count = text.count(call_arg)
if call_count != 4:
    raise SystemExit(
        f"authoritative status call arguments: expected 4 matches, found {call_count}"
    )
text = text.replace(call_arg, "guestId: widget.guestId,")

text = replace_once(
    text,
    """    if (Get.isBottomSheetOpen == true) {
      Get.back();
    }

    if (status == 'success') {
""",
    """    if (Get.isBottomSheetOpen == true) {
      Get.back();
    }

    if (status == 'superseded') {
      return;
    }

    if (status == 'success') {
""",
    "static navigation superseded guard",
)

instance_resolver = """  Future<void> _resolveClosedOrderPayment() async {
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

"""
text = sub_once(
    text,
    r"  Future<void> _resolveClosedOrderPayment\(\) async \{.*?\n  \}\n\n  bool _isPaidOrder\(OrderModel order\) \{.*?\n  \}\n\n(?=  void _navigateOrderPaymentResult)",
    instance_resolver,
    "instance status resolver",
)

text = replace_once(
    text,
    """  void _navigateOrderPaymentResult(String status) {
    if (!Get.currentRoute.startsWith(RouteHelper.payment)) {
      return;
    }

    if (status == 'success') {
""",
    """  void _navigateOrderPaymentResult(String status) {
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
""",
    "instance navigation superseded guard",
)

path.write_text(text)

pubspec_path = Path("pubspec.yaml")
pubspec = pubspec_path.read_text()
pubspec = replace_once(
    pubspec,
    "version: 3.8.11+39",
    "version: 3.8.12+40",
    "app version bump",
)
pubspec_path.write_text(pubspec)
