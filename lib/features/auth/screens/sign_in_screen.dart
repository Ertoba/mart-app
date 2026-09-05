import 'dart:async';
import 'dart:io';
import 'package:sixam_mart/features/auth/controllers/auth_controller.dart';
import 'package:sixam_mart/features/auth/widgets/sign_in/sign_in_view.dart';
import 'package:sixam_mart/features/auth/widgets/mili_auth_ui.dart';
import 'package:sixam_mart/helper/responsive_helper.dart';
import 'package:sixam_mart/helper/route_helper.dart';
import 'package:sixam_mart/util/dimensions.dart';
import 'package:sixam_mart/util/images.dart';
import 'package:sixam_mart/common/widgets/menu_drawer.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';

class SignInScreen extends StatefulWidget {
  final bool exitFromApp;
  final bool backFromThis;
  final bool fromNotification;
  final bool fromResetPassword;
  const SignInScreen({
    super.key,
    required this.exitFromApp,
    required this.backFromThis,
    this.fromNotification = false,
    this.fromResetPassword = false,
  });

  @override
  SignInScreenState createState() => SignInScreenState();
}

class SignInScreenState extends State<SignInScreen> {
  bool _canExit = GetPlatform.isWeb ? true : false;

  @override
  void initState() {
    super.initState();
    Get.find<AuthController>().enableManualView(enable: false);
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: Navigator.canPop(context),
      onPopInvokedWithResult: (didPop, result) async {
        if (widget.fromNotification || widget.fromResetPassword) {
          Navigator.pushNamed(context, RouteHelper.getInitialRoute());
        } else if (widget.exitFromApp) {
          if (_canExit) {
            if (GetPlatform.isAndroid) {
              SystemNavigator.pop();
            } else if (GetPlatform.isIOS) {
              exit(0);
            } else {
              Navigator.pushNamed(context, RouteHelper.getInitialRoute());
            }
          } else {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                  'back_press_again_to_exit'.tr,
                  style: const TextStyle(color: Colors.white),
                ),
                behavior: SnackBarBehavior.floating,
                backgroundColor: Colors.green,
                duration: const Duration(seconds: 2),
                margin: const EdgeInsets.all(Dimensions.paddingSizeSmall),
              ),
            );
            _canExit = true;
            Timer(const Duration(seconds: 2), () {
              _canExit = false;
            });
          }
        } else {
          if (Get.find<AuthController>().isManualViewEnable) {
            Get.find<AuthController>().enableManualView(enable: false);
          } else if (Get.find<AuthController>().isOtpViewEnable) {
            Get.find<AuthController>().enableOtpView(enable: false);
          } else {
            // Get.back();
          }
        }
      },
      child: Scaffold(
        backgroundColor: ResponsiveHelper.isDesktop(context)
            ? Colors.transparent
            : Theme.of(context).cardColor,
        appBar: (ResponsiveHelper.isDesktop(context)
            ? null
            : !widget.exitFromApp
            ? AppBar(
                leading: IconButton(
                  onPressed: () {
                    if (widget.fromNotification || widget.fromResetPassword) {
                      Navigator.pushNamed(
                        context,
                        RouteHelper.getInitialRoute(),
                      );
                    } else if (Get.find<AuthController>().isManualViewEnable) {
                      Get.find<AuthController>().enableManualView(
                        enable: false,
                      );
                    } else if (Get.find<AuthController>().isOtpViewEnable) {
                      Get.find<AuthController>().enableOtpView(enable: false);
                    } else {
                      Get.back(result: false);
                    }
                  },
                  icon: Icon(
                    Icons.arrow_back_ios_rounded,
                    color: Theme.of(context).textTheme.bodyLarge!.color,
                  ),
                ),
                elevation: 0,
                backgroundColor: Theme.of(context).cardColor,
                actions: const [SizedBox()],
              )
            : null),
        endDrawer: const MenuDrawer(),
        endDrawerEnableOpenDragGesture: false,

        body: SafeArea(
          child: MiliAuthLayout(
            logoAsset: Images.brandMark,
            children: [
              if (ResponsiveHelper.isDesktop(context))
                Align(
                  alignment: AlignmentDirectional.centerEnd,
                  child: IconButton(
                    tooltip: 'close'.tr,
                    onPressed: () => Get.back(),
                    icon: const Icon(Icons.close_rounded),
                  ),
                ),
              SignInView(
                exitFromApp: widget.exitFromApp,
                backFromThis: widget.backFromThis,
                fromResetPassword: widget.fromResetPassword,
                isOtpViewEnable: (v) {},
              ),
            ],
          ),
        ),
      ),
    );
  }
}
