import 'package:get/get_connect/http/src/response/response.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:sixam_mart/api/api_client.dart';
import 'package:sixam_mart/features/checkout/domain/models/place_order_body_model.dart';
import 'package:sixam_mart/features/checkout/domain/models/surge_price_model.dart';
import 'package:sixam_mart/features/payment/domain/models/offline_method_model.dart';
import 'package:sixam_mart/interfaces/repository_interface.dart';

abstract class CheckoutRepositoryInterface implements RepositoryInterface {
  Future<int> getDmTipMostTapped();
  Future<bool> saveSharedPrefDmTipIndex(String index);
  String getSharedPrefDmTipIndex();
  Future<Response> getDistanceInMeter(LatLng originLatLng, LatLng destinationLatLng);
  Future<double> getExtraCharge(double? distance);
  Future<Response> placeOrder(PlaceOrderBodyModel orderBody, List<MultipartBody>? orderAttachment);
  Future<Response> placePrescriptionOrder(
    int? storeId,
    double? distance,
    String address,
    String longitude,
    String latitude,
    String note,
    List<MultipartBody> orderAttachment,
    String dmTips,
    String deliveryInstruction,
  );
  @override
  Future<List<OfflineMethodModel>?> getList({int? offset});
  Future<Response> getOrderTax(PlaceOrderBodyModel orderBody);
  Future<SurgePriceModel?> getSurgePrice({
    required String zoneId,
    required String moduleId,
    required String dateTime,
    String? guestId,
  });
}
