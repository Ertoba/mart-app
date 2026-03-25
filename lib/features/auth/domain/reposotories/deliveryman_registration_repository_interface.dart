import 'package:sixam_mart/api/api_client.dart';
import 'package:sixam_mart/features/auth/domain/models/delivery_man_body.dart';
import 'package:sixam_mart/interfaces/repository_interface.dart';

abstract class DeliverymanRegistrationRepositoryInterface implements RepositoryInterface {
  @override
  Future<dynamic> getList({int? offset, bool isZone = true, bool isVehicle = false, int? zoneId});
  Future<bool> registerDeliveryMan(DeliveryManBody deliveryManBody, List<MultipartBody> multiParts);
}
