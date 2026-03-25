import 'package:sixam_mart/features/rental_module/common/models/taxi_stub_models.dart';

abstract class TaxiCartServiceInterface {
  Future<List<TaxiCartItem>> getCarCartList();
  Future<void> clearTaxiCart();
}
