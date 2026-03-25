import 'package:shared_preferences/shared_preferences.dart';
import 'package:sixam_mart/api/api_client.dart';
import 'package:sixam_mart/common/models/module_model.dart';
import 'package:sixam_mart/features/auth/domain/models/delivery_man_body.dart';
import 'package:sixam_mart/features/auth/domain/models/delivery_man_vehicles_model.dart';
import 'package:sixam_mart/features/auth/domain/reposotories/deliveryman_registration_repository_interface.dart';
import 'package:sixam_mart/features/location/domain/models/zone_data_model.dart';
import 'package:sixam_mart/util/app_constants.dart';

class DeliverymanRegistrationRepository implements DeliverymanRegistrationRepositoryInterface {
  final ApiClient apiClient;
  final SharedPreferences sharedPreferences;

  DeliverymanRegistrationRepository({
    required this.apiClient,
    required this.sharedPreferences,
  });

  @override
  Future<dynamic> getList({int? offset, bool isZone = true, bool isVehicle = false, int? zoneId}) async {
    if (isVehicle) {
      final response = await apiClient.getData(AppConstants.vehicleListUri);
      if (response.statusCode == 200) {
        return (response.body as List).map((data) => DeliveryManVehicleModel.fromJson(data)).toList();
      }
      return <DeliveryManVehicleModel>[];
    }

    if (isZone) {
      final response = await apiClient.getData(AppConstants.zoneListUri);
      if (response.statusCode == 200) {
        return (response.body as List).map((data) => ZoneDataModel.fromJson(data)).toList();
      }
      return <ZoneDataModel>[];
    }

    final response = await apiClient.getData('${AppConstants.moduleUri}?zone_id=${zoneId ?? 0}');
    if (response.statusCode == 200) {
      return (response.body as List).map((data) => ModuleModel.fromJson(data)).toList();
    }
    return <ModuleModel>[];
  }

  @override
  Future<bool> registerDeliveryMan(DeliveryManBody deliveryManBody, List<MultipartBody> multiParts) async {
    final response = await apiClient.postMultipartData(
      AppConstants.dmRegisterUri,
      deliveryManBody.toJson(),
      multiParts,
    );
    return response.statusCode == 200;
  }

  @override
  Future add(value) async {}

  @override
  Future delete(int? id) async {}

  @override
  Future get(String? id) async {}

  @override
  Future update(Map<String, dynamic> body, int? id) async {}
}
