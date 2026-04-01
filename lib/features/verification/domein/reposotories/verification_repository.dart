import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sixam_mart/api/api_client.dart';
import 'package:sixam_mart/common/models/response_model.dart';
import 'package:sixam_mart/features/verification/domein/models/verification_data_model.dart';
import 'package:sixam_mart/features/verification/domein/reposotories/verification_repository_interface.dart';
import 'package:sixam_mart/util/app_constants.dart';

class VerificationRepository implements VerificationRepositoryInterface {
  final ApiClient apiClient;
  final SharedPreferences sharedPreferences;

  VerificationRepository({
    required this.apiClient,
    required this.sharedPreferences,
  });

  @override
  Future<ResponseModel> forgetPassword({String? phone, String? email}) async {
    final String verificationMethod = _getVerificationMethod(
      phone: phone,
      email: email,
    );
    final response = await apiClient.postData(AppConstants.forgetPasswordUri, {
      'phone': phone,
      'email': email,
      'verification_method': verificationMethod,
    }, handleError: false);
    return ResponseModel(
      response.statusCode == 200,
      response.body?['message'] ?? response.statusText,
    );
  }

  @override
  Future<ResponseModel> verifyToken({
    String? phone,
    String? email,
    required String token,
  }) async {
    final String verificationMethod = _getVerificationMethod(
      phone: phone,
      email: email,
    );
    final response = await apiClient.postData(AppConstants.verifyTokenUri, {
      'phone': phone,
      'email': email,
      'reset_token': token,
      'verification_method': verificationMethod,
    }, handleError: false);
    return ResponseModel(
      response.statusCode == 200,
      response.body?['message'] ?? response.statusText,
    );
  }

  @override
  Future<ResponseModel> resetPassword({
    String? resetToken,
    String? phone,
    String? email,
    required String password,
    required String confirmPassword,
  }) async {
    final String verificationMethod = _getVerificationMethod(
      phone: phone,
      email: email,
    );
    final Map<String, dynamic> requestBody = {
      'reset_token': resetToken,
      'phone': phone,
      'email': email,
      'verification_method': verificationMethod,
      'password': password,
      'confirm_password': confirmPassword,
    };
    requestBody.removeWhere((key, value) => !_hasValue(value?.toString()));
    final response = await apiClient.putData(
      AppConstants.resetPasswordUri,
      requestBody,
      handleError: false,
    );
    return ResponseModel(
      response.statusCode == 200,
      response.body?['message'] ?? response.statusText,
    );
  }

  @override
  Future<Response> verifyPhone(VerificationDataModel data) async {
    return apiClient.postData(
      AppConstants.verifyPhoneUri,
      data.toJson(),
      handleError: false,
    );
  }

  @override
  Future<ResponseModel> verifyFirebaseOtp({
    required String phoneNumber,
    required String session,
    required String otp,
    required String loginType,
  }) async {
    final response = await apiClient.postData(AppConstants.firebaseAuthVerify, {
      'phone': phoneNumber,
      'session': session,
      'otp': otp,
      'login_type': loginType,
    }, handleError: false);
    return ResponseModel(
      response.statusCode == 200,
      response.body?['message'] ?? response.statusText,
    );
  }

  @override
  Future<ResponseModel> verifyForgetPassFirebaseOtp({
    required String phoneNumber,
    required String session,
    required String otp,
  }) async {
    final response = await apiClient.postData(
      AppConstants.firebaseResetPassword,
      {'phone': phoneNumber, 'session': session, 'otp': otp},
      handleError: false,
    );
    return ResponseModel(
      response.statusCode == 200,
      response.body?['message'] ?? response.statusText,
    );
  }

  @override
  Future add(value) async {}

  @override
  Future delete(int? id) async {}

  @override
  Future get(String? id) async {}

  @override
  Future getList({int? offset}) async {}

  @override
  Future update(Map<String, dynamic> body, int? id) async {}

  String _getVerificationMethod({String? phone, String? email}) {
    if (_hasValue(phone)) {
      return 'phone';
    }
    if (_hasValue(email)) {
      return 'email';
    }
    return '';
  }

  bool _hasValue(String? value) {
    if (value == null) {
      return false;
    }
    final String normalizedValue = value.trim().toLowerCase();
    return normalizedValue.isNotEmpty && normalizedValue != 'null';
  }
}
