import 'package:sixam_mart/features/splash/controllers/splash_controller.dart';
import 'package:sixam_mart/util/dimensions.dart';
import 'package:sixam_mart/util/images.dart';
import 'package:sixam_mart/util/styles.dart';
import 'package:sixam_mart/common/widgets/custom_button.dart';
import 'package:sixam_mart/common/widgets/custom_snackbar.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:url_launcher/url_launcher_string.dart';

class UpdateScreen extends StatefulWidget {
  final bool isUpdate;
  const UpdateScreen({super.key, required this.isUpdate});

  @override
  State<UpdateScreen> createState() => _UpdateScreenState();
}

class _UpdateScreenState extends State<UpdateScreen> {
  Future<void> _launchContact(String uri) async {
    if(await canLaunchUrlString(uri)) {
      await launchUrlString(uri, mode: LaunchMode.externalApplication);
    } else {
      showCustomSnackBar('${'can_not_launch'.tr} $uri');
    }
  }

  @override
  Widget build(BuildContext context) {
    final config = Get.find<SplashController>().configModel;
    final maintenanceMessage =
        config?.maintenanceModeData?.maintenanceMessageSetup;

    final String maintenanceTitle =
        (maintenanceMessage?.maintenanceMessage?.trim().isNotEmpty ?? false)
            ? maintenanceMessage!.maintenanceMessage!.trim()
            : 'we_are_under_maintenance'.tr;

    final String maintenanceBody =
        (maintenanceMessage?.messageBody?.trim().isNotEmpty ?? false)
            ? maintenanceMessage!.messageBody!.trim()
            : 'we_will_be_right_back'.tr;

    final bool showPhone = !widget.isUpdate
        && maintenanceMessage?.businessNumber == 1
        && (config?.phone?.trim().isNotEmpty ?? false);

    final bool showEmail = !widget.isUpdate
        && maintenanceMessage?.businessEmail == 1
        && (config?.email?.trim().isNotEmpty ?? false);

    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(Dimensions.paddingSizeLarge),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Image.asset(
                  widget.isUpdate ? Images.update : Images.maintenance,
                  width: MediaQuery.of(context).size.height * 0.4,
                  height: MediaQuery.of(context).size.height * 0.4,
                ),
                SizedBox(height: MediaQuery.of(context).size.height * 0.01),

                Text(
                  widget.isUpdate ? 'update'.tr : maintenanceTitle,
                  style: robotoBold.copyWith(
                    fontSize: MediaQuery.of(context).size.height * 0.023,
                    color: Theme.of(context).primaryColor,
                  ),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: MediaQuery.of(context).size.height * 0.01),

                Text(
                  widget.isUpdate ? 'your_app_is_deprecated'.tr : maintenanceBody,
                  style: robotoRegular.copyWith(
                    fontSize: MediaQuery.of(context).size.height * 0.0175,
                    color: Theme.of(context).disabledColor,
                  ),
                  textAlign: TextAlign.center,
                ),

                if(showPhone || showEmail) ...[
                  const SizedBox(height: Dimensions.paddingSizeDefault),
                  Wrap(
                    alignment: WrapAlignment.center,
                    spacing: Dimensions.paddingSizeSmall,
                    runSpacing: Dimensions.paddingSizeSmall,
                    children: [
                      if(showPhone)
                        TextButton.icon(
                          onPressed: () => _launchContact('tel:${config!.phone}'),
                          icon: const Icon(Icons.phone_outlined),
                          label: Text(config!.phone!),
                        ),
                      if(showEmail)
                        TextButton.icon(
                          onPressed: () => _launchContact('mailto:${config!.email}'),
                          icon: const Icon(Icons.email_outlined),
                          label: Text(config!.email!),
                        ),
                    ],
                  ),
                ],

                SizedBox(
                  height: MediaQuery.of(context).size.height * 0.04,
                ),

                if(widget.isUpdate)
                  CustomButton(
                    buttonText: 'update_now'.tr,
                    onPressed: () async {
                      String? appUrl = 'https://google.com';
                      if(GetPlatform.isAndroid) {
                        appUrl = config?.appUrlAndroid;
                      } else if(GetPlatform.isIOS) {
                        appUrl = config?.appUrlIos;
                      }
                      if(appUrl != null && await canLaunchUrlString(appUrl)) {
                        launchUrlString(
                          appUrl,
                          mode: LaunchMode.externalApplication,
                        );
                      } else {
                        showCustomSnackBar('${'can_not_launch'.tr} $appUrl');
                      }
                    },
                  )
                else
                  CustomButton(
                    buttonText: 'try_again'.tr,
                    onPressed: () => Get.find<SplashController>().getConfigData(
                      handleMaintenanceMode: true,
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
