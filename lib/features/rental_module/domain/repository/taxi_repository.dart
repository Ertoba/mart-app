import 'package:shared_preferences/shared_preferences.dart';
import 'package:sixam_mart/api/api_client.dart';
import 'package:sixam_mart/features/rental_module/domain/repository/taxi_repository_interface.dart';

class TaxiRepository implements TaxiRepositoryInterface{
  final ApiClient apiClient;
  final SharedPreferences sharedPreferences;
  TaxiRepository({required this.sharedPreferences, required this.apiClient});

  @override
  Future add(value) async {}
  @override
  Future update(Map<String, dynamic> body, int? id) async {}
  @override
  Future delete(int? id) async {}
  @override
  Future getList({int? offset}) async => const [];
  @override
  Future get(String? id) async {}
}