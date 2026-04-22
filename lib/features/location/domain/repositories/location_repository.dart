import 'package:get/get_connect/http/src/response/response.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:sixam_mart/api/api_client.dart';
import 'package:sixam_mart/features/location/domain/models/zone_model.dart';
import 'package:sixam_mart/features/location/domain/models/zone_response_model.dart';
import 'package:sixam_mart/features/location/domain/repositories/location_repository_interface.dart';
import 'package:sixam_mart/util/app_constants.dart';
import 'package:sixam_mart/common/widgets/custom_snackbar.dart';

class LocationRepository implements LocationRepositoryInterface {
  final ApiClient apiClient;

  LocationRepository({required this.apiClient});

  @override
  Future<String> getAddressFromGeocode(LatLng latLng) async {
    Response response = await apiClient.getData(
      '${AppConstants.geocodeUri}?lat=${latLng.latitude}&lng=${latLng.longitude}&language=ka',
      handleError: false,
    );
    String address = 'მდებარეობა ვერ მოიძებნა';
    if (response.statusCode == 200 && response.body['status'] == 'OK') {
      address = response.body['results'][0]['formatted_address'].toString();
      // Remove Plus Code prefix (e.g. "GC27+X4 " or "GC27+X4, ")
      address = address
          .replaceAll(RegExp(r'^[A-Z0-9]{2,8}\+[A-Z0-9]{2,3}[,\s]*'), '')
          .trim();
    } else {
      showCustomSnackBar(response.body['error_message'] ?? response.bodyString);
    }
    return address;
  }

  @override
  Future<ZoneResponseModel> getZone(
    String? lat,
    String? lng, {
    bool handleError = false,
  }) async {
    Response response = await apiClient.getData(
      '${AppConstants.zoneUri}?lat=$lat&lng=$lng',
      handleError: handleError,
    );
    if (response.statusCode == 200) {
      ZoneResponseModel responseModel;
      List<int>? zoneIds = ZoneModel.fromJson(response.body).zoneIds;
      List<ZoneData>? zoneData = ZoneModel.fromJson(response.body).zoneData;
      responseModel = ZoneResponseModel(
        true,
        '',
        zoneIds ?? [],
        zoneData ?? [],
        [],
        response.statusCode,
      );
      return responseModel;
    } else {
      return ZoneResponseModel(
        false,
        response.statusText,
        [],
        [],
        [],
        response.statusCode,
      );
    }
  }

  @override
  Future<Response> searchLocation(String text) async {
    return await apiClient.getData(
      '${AppConstants.searchLocationUri}?search_text=$text',
    );
  }

  @override
  Future add(value) {
    throw UnimplementedError();
  }

  @override
  Future delete(int? id) {
    throw UnimplementedError();
  }

  @override
  Future<Response> get(String? id) async {
    Response response = await apiClient.getData(
      '${AppConstants.placeDetailsUri}?placeid=$id',
    );
    return response;
  }

  @override
  Future getList({int? offset}) {
    throw UnimplementedError();
  }

  @override
  Future update(Map<String, dynamic> body, int? id) {
    throw UnimplementedError();
  }
}
