import 'package:sixam_mart/features/splash/controllers/splash_controller.dart';
import 'package:sixam_mart/features/support/widgets/web_help_support_widget.dart';
import 'package:sixam_mart/features/notification/domain/models/notification_body_model.dart';
import 'package:sixam_mart/helper/auth_helper.dart';
import 'package:sixam_mart/helper/responsive_helper.dart';
import 'package:sixam_mart/helper/route_helper.dart';
import 'package:sixam_mart/util/dimensions.dart';
import 'package:sixam_mart/util/images.dart';
import 'package:sixam_mart/common/widgets/custom_app_bar.dart';
import 'package:sixam_mart/common/widgets/custom_snackbar.dart';
import 'package:sixam_mart/common/widgets/footer_view.dart';
import 'package:sixam_mart/common/widgets/menu_drawer.dart';
import 'package:sixam_mart/util/styles.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:url_launcher/url_launcher_string.dart';

class SupportScreen extends StatefulWidget {
  const SupportScreen({super.key});

  @override
  State<SupportScreen> createState() => _SupportScreenState();
}

class _SupportScreenState extends State<SupportScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(title: 'help_support'.tr),
      endDrawer: const MenuDrawer(),
      endDrawerEnableOpenDragGesture: false,
      body: SingleChildScrollView(
        padding: ResponsiveHelper.isDesktop(context)
            ? EdgeInsets.zero
            : const EdgeInsets.all(Dimensions.paddingSizeSmall),
        physics: const BouncingScrollPhysics(),
        child: Center(
          child: FooterView(
            child: ResponsiveHelper.isDesktop(context)
                ? const SizedBox(
                    width: double.infinity,
                    height: 650,
                    child: WebSupportScreen(),
                  )
                : SizedBox(
                    width: Dimensions.webMaxWidth,
                    child: Column(
                      children: [
                        const _SupportHero(),
                        const SizedBox(height: Dimensions.paddingSizeLarge),

                        _SupportActionCard(
                          icon: Icons.location_on,
                          title: 'address'.tr,
                          color: Theme.of(context).primaryColor,
                          info:
                              Get.find<SplashController>().configModel!.address,
                          onTap: () {},
                        ),
                        const SizedBox(height: Dimensions.paddingSizeSmall),

                        _SupportActionCard(
                          icon: Icons.call,
                          title: 'call'.tr,
                          color: Colors.red,
                          info: Get.find<SplashController>().configModel!.phone,
                          onTap: () async {
                            if (await canLaunchUrlString(
                              'tel:${Get.find<SplashController>().configModel!.phone}',
                            )) {
                              launchUrlString(
                                'tel:${Get.find<SplashController>().configModel!.phone}',
                              );
                            } else {
                              showCustomSnackBar(
                                '${'can_not_launch'.tr} ${Get.find<SplashController>().configModel!.phone}',
                              );
                            }
                          },
                        ),
                        const SizedBox(height: Dimensions.paddingSizeSmall),

                        _SupportActionCard(
                          icon: Icons.mail_outline,
                          title: 'email_us'.tr,
                          color: Theme.of(context).primaryColor,
                          info: Get.find<SplashController>().configModel!.email,
                          onTap: () {
                            final Uri emailLaunchUri = Uri(
                              scheme: 'mailto',
                              path: Get.find<SplashController>()
                                  .configModel!
                                  .email,
                            );
                            launchUrlString(emailLaunchUri.toString());
                          },
                        ),
                        const SizedBox(height: Dimensions.paddingSizeSmall),

                        _SupportActionCard(
                          icon: Icons.support_agent_rounded,
                          title: 'საპორტის ჩატი',
                          color: Theme.of(context).primaryColor,
                          info: 'მოგვწერეთ პირდაპირ მხარდაჭერის გუნდს',
                          onTap: _openSupportChat,
                        ),
                      ],
                    ),
                  ),
          ),
        ),
      ),
    );
  }

  void _openSupportChat() {
    if (!AuthHelper.isLoggedIn()) {
      Get.toNamed(RouteHelper.getSignInRoute(RouteHelper.support));
      return;
    }

    Get.toNamed(
      RouteHelper.getChatRoute(
        notificationBody: NotificationBodyModel(
          type: 'admin',
          notificationType: NotificationType.message,
          adminId: 0,
          receiverType: 'admin',
        ),
        fromNotification: false,
      ),
    );
  }
}

class _SupportHero extends StatelessWidget {
  const _SupportHero();

  @override
  Widget build(BuildContext context) {
    final Color primaryColor = Theme.of(context).primaryColor;

    return Column(
      children: [
        SizedBox(
          height: context.height * 0.25 > 220 ? 220 : context.height * 0.25,
          width: double.infinity,
          child: SvgPicture.asset(
            Images.miliSupportStatic,
            fit: BoxFit.contain,
          ),
        ),
        const SizedBox(height: Dimensions.paddingSizeDefault),
        RichText(
          textAlign: TextAlign.center,
          text: TextSpan(
            style: robotoBold.copyWith(
              color: Theme.of(context).textTheme.bodyLarge!.color,
              fontSize: Dimensions.fontSizeExtraLarge,
              height: 1.25,
            ),
            children: [
              const TextSpan(text: 'ჩვენ აქ ვართ, რომ '),
              TextSpan(
                text: 'დაგეხმაროთ!',
                style: robotoBold.copyWith(color: primaryColor),
              ),
            ],
          ),
        ),
        const SizedBox(height: Dimensions.paddingSizeSmall),
        Text(
          'აირჩიეთ თქვენთვის სასურველი კონტაქტის გზა და დაგიკავშირდებით უმოკლეს დროში.',
          textAlign: TextAlign.center,
          style: robotoMedium.copyWith(
            color: Theme.of(context).hintColor,
            fontSize: Dimensions.fontSizeSmall,
            height: 1.45,
          ),
        ),
      ],
    );
  }
}

class _SupportActionCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String? info;
  final Color color;
  final VoidCallback onTap;

  const _SupportActionCard({
    required this.icon,
    required this.title,
    required this.info,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
      child: Container(
        padding: const EdgeInsets.all(Dimensions.paddingSizeDefault),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.05),
          borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
          border: Border.all(color: color.withValues(alpha: 0.10)),
        ),
        child: Row(
          children: [
            Container(
              height: 48,
              width: 48,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: color.withValues(alpha: 0.12),
              ),
              child: Icon(icon, color: color, size: 24),
            ),
            const SizedBox(width: Dimensions.paddingSizeDefault),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: robotoBold.copyWith(
                      color: color,
                      fontSize: Dimensions.fontSizeDefault,
                    ),
                  ),
                  const SizedBox(height: Dimensions.paddingSizeExtraSmall),
                  Text(
                    info ?? '',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: robotoMedium.copyWith(
                      fontSize: Dimensions.fontSizeSmall,
                      color: Theme.of(context).textTheme.bodyLarge!.color,
                    ),
                  ),
                ],
              ),
            ),
            Container(
              height: 32,
              width: 32,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: color.withValues(alpha: 0.10),
              ),
              child: Icon(Icons.chevron_right_rounded, color: color),
            ),
          ],
        ),
      ),
    );
  }
}
