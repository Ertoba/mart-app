import 'package:shared_preferences/shared_preferences.dart';
import 'package:sixam_mart/api/api_client.dart';
import 'package:sixam_mart/features/rental_module/home/domain/repositories/taxi_home_repository_interface.dart';

class TaxiHomeRepository implements TaxiHomeRepositoryInterface {
  final ApiClient apiClient;
  final SharedPreferences sharedPreferences;

  TaxiHomeRepository({
    required this.apiClient,
    required this.sharedPreferences,
  });

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
