import 'dart:async';
import 'package:sixam_mart/common/models/response_model.dart';
import 'package:sixam_mart/features/auth/domain/enum/centralize_login_enum.dart';
import 'package:sixam_mart/features/auth/screens/new_user_setup_screen.dart';
import 'package:sixam_mart/features/auth/widgets/sign_in/existing_user_bottom_sheet.dart';
import 'package:sixam_mart/features/location/controllers/location_controller.dart';
import 'package:sixam_mart/features/profile/controllers/profile_controller.dart';
import 'package:sixam_mart/features/profile/domain/models/update_user_model.dart';
import 'package:sixam_mart/features/splash/controllers/splash_controller.dart';
import 'package:sixam_mart/features/auth/controllers/auth_controller.dart';
import 'package:sixam_mart/features/verification/controllers/verification_controller.dart';
import 'package:sixam_mart/features/verification/domein/enum/verification_type_enum.dart';
import 'package:sixam_mart/features/verification/domein/models/verification_data_model.dart';
import 'package:sixam_mart/features/verification/screens/new_pass_screen.dart';
import 'package:sixam_mart/helper/auth_helper.dart';
import 'package:sixam_mart/helper/responsive_helper.dart';
import 'package:sixam_mart/helper/route_helper.dart';
import 'package:sixam_mart/util/dimensions.dart';
import 'package:sixam_mart/util/styles.dart';
import 'package:sixam_mart/common/widgets/custom_app_bar.dart';
import 'package:sixam_mart/common/widgets/custom_snackbar.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:pin_code_fields/pin_code_fields.dart';

class VerificationScreen extends StatefulWidget {
  final String? number;
  final String? email;
  final bool fromSignUp;
  final String? token;
  final String? password;
  final String loginType;
  final String? firebaseSession;
  final bool fromForgetPassword;
  final UpdateUserModel? userModel;
  final bool backFromThis;
  const VerificationScreen({
    super.key,
    required this.number,
    required this.password,
    required this.fromSignUp,
    required this.token,
    this.email,
    required this.loginType,
    this.firebaseSession,
    required this.fromForgetPassword,
    this.userModel,
    this.backFromThis = false,
  });

  @override
  VerificationScreenState createState() => VerificationScreenState();
}

class VerificationScreenState extends State<VerificationScreen> {
  String? _number;
  String? _email;
  Timer? _timer;
  int _seconds = 0;
  late StreamController<ErrorAnimationType> errorController;

  bool hasError = false;
  String errorMessage = "";

  @override
  void initState() {
    super.initState();

    Get.find<VerificationController>().updateVerificationCode(
      '',
      canUpdate: false,
    );
    if (widget.number != null && widget.number!.isNotEmpty) {
      _number = widget.number!.startsWith('+')
          ? widget.number
          : '+${widget.number!.substring(1, widget.number!.length)}';
    }
    _email = widget.email;
    _startTimer();

    errorController = StreamController<ErrorAnimationType>();
  }

  void _startTimer() {
    _seconds = 60;
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      _seconds = _seconds - 1;
      if (_seconds == 0) {
        timer.cancel();
        _timer?.cancel();
      }
      setState(() {});
    });
  }

  @override
  void dispose() {
    super.dispose();

    _timer?.cancel();
    errorController.close();
  }

  @override
  Widget build(BuildContext context) {
    final bool isDesktop = ResponsiveHelper.isDesktop(context);
    final bool isEmailVerification = _email != null && _email!.isNotEmpty;
    final double screenHorizontalPadding = context.width > 700
        ? Dimensions.paddingSizeDefault
        : Dimensions.paddingSizeDefault;
    final double contentWidth = context.width > 700
        ? 500
        : context.width - (screenHorizontalPadding * 2);
    final double pinFieldWidth = ((contentWidth - 54) / 6)
        .clamp(38.0, 46.0)
        .toDouble();
    const double borderWidth = 0.8;

    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: isDesktop
          ? null
          : CustomAppBar(
              title: isEmailVerification
                  ? 'email_verification'.tr
                  : 'phone_verification'.tr,
            ),
      backgroundColor: isDesktop
          ? Colors.transparent
          : Theme.of(context).cardColor,
      body: SafeArea(
        child: Stack(
          children: [
            const _VerificationThemeBackground(),
            LayoutBuilder(
              builder: (context, constraints) {
                return Center(
                  child: Padding(
                    padding: EdgeInsets.symmetric(
                      horizontal: screenHorizontalPadding,
                      vertical: Dimensions.paddingSizeSmall,
                    ),
                    child: SizedBox(
                      width: contentWidth,
                      height: constraints.maxHeight,
                      child: FittedBox(
                        fit: BoxFit.scaleDown,
                        alignment: Alignment.center,
                        child: SizedBox(
                          width: contentWidth,
                          child: Container(
                            padding: context.width > 700
                                ? const EdgeInsets.all(
                                    Dimensions.paddingSizeLarge,
                                  )
                                : EdgeInsets.zero,
                            decoration: context.width > 700
                                ? BoxDecoration(
                                    color: Theme.of(context).cardColor,
                                    borderRadius: BorderRadius.circular(
                                      Dimensions.radiusDefault,
                                    ),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Theme.of(
                                          context,
                                        ).shadowColor.withValues(alpha: 0.08),
                                        blurRadius: 24,
                                        offset: const Offset(0, 14),
                                      ),
                                    ],
                                  )
                                : null,
                            child: GetBuilder<VerificationController>(
                              builder: (verificationController) {
                                return Column(
                                  mainAxisSize: MainAxisSize.min,
                                  crossAxisAlignment:
                                      CrossAxisAlignment.stretch,
                                  children: [
                                    if (isDesktop) ...[
                                      Align(
                                        alignment: Alignment.topRight,
                                        child: IconButton(
                                          onPressed: () => Get.back(),
                                          icon: const Icon(Icons.clear),
                                        ),
                                      ),
                                      Padding(
                                        padding: const EdgeInsets.only(
                                          bottom: Dimensions.paddingSizeLarge,
                                        ),
                                        child: Text(
                                          isEmailVerification
                                              ? 'email_verification'.tr
                                              : 'phone_verification'.tr,
                                          style: robotoMedium.copyWith(
                                            fontSize: Dimensions.fontSizeLarge,
                                          ),
                                          textAlign: TextAlign.center,
                                        ),
                                      ),
                                    ],

                                    _VerificationHero(
                                      isEmailVerification: isEmailVerification,
                                    ),
                                    const SizedBox(
                                      height: Dimensions.paddingSizeDefault,
                                    ),

                                    Text(
                                      'enter_code'.tr,
                                      textAlign: TextAlign.center,
                                      style: robotoBold.copyWith(
                                        fontSize: Dimensions.fontSizeOverLarge,
                                        height: 1.15,
                                        color: Theme.of(
                                          context,
                                        ).textTheme.bodyLarge!.color,
                                      ),
                                    ),
                                    const SizedBox(
                                      height: Dimensions.paddingSizeExtraSmall,
                                    ),

                                    Get.find<SplashController>()
                                            .configModel!
                                            .demo!
                                        ? Text(
                                            'for_demo_purpose'.tr,
                                            style: robotoMedium.copyWith(
                                              fontSize:
                                                  Dimensions.fontSizeSmall,
                                            ),
                                            textAlign: TextAlign.center,
                                          )
                                        : _VerificationDestinationText(
                                            isEmailVerification:
                                                isEmailVerification,
                                            destination: isEmailVerification
                                                ? _email
                                                : _number,
                                          ),
                                    const SizedBox(
                                      height: Dimensions.paddingSizeDefault,
                                    ),

                                    Padding(
                                      padding: const EdgeInsets.symmetric(
                                        vertical:
                                            Dimensions.paddingSizeExtraSmall,
                                      ),
                                      child: PinCodeTextField(
                                        length: 6,
                                        appContext: context,
                                        keyboardType: TextInputType.number,
                                        animationType: AnimationType.fade,
                                        pinTheme: PinTheme(
                                          shape: PinCodeFieldShape.box,
                                          fieldHeight: 50,
                                          fieldWidth: pinFieldWidth,
                                          borderWidth: borderWidth,
                                          borderRadius: BorderRadius.circular(
                                            Dimensions.radiusDefault,
                                          ),
                                          selectedColor: Theme.of(
                                            context,
                                          ).primaryColor,
                                          selectedFillColor: Theme.of(
                                            context,
                                          ).cardColor,
                                          inactiveFillColor: Theme.of(
                                            context,
                                          ).cardColor,
                                          inactiveColor: Theme.of(context)
                                              .disabledColor
                                              .withValues(alpha: 0.55),
                                          activeColor: hasError
                                              ? Colors.orange
                                              : Theme.of(context).primaryColor
                                                    .withValues(alpha: 0.4),
                                          activeFillColor: Theme.of(
                                            context,
                                          ).cardColor,
                                          inactiveBorderWidth: borderWidth,
                                          selectedBorderWidth: 1.2,
                                          disabledBorderWidth: borderWidth,
                                          errorBorderWidth: borderWidth,
                                          activeBorderWidth: borderWidth,
                                        ),
                                        animationDuration: const Duration(
                                          milliseconds: 220,
                                        ),
                                        backgroundColor: Colors.transparent,
                                        enableActiveFill: true,
                                        textStyle: robotoMedium.copyWith(
                                          fontSize: Dimensions.fontSizeLarge,
                                          color: Theme.of(context).primaryColor,
                                        ),
                                        cursorColor: Theme.of(
                                          context,
                                        ).primaryColor,
                                        onChanged: verificationController
                                            .updateVerificationCode,
                                        beforeTextPaste: (text) => true,
                                        errorAnimationController:
                                            errorController,
                                        errorTextSpace: 20,
                                        errorTextMargin: const EdgeInsets.only(
                                          top: 10,
                                        ),
                                      ),
                                    ),

                                    Text(
                                      hasError ? errorMessage : '',
                                      textAlign: TextAlign.center,
                                      style: robotoRegular.copyWith(
                                        color: Colors.red,
                                        fontSize: Dimensions.fontSizeSmall,
                                      ),
                                    ),
                                    const SizedBox(
                                      height: Dimensions.paddingSizeSmall,
                                    ),

                                    GetBuilder<ProfileController>(
                                      builder: (profileController) {
                                        return _VerificationSubmitButton(
                                          isLoading:
                                              verificationController
                                                  .isLoading ||
                                              profileController.isLoading,
                                          onPressed: _verifyPressed(
                                            verificationController,
                                          ),
                                        );
                                      },
                                    ),
                                    const SizedBox(
                                      height: Dimensions.paddingSizeSmall,
                                    ),

                                    const _SecureAuthorizationCard(),
                                    const SizedBox(
                                      height: Dimensions.paddingSizeDefault,
                                    ),

                                    _ResendCodeSection(
                                      seconds: _seconds,
                                      onResend: _seconds < 1
                                          ? _resendCode
                                          : null,
                                    ),
                                    const SizedBox(
                                      height: Dimensions.paddingSizeDefault,
                                    ),

                                    const _VerificationSupportCard(),
                                  ],
                                );
                              },
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  VoidCallback? _verifyPressed(VerificationController verificationController) {
    if (verificationController.verificationCode.length < 6) {
      return null;
    }

    return () {
      if (widget.firebaseSession != null && widget.userModel == null) {
        verificationController
            .verifyFirebaseOtp(
              phoneNumber: _number!,
              session: widget.firebaseSession!,
              loginType: widget.loginType,
              otp: verificationController.verificationCode,
              token: widget.token,
              isForgetPassPage: widget.fromForgetPassword,
              isSignUpPage: widget.loginType == CentralizeLoginType.otp.name
                  ? false
                  : true,
            )
            .then((value) {
              if (value.isSuccess) {
                _handleVerifyResponse(value, _number, _email);
              } else {
                showCustomSnackBar(value.message);
              }
            });
      } else if (widget.userModel != null) {
        widget.userModel!.otp = verificationController.verificationCode;
        Get.find<ProfileController>().updateUserInfo(
          widget.userModel!,
          Get.find<AuthController>().getUserToken(),
          fromButton: true,
        );
      } else if (widget.fromSignUp) {
        verificationController
            .verifyPhone(
              data: VerificationDataModel(
                phone: _number,
                email: _email,
                verificationType: _number != null
                    ? VerificationTypeEnum.phone.name
                    : VerificationTypeEnum.email.name,
                otp: verificationController.verificationCode,
                loginType: widget.loginType,
                guestId: AuthHelper.getGuestId(),
              ),
            )
            .then((value) {
              if (value.isSuccess) {
                _handleVerifyResponse(value, _number, _email);
              } else {
                showCustomSnackBar(value.message);
              }
            });
      } else {
        verificationController.verifyToken(phone: _number, email: _email).then((
          value,
        ) {
          if (value.isSuccess) {
            if (ResponsiveHelper.isDesktop(Get.context!)) {
              Get.back();
              Get.dialog(
                Center(
                  child: NewPassScreen(
                    resetToken: verificationController.verificationCode,
                    number: _number,
                    email: _email,
                    fromPasswordChange: false,
                    fromDialog: true,
                  ),
                ),
              );
            } else {
              Get.toNamed(
                RouteHelper.getResetPasswordRoute(
                  phone: _number,
                  email: _email,
                  token: verificationController.verificationCode,
                  page: 'reset-password',
                ),
              );
            }
          } else {
            errorController.add(ErrorAnimationType.shake);
            errorMessage = value.message ?? '';
            setState(() {
              hasError = true;
            });
            showCustomSnackBar(value.message);
          }
        });
      }
    };
  }

  Future<void> _resendCode() async {
    if (widget.firebaseSession != null) {
      await Get.find<AuthController>().firebaseVerifyPhoneNumber(
        _number!,
        widget.token,
        widget.loginType,
        fromSignUp: widget.fromSignUp,
        canRoute: false,
      );
      _startTimer();
    } else {
      _resendOtp();
    }
  }

  void _handleVerifyResponse(
    ResponseModel response,
    String? number,
    String? email,
  ) {
    if (response.authResponseModel != null &&
        response.authResponseModel!.isExistUser != null) {
      if (ResponsiveHelper.isDesktop(context)) {
        Get.back();
        Get.dialog(
          Center(
            child: ExistingUserBottomSheet(
              userModel: response.authResponseModel!.isExistUser!,
              number: _number,
              email: _email,
              loginType: widget.loginType,
              otp: Get.find<VerificationController>().verificationCode,
              backFromThis: widget.backFromThis,
            ),
          ),
        );
      } else {
        Get.bottomSheet(
          ExistingUserBottomSheet(
            userModel: response.authResponseModel!.isExistUser!,
            number: _number,
            email: _email,
            loginType: widget.loginType,
            otp: Get.find<VerificationController>().verificationCode,
            backFromThis: widget.backFromThis,
          ),
        );
      }
    } else if (response.authResponseModel != null &&
        !response.authResponseModel!.isPersonalInfo!) {
      if (ResponsiveHelper.isDesktop(context)) {
        Get.back();
        Get.dialog(
          NewUserSetupScreen(
            name: '',
            loginType: widget.loginType,
            phone: number,
            email: email,
            backFromThis: widget.backFromThis,
          ),
        );
      } else {
        Get.toNamed(
          RouteHelper.getNewUserSetupScreen(
            name: '',
            loginType: widget.loginType,
            phone: number,
            email: email,
            backFromThis: widget.backFromThis,
          ),
        );
      }
    } else {
      if (widget.fromForgetPassword) {
        Get.toNamed(
          RouteHelper.getResetPasswordRoute(
            phone: _number,
            email: _email,
            token: Get.find<VerificationController>().verificationCode,
            page: 'reset-password',
          ),
        );
      } else {
        if (widget.backFromThis) {
          Get.find<LocationController>().syncZoneData();
          Get.back();
          Get.back();
        } else {
          Get.find<LocationController>().navigateToLocationScreen(
            'verification',
            offNamed: true,
          );
        }
      }
    }
  }

  void _resendOtp() {
    if (widget.userModel != null) {
      Get.find<ProfileController>().updateUserInfo(
        widget.userModel!,
        Get.find<AuthController>().getUserToken(),
        fromVerification: true,
      );
    } else if (widget.fromSignUp) {
      if (widget.loginType == CentralizeLoginType.otp.name) {
        Get.find<AuthController>()
            .otpLogin(
              phone: _number!,
              otp: '',
              loginType: widget.loginType,
              verified: '',
            )
            .then((response) {
              if (response.isSuccess) {
                _startTimer();
                showCustomSnackBar('resend_code_successful'.tr, isError: false);
              } else {
                showCustomSnackBar(response.message);
              }
            });
      } else {
        Get.find<AuthController>()
            .login(
              emailOrPhone: _number != null ? _number! : _email ?? '',
              password: widget.password!,
              loginType: widget.loginType,
              fieldType: _number != null
                  ? VerificationTypeEnum.phone.name
                  : VerificationTypeEnum.email.name,
            )
            .then((value) {
              if (value.isSuccess) {
                _startTimer();
                showCustomSnackBar('resend_code_successful'.tr, isError: false);
              } else {
                showCustomSnackBar(value.message);
              }
            });
      }
    } else {
      Get.find<VerificationController>()
          .forgetPassword(phone: _number, email: _email)
          .then((value) {
            if (value.isSuccess) {
              _startTimer();
              showCustomSnackBar('resend_code_successful'.tr, isError: false);
            } else {
              showCustomSnackBar(value.message);
            }
          });
    }
  }
}

class _VerificationThemeBackground extends StatelessWidget {
  const _VerificationThemeBackground();

  @override
  Widget build(BuildContext context) {
    final Color primaryColor = Theme.of(context).primaryColor;

    return IgnorePointer(
      child: Stack(
        children: [
          Positioned(
            top: 62,
            left: -42,
            child: Container(
              height: 150,
              width: 150,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: primaryColor.withValues(alpha: 0.035),
              ),
            ),
          ),
          Positioned(
            top: 160,
            right: -28,
            child: Icon(
              Icons.verified_user_outlined,
              size: 112,
              color: primaryColor.withValues(alpha: 0.045),
            ),
          ),
          Positioned(
            bottom: 112,
            left: -20,
            child: Icon(
              Icons.shopping_bag_outlined,
              size: 94,
              color: primaryColor.withValues(alpha: 0.04),
            ),
          ),
        ],
      ),
    );
  }
}

class _VerificationHero extends StatelessWidget {
  final bool isEmailVerification;

  const _VerificationHero({required this.isEmailVerification});

  @override
  Widget build(BuildContext context) {
    final Color primaryColor = Theme.of(context).primaryColor;

    return SizedBox(
      height: 126,
      child: Stack(
        alignment: Alignment.center,
        children: [
          Positioned(
            left: 28,
            bottom: 18,
            child: Icon(
              Icons.shield_outlined,
              size: 60,
              color: primaryColor.withValues(alpha: 0.055),
            ),
          ),
          Positioned(
            right: 42,
            top: 36,
            child: Icon(
              Icons.cloud_outlined,
              size: 38,
              color: primaryColor.withValues(alpha: 0.06),
            ),
          ),
          Container(
            height: 98,
            width: 66,
            decoration: BoxDecoration(
              color: Theme.of(context).cardColor,
              borderRadius: BorderRadius.circular(18),
              border: Border.all(
                color: primaryColor.withValues(alpha: 0.38),
                width: 4,
              ),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  height: 12,
                  width: 28,
                  decoration: BoxDecoration(
                    color: primaryColor.withValues(alpha: 0.24),
                    borderRadius: const BorderRadius.only(
                      bottomLeft: Radius.circular(10),
                      bottomRight: Radius.circular(10),
                    ),
                  ),
                ),
                Icon(
                  isEmailVerification
                      ? Icons.mark_email_read_outlined
                      : Icons.phone_iphone_rounded,
                  size: 24,
                  color: primaryColor.withValues(alpha: 0.28),
                ),
                Container(
                  height: 4,
                  width: 20,
                  margin: const EdgeInsets.only(bottom: 10),
                  decoration: BoxDecoration(
                    color: primaryColor.withValues(alpha: 0.28),
                    borderRadius: BorderRadius.circular(20),
                  ),
                ),
              ],
            ),
          ),
          Positioned(
            right: 70,
            bottom: 34,
            child: Container(
              height: 42,
              width: 104,
              padding: const EdgeInsets.symmetric(horizontal: 12),
              decoration: BoxDecoration(
                color: primaryColor,
                borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
                boxShadow: [
                  BoxShadow(
                    color: primaryColor.withValues(alpha: 0.18),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.lock_outline_rounded,
                    color: Colors.white,
                    size: 18,
                  ),
                  const SizedBox(width: Dimensions.paddingSizeExtraSmall),
                  Text(
                    '***',
                    style: robotoBold.copyWith(
                      color: Colors.white,
                      fontSize: Dimensions.fontSizeLarge,
                    ),
                  ),
                ],
              ),
            ),
          ),
          Positioned(
            right: 52,
            top: 30,
            child: Icon(Icons.done_all_rounded, color: primaryColor, size: 24),
          ),
        ],
      ),
    );
  }
}

class _VerificationDestinationText extends StatelessWidget {
  final bool isEmailVerification;
  final String? destination;

  const _VerificationDestinationText({
    required this.isEmailVerification,
    required this.destination,
  });

  @override
  Widget build(BuildContext context) {
    final String copy = isEmailVerification
        ? 'we_have_a_verification_code'.tr
        : 'verification_code_sent_to_number'.tr;

    return RichText(
      textAlign: TextAlign.center,
      text: TextSpan(
        children: [
          TextSpan(
            text: '$copy\n',
            style: robotoRegular.copyWith(
              color: Theme.of(context).hintColor,
              fontSize: Dimensions.fontSizeSmall,
              height: 1.30,
            ),
          ),
          TextSpan(
            text: destination ?? '',
            style: robotoBold.copyWith(
              color: Theme.of(context).primaryColor,
              fontSize: Dimensions.fontSizeSmall,
              height: 1.30,
            ),
          ),
        ],
      ),
    );
  }
}

class _SecureAuthorizationCard extends StatelessWidget {
  const _SecureAuthorizationCard();

  @override
  Widget build(BuildContext context) {
    final Color primaryColor = Theme.of(context).primaryColor;

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: Dimensions.paddingSizeSmall,
        vertical: Dimensions.paddingSizeSmall,
      ),
      decoration: BoxDecoration(
        color: primaryColor.withValues(alpha: 0.06),
        borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
      ),
      child: Row(
        children: [
          Container(
            height: 34,
            width: 34,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: primaryColor,
              boxShadow: [
                BoxShadow(
                  color: primaryColor.withValues(alpha: 0.22),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: const Icon(
              Icons.verified_user_outlined,
              color: Colors.white,
              size: 18,
            ),
          ),
          const SizedBox(width: Dimensions.paddingSizeSmall),
          Expanded(
            child: Text(
              'safe_secure_authorization'.tr,
              style: robotoBold.copyWith(
                color: primaryColor,
                fontSize: Dimensions.fontSizeSmall,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}

class _VerificationSubmitButton extends StatelessWidget {
  final bool isLoading;
  final VoidCallback? onPressed;

  const _VerificationSubmitButton({
    required this.isLoading,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    final Color primaryColor = Theme.of(context).primaryColor;
    final bool isEnabled = onPressed != null && !isLoading;

    return TextButton(
      onPressed: isLoading ? null : onPressed,
      style: TextButton.styleFrom(
        minimumSize: const Size(double.infinity, 50),
        padding: EdgeInsets.zero,
        backgroundColor: isEnabled ? primaryColor : const Color(0xff93A2AE),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
        ),
      ),
      child: isLoading
          ? Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const SizedBox(
                  height: 18,
                  width: 18,
                  child: CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                    strokeWidth: 2,
                  ),
                ),
                const SizedBox(width: Dimensions.paddingSizeSmall),
                Text(
                  'loading'.tr,
                  style: robotoMedium.copyWith(color: Colors.white),
                ),
              ],
            )
          : Stack(
              alignment: Alignment.center,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(
                      Icons.lock_outline_rounded,
                      color: Colors.white,
                      size: 20,
                    ),
                    const SizedBox(width: Dimensions.paddingSizeSmall),
                    Flexible(
                      child: Text(
                        'verify'.tr,
                        textAlign: TextAlign.center,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: robotoBold.copyWith(
                          color: Colors.white,
                          fontSize: Dimensions.fontSizeDefault,
                        ),
                      ),
                    ),
                  ],
                ),
                const Positioned(
                  right: 20,
                  child: Icon(
                    Icons.arrow_forward_rounded,
                    color: Colors.white,
                    size: 24,
                  ),
                ),
              ],
            ),
    );
  }
}

class _ResendCodeSection extends StatelessWidget {
  final int seconds;
  final Future<void> Function()? onResend;

  const _ResendCodeSection({required this.seconds, required this.onResend});

  @override
  Widget build(BuildContext context) {
    final String resendText =
        '${'resent_it'.tr}${seconds > 0 ? ' (${seconds}s)' : ''}';

    return Column(
      children: [
        Text(
          'did_not_receive_the_code'.tr,
          textAlign: TextAlign.center,
          style: robotoRegular.copyWith(
            color: Theme.of(context).hintColor,
            fontSize: Dimensions.fontSizeExtraSmall,
          ),
        ),
        TextButton(
          onPressed: onResend,
          child: Text(
            resendText,
            textAlign: TextAlign.center,
            style: robotoBold.copyWith(
              color: onResend == null
                  ? Theme.of(context).disabledColor
                  : Theme.of(context).primaryColor,
              fontSize: Dimensions.fontSizeSmall,
            ),
          ),
        ),
      ],
    );
  }
}

class _VerificationSupportCard extends StatelessWidget {
  const _VerificationSupportCard();

  @override
  Widget build(BuildContext context) {
    final Color primaryColor = Theme.of(context).primaryColor;

    return InkWell(
      onTap: () => Get.toNamed(RouteHelper.getSupportRoute()),
      borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
      child: Container(
        padding: const EdgeInsets.all(Dimensions.paddingSizeSmall),
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
          borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
          border: Border.all(
            color: Theme.of(context).disabledColor.withValues(alpha: 0.12),
          ),
          boxShadow: [
            BoxShadow(
              color: Theme.of(context).shadowColor.withValues(alpha: 0.06),
              blurRadius: 18,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 38,
              height: 38,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: primaryColor.withValues(alpha: 0.12),
              ),
              child: Icon(
                Icons.headset_mic_outlined,
                color: primaryColor,
                size: 22,
              ),
            ),
            const SizedBox(width: Dimensions.paddingSizeSmall),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'need_help'.tr,
                    style: robotoBold.copyWith(
                      color: Theme.of(context).textTheme.bodyLarge!.color,
                      fontSize: Dimensions.fontSizeSmall,
                    ),
                  ),
                  const SizedBox(height: Dimensions.paddingSizeExtraSmall),
                  Text(
                    'contact_support_for_help'.tr,
                    style: robotoRegular.copyWith(
                      color: Theme.of(context).hintColor,
                      fontSize: Dimensions.fontSizeExtraSmall,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            Icon(
              Icons.chevron_right_rounded,
              color: Theme.of(context).hintColor,
              size: 30,
            ),
          ],
        ),
      ),
    );
  }
}
