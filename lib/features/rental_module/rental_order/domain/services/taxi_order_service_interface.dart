import 'package:sixam_mart/features/rental_module/common/models/taxi_stub_models.dart';

abstract class TaxiOrderServiceInterface {
  Future<void> getTripList(int offset, {required bool isRunning});
  Future<TaxiTripDetails?> getTripDetails(int tripId, {String? phone, bool willUpdate = true});
}
