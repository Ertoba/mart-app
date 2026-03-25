import 'package:sixam_mart/api/api_client.dart';
import 'package:sixam_mart/features/rental_module/rental_cart_screen/domain/repository/taxi_cart_repository_interface.dart';

class TaxiCartRepository implements TaxiCartRepositoryInterface {
  final ApiClient apiClient;
  TaxiCartRepository({required this.apiClient});

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
