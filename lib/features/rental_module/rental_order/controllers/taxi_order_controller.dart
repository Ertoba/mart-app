import 'package:get/get.dart';
import 'package:sixam_mart/features/rental_module/common/models/taxi_stub_models.dart';
import 'package:sixam_mart/features/rental_module/rental_order/domain/services/taxi_order_service_interface.dart';

class TaxiOrderController extends GetxController implements GetxService {
  final TaxiOrderServiceInterface taxiOrderServiceInterface;
  TaxiOrderController({required this.taxiOrderServiceInterface});

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  TaxiTripDetails? _tripDetails;
  TaxiTripDetails? get tripDetails => _tripDetails;

  Future<void> getTripList(int offset, {required bool isRunning}) async {
    _isLoading = true;
    update();
    await taxiOrderServiceInterface.getTripList(offset, isRunning: isRunning);
    _isLoading = false;
    update();
  }

  Future<bool> getTripDetails(int tripId, {String? phone, bool willUpdate = true}) async {
    _isLoading = true;
    update();
    _tripDetails = await taxiOrderServiceInterface.getTripDetails(tripId, phone: phone, willUpdate: willUpdate);
    _isLoading = false;
    update();
    return _tripDetails != null;
  }
}
