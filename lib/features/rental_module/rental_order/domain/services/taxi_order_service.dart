import 'package:sixam_mart/features/rental_module/common/models/taxi_stub_models.dart';
import 'package:sixam_mart/features/rental_module/rental_order/domain/repository/taxi_order_repository_interface.dart';
import 'package:sixam_mart/features/rental_module/rental_order/domain/services/taxi_order_service_interface.dart';

class TaxiOrderService implements TaxiOrderServiceInterface {
  final TaxiOrderRepositoryInterface taxiOrderRepositoryInterface;
  TaxiOrderService({required this.taxiOrderRepositoryInterface});

  @override
  Future<void> getTripList(int offset, {required bool isRunning}) async {}

  @override
  Future<TaxiTripDetails?> getTripDetails(int tripId, {String? phone, bool willUpdate = true}) async {
    return TaxiTripDetails(id: tripId, phone: phone);
  }
}
