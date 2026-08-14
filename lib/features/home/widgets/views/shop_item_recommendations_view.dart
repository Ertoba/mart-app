import 'package:card_swiper/card_swiper.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:sixam_mart/features/home/widgets/components/review_item_card_widget.dart';
import 'package:sixam_mart/features/item/controllers/item_controller.dart';
import 'package:sixam_mart/features/item/domain/models/item_model.dart';
import 'package:sixam_mart/util/dimensions.dart';
import 'package:sixam_mart/util/styles.dart';

class ShopItemRecommendationsView extends StatefulWidget {
  const ShopItemRecommendationsView({super.key});

  @override
  State<ShopItemRecommendationsView> createState() =>
      _ShopItemRecommendationsViewState();
}

class _ShopItemRecommendationsViewState
    extends State<ShopItemRecommendationsView> {
  final SwiperController swiperController = SwiperController();

  @override
  Widget build(BuildContext context) {
    return GetBuilder<ItemController>(
      builder: (itemController) {
        final List<Item>? items = itemController.recommendedItemList;

        if (items == null || items.isEmpty) {
          return const SizedBox.shrink();
        }

        return Column(
          children: [
            Padding(
              padding: const EdgeInsets.only(
                top: Dimensions.paddingSizeDefault,
                left: Dimensions.paddingSizeDefault,
                right: Dimensions.paddingSizeDefault,
              ),
              child: Align(
                alignment: Alignment.center,
                child: Text(
                  'here_is_what_you_might_like'.tr,
                  style: robotoBold.copyWith(
                    fontSize: Dimensions.fontSizeLarge,
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(
                bottom: Dimensions.paddingSizeDefault,
              ),
              child: Stack(
                children: [
                  SizedBox(
                    height: 300,
                    width: Get.width,
                    child: Swiper(
                      controller: swiperController,
                      itemBuilder: (BuildContext context, int index) {
                        return ReviewItemCard(item: items[index]);
                      },
                      itemCount: items.length,
                      itemWidth: 250,
                      itemHeight: 300,
                      layout: SwiperLayout.TINDER,
                    ),
                  ),
                  Positioned(
                    top: 150,
                    right: 10,
                    child: InkWell(
                      onTap: () => swiperController.next(),
                      child: Icon(
                        Icons.arrow_forward,
                        color: Theme.of(context).primaryColor,
                      ),
                    ),
                  ),
                  Positioned(
                    top: 150,
                    left: 10,
                    child: InkWell(
                      onTap: () => swiperController.previous(),
                      child: Icon(
                        Icons.arrow_back,
                        color: Theme.of(context).primaryColor,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        );
      },
    );
  }
}
