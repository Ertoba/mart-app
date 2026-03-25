import 'package:shared_preferences/shared_preferences.dart';
import 'package:sixam_mart/api/api_client.dart';
import 'package:sixam_mart/features/rental_module/rental_favourite/domain/repositories/taxi_favourite_repository_interface.dart';

class TaxiFavouriteRepository implements TaxiFavouriteRepositoryInterface {
  final ApiClient apiClient;
  final SharedPreferences sharedPreferences;

  TaxiFavouriteRepository({
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
