import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lottie/lottie.dart';
import 'package:sixam_mart/features/splash/controllers/splash_controller.dart';
import 'package:sixam_mart/features/order/controllers/order_controller.dart';
import 'package:sixam_mart/features/order/domain/models/order_model.dart';
import 'package:sixam_mart/helper/date_converter.dart';
import 'package:sixam_mart/helper/module_helper.dart';
import 'package:sixam_mart/util/dimensions.dart';
import 'package:sixam_mart/util/images.dart';
import 'package:sixam_mart/util/styles.dart';
import 'package:sixam_mart/common/widgets/custom_image.dart';

class OrderBannerViewWidget extends StatelessWidget {
  final OrderModel order;
  final bool ongoing;
  final bool parcel;
  final bool prescriptionOrder;
  final OrderController orderController;
  const OrderBannerViewWidget({
    super.key,
    required this.order,
    required this.ongoing,
    required this.parcel,
    required this.prescriptionOrder,
    required this.orderController,
  });

  @override
  Widget build(BuildContext context) {
    final bool isBeerModule = ModuleHelper.isBeerModule;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        DateConverter.isBeforeTime(order.scheduleAt) &&
                Get.find<SplashController>()
                    .getModuleConfig(order.moduleType)
                    .newVariation!
            ? ongoing
                  ? Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Expanded(
                          flex: 1,
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(10),
                            child: Padding(
                              padding: EdgeInsets.only(
                                bottom: order.orderStatus != 'pending'
                                    ? 30.0
                                    : 0,
                              ),
                              child: _statusAnimation(isBeerModule),
                            ),
                          ),
                        ),
                        Expanded(
                          flex: 2,
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              SizedBox(
                                height: Dimensions.paddingSizeExtraLarge,
                              ),
                              Text(
                                (isBeerModule
                                        ? 'beer_on_the_way'
                                        : 'your_food_will_delivered_within')
                                    .tr,
                                style: robotoRegular.copyWith(
                                  fontSize: Dimensions.fontSizeDefault,
                                ),
                              ),
                              const SizedBox(
                                height: Dimensions.paddingSizeExtraSmall,
                              ),

                              Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text(
                                    DateConverter.differenceInMinute(
                                              order.store!.deliveryTime,
                                              order.createdAt,
                                              order.processingTime,
                                              order.scheduleAt,
                                            ) <
                                            5
                                        ? '1 - 5'
                                        : '${DateConverter.differenceInMinute(order.store!.deliveryTime, order.createdAt, order.processingTime, order.scheduleAt) - 5} '
                                              '- ${DateConverter.differenceInMinute(order.store!.deliveryTime, order.createdAt, order.processingTime, order.scheduleAt)}',
                                    style: robotoBold.copyWith(
                                      fontSize: Dimensions.fontSizeOverLarge,
                                    ),
                                    textDirection: TextDirection.ltr,
                                  ),
                                  const SizedBox(
                                    width: Dimensions.paddingSizeExtraSmall,
                                  ),
                                  Text(
                                    'min'.tr,
                                    style: robotoMedium.copyWith(
                                      fontSize: Dimensions.fontSizeLarge,
                                      color: Theme.of(context).disabledColor,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(
                                height: Dimensions.paddingSizeExtraLarge,
                              ),
                            ],
                          ),
                        ),
                      ],
                    )
                  : CustomImage(
                      image: '${order.store?.coverPhotoFullUrl}',
                      height: 150,
                      width: double.infinity,
                    )
            : const SizedBox(),

        parcel
            ? (ongoing && order.orderStatus == 'pending')
                  ? Image.asset(
                      Images.pendingOrderDetails,
                      height: 160,
                      width: double.infinity,
                    )
                  : Center(
                      child: CustomImage(
                        image: '${order.parcelCategory?.imageFullUrl}',
                        height: 160,
                      ),
                    )
            : const SizedBox(),

        prescriptionOrder
            ? ongoing
                  ? Image.asset(
                      order.orderStatus == 'pending'
                          ? Images.pendingOrderDetails
                          : (order.orderStatus == 'confirmed' ||
                                order.orderStatus == 'processing' ||
                                order.orderStatus == 'handover')
                          ? Images.preparingGroceryOrderDetails
                          : Images.ongoingAnimation,
                      height: 160,
                      width: double.infinity,
                    )
                  : CustomImage(
                      image: '${order.store?.coverPhotoFullUrl}',
                      height: 160,
                      width: double.infinity,
                    )
            : const SizedBox(),

        orderController.orderDetails!.isNotEmpty &&
                orderController.orderDetails![0].itemDetails!.moduleType ==
                    'grocery'
            ? (ongoing && order.orderStatus == 'pending')
                  ? Image.asset(
                      Images.pendingOrderDetails,
                      height: 160,
                      width: double.infinity,
                    )
                  : CustomImage(
                      image: '${order.store?.coverPhotoFullUrl}',
                      height: 160,
                      width: double.infinity,
                    )
            : const SizedBox(),

        orderController.orderDetails!.isNotEmpty &&
                orderController.orderDetails![0].itemDetails!.moduleType ==
                    'pharmacy'
            ? (ongoing && order.orderStatus == 'pending')
                  ? Image.asset(
                      Images.pendingOrderDetails,
                      height: 160,
                      width: double.infinity,
                    )
                  : CustomImage(
                      image: '${order.store?.coverPhotoFullUrl}',
                      height: 160,
                      width: double.infinity,
                    )
            : const SizedBox(),

        orderController.orderDetails!.isNotEmpty &&
                orderController.orderDetails![0].itemDetails!.moduleType ==
                    'ecommerce'
            ? (ongoing && order.orderStatus == 'pending')
                  ? Image.asset(
                      Images.pendingOrderDetails,
                      height: 160,
                      width: double.infinity,
                    )
                  : CustomImage(
                      image: '${order.store?.coverPhotoFullUrl}',
                      height: 160,
                      width: double.infinity,
                    )
            : const SizedBox(),
      ],
    );
  }

  Widget _statusAnimation(bool isBeerModule) {
    if (order.orderStatus == 'pending') {
      return Image.asset(Images.orderPendingIcon, fit: BoxFit.cover);
    }

    if (order.orderStatus == 'confirmed' ||
        order.orderStatus == 'processing' ||
        order.orderStatus == 'handover') {
      if (isBeerModule) {
        return Lottie.asset(
          Images.beerRefillLottie,
          fit: BoxFit.contain,
          decoder: _decodeDotLottie,
        );
      }

      return Image.asset(Images.preparingFoodOrderDetails, fit: BoxFit.cover);
    }

    return Image.asset(Images.ongoingAnimation, fit: BoxFit.cover);
  }

  static Future<LottieComposition?> _decodeDotLottie(List<int> bytes) {
    return LottieComposition.decodeZip(
      bytes,
      filePicker: (files) {
        for (final file in files) {
          final String name = file.name.toLowerCase();
          if (name.startsWith('animations/') && name.endsWith('.json')) {
            return file;
          }
        }
        return null;
      },
    );
  }
}
