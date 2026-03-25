
import 'package:sixam_mart/features/rental_module/home/domain/repositories/taxi_home_repository_interface.dart';
import 'package:sixam_mart/features/rental_module/home/domain/services/taxi_home_service_interface.dart';

class TaxiHomeService implements TaxiHomeServiceInterface {
  final TaxiHomeRepositoryInterface taxiHomeRepositoryInterface;
  TaxiHomeService({required this.taxiHomeRepositoryInterface});

  @override
  Future<void> getTopRatedCarList(int offset, bool reload) async {}
  @override
  Future<void> getTaxiBannerList(bool reload) async {}
  @override
  Future<void> getTaxiCouponList(bool reload) async {}
}