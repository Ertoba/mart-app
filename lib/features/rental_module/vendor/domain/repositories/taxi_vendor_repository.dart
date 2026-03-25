import 'package:sixam_mart/api/api_client.dart';
import 'package:sixam_mart/features/rental_module/vendor/domain/repositories/taxi_vendor_repository_interface.dart';

class TaxiVendorRepository implements TaxiVendorRepositoryInterface {
  final ApiClient apiClient;
  TaxiVendorRepository({required this.apiClient});

  @override
  Future add(value) async {}

  @override
  Future delete(int? id) async {}

  @override
  Future get(String? id) async {}

  @override
  Future getList({int? offset}) async => const [];

  @override
  Future update(Map<String, dynamic> body, int? id) async {}
}
