import 'package:country_code_picker/country_code_picker.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:sixam_mart/features/auth/widgets/mili_auth_ui.dart';
import 'package:flutter/services.dart';
import 'package:sixam_mart/features/auth/controllers/auth_controller.dart';
import 'package:sixam_mart/features/auth/widgets/social_login_widget.dart';
import 'package:sixam_mart/features/language/controllers/language_controller.dart';
import 'package:sixam_mart/helper/validate_check.dart';

class OtpLoginWidget extends StatelessWidget {
  final TextEditingController phoneController;
  final FocusNode phoneFocus;
  final String? countryDialCode;
  final Function(CountryCode countryCode)? onCountryChanged;
  final Function() onClickLoginButton;
  final Function()? onManualViewClick;
  final bool socialEnable;
  final bool backFromThis;
  const OtpLoginWidget({
    super.key,
    required this.phoneController,
    required this.phoneFocus,
    required this.onCountryChanged,
    required this.countryDialCode,
    required this.onClickLoginButton,
    this.onManualViewClick,
    this.socialEnable = false,
    required this.backFromThis,
  });

  @override
  Widget build(BuildContext context) => GetBuilder<AuthController>(
    builder: (authController) {
      void submit() {
        if (!authController.isLoading) onClickLoginButton();
      }

      return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisSize: MainAxisSize.min,
        children: [
          MiliAuthIntro(
            title: 'auth_ui_title'.tr,
            subtitle: 'auth_ui_otp_subtitle'.tr,
          ),
          MiliAuthField(
            label: 'phone'.tr,
            hint: 'auth_ui_phone_hint'.tr,
            controller: phoneController,
            focusNode: phoneFocus,
            inputAction: TextInputAction.done,
            inputType: TextInputType.phone,
            isPhone: true,
            onCountryChanged: onCountryChanged,
            countryDialCode:
                countryDialCode ??
                Get.find<LocalizationController>().locale.countryCode,
            autofillHints: const [AutofillHints.telephoneNumberNational],
            inputFormatters: [
              FilteringTextInputFormatter.allow(RegExp('[0-9]')),
            ],
            onSubmit: (_) => submit(),
            validator: (value) => ValidateCheck.validateEmptyText(
              value,
              'please_enter_phone_number'.tr,
            ),
          ),
          MiliAuthOptions(
            remember: authController.isActiveRememberMe,
            onRemember: authController.toggleRememberMe,
          ),
          MiliAuthSubmit(
            loading: authController.isLoading,
            label: 'auth_ui_send_code'.tr,
            onPressed: submit,
          ),
          if (onManualViewClick != null)
            MiliAuthSecondary(
              label: 'auth_ui_use_password'.tr,
              icon: Icons.lock_outline_rounded,
              onPressed: onManualViewClick,
            ),
          if (socialEnable)
            SocialLoginWidget(
              onlySocialLogin: false,
              backFromThis: backFromThis,
            ),
        ],
      );
    },
  );
}
