import 'package:sixam_mart/api/api_client.dart';
import 'package:sixam_mart/features/rental_module/rental_order/domain/repository/taxi_order_repository_interface.dart';

class TaxiOrderRepository implements TaxiOrderRepositoryInterface {
  final ApiClient apiClient;
  TaxiOrderRepository({required this.apiClient});

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
