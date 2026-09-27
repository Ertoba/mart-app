import 'package:get/get.dart';
import 'package:sixam_mart/features/rental_module/common/models/taxi_stub_models.dart';
import 'package:sixam_mart/features/rental_module/rental_cart_screen/domain/services/taxi_cart_service_interface.dart';

class TaxiCartController extends GetxController implements GetxService {
  final TaxiCartServiceInterface taxiCartServiceInterface;
  TaxiCartController({required this.taxiCartServiceInterface});

  final List<TaxiCartItem> _cartList = [];
  List<TaxiCartItem> get cartList => _cartList;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  Future<void> getCarCartList() async {
    _isLoading = true;
    update();
    _cartList
      ..clear()
      ..addAll(await taxiCartServiceInterface.getCarCartList());
    _isLoading = false;
    update();
  }

  Future<void> clearTaxiCart() async {
    await taxiCartServiceInterface.clearTaxiCart();
    _cartList.clear();
    update();
  }

  void setReelOrderId(int? vehicleId) {
    // Reserved by the v4 rental flow until the rental cart persists reel attribution.
  }
}
