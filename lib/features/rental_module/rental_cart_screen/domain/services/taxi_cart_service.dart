import 'package:sixam_mart/features/rental_module/common/models/taxi_stub_models.dart';
import 'package:sixam_mart/features/rental_module/rental_cart_screen/domain/repository/taxi_cart_repository_interface.dart';
import 'package:sixam_mart/features/rental_module/rental_cart_screen/domain/services/taxi_cart_service_interface.dart';

class TaxiCartService implements TaxiCartServiceInterface {
  final TaxiCartRepositoryInterface taxiCartRepositoryInterface;
  TaxiCartService({required this.taxiCartRepositoryInterface});

  @override
  Future<List<TaxiCartItem>> getCarCartList() async => const [];

  @override
  Future<void> clearTaxiCart() async {}
}
