import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shimmer_animation/shimmer_animation.dart';
import 'package:sixam_mart/common/widgets/custom_image.dart';
import 'package:sixam_mart/common/widgets/not_available_widget.dart';
import 'package:sixam_mart/common/widgets/title_widget.dart';
import 'package:sixam_mart/features/item/controllers/campaign_controller.dart';
import 'package:sixam_mart/features/item/controllers/item_controller.dart';
import 'package:sixam_mart/features/item/domain/models/item_model.dart';
import 'package:sixam_mart/helper/route_helper.dart';
import 'package:sixam_mart/util/dimensions.dart';

class JustForYouSection extends StatefulWidget {
  final String? title;
  const JustForYouSection({super.key, this.title});

  @override
  State<JustForYouSection> createState() => _JustForYouSectionState();
}

class _JustForYouSectionState extends State<JustForYouSection> {
  @override
  void initState() {
    super.initState();
    final CampaignController campaignController =
        Get.find<CampaignController>();
    if (campaignController.itemCampaignList == null) {
      campaignController.getItemCampaignList(false);
    }
  }

  @override
  Widget build(BuildContext context) {
    const double cardSize = 72;

    return GetBuilder<ItemController>(
      builder: (itemController) {
        return GetBuilder<CampaignController>(
          builder: (campaignController) {
            final List<Item>? personalizedItems =
                itemController.suggestedItemList;
            final List<Item>? campaigns = campaignController.itemCampaignList;

            final bool hasPersonalizedItems =
                personalizedItems != null && personalizedItems.isNotEmpty;

            final List<Item>? displayItems = hasPersonalizedItems
                ? personalizedItems
                : campaigns;

            final bool isLoading =
                personalizedItems == null && campaigns == null;

            if (!isLoading && (displayItems == null || displayItems.isEmpty)) {
              return const SizedBox();
            }

            final int itemCount = isLoading
                ? 6
                : (displayItems!.length > 10 ? 10 : displayItems.length);

            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: Dimensions.paddingSizeDefault,
                  ),
                  child: TitleWidget(
                    title: widget.title ?? 'just_for_you'.tr,
                    seeAllUnderline: false,
                    onTap: hasPersonalizedItems
                        ? null
                        : () => Get.toNamed(
                            RouteHelper.getItemCampaignRoute(
                              isJustForYou: true,
                            ),
                          ),
                  ),
                ),
                const SizedBox(height: Dimensions.paddingSizeDefault),
                SizedBox(
                  height: cardSize,
                  child: ListView.separated(
                    scrollDirection: Axis.horizontal,
                    physics: const BouncingScrollPhysics(),
                    padding: const EdgeInsets.symmetric(
                      horizontal: Dimensions.paddingSizeDefault,
                    ),
                    itemCount: itemCount,
                    separatorBuilder: (context, index) =>
                        const SizedBox(width: Dimensions.paddingSizeSmall),
                    itemBuilder: (context, index) {
                      if (isLoading) {
                        return const _JustForYouShimmerCard(size: cardSize);
                      }

                      return _JustForYouCard(
                        item: displayItems![index],
                        size: cardSize,
                        isCampaign: !hasPersonalizedItems,
                      );
                    },
                  ),
                ),
              ],
            );
          },
        );
      },
    );
  }
}

class _JustForYouCard extends StatelessWidget {
  final Item item;
  final double size;
  final bool isCampaign;

  const _JustForYouCard({
    required this.item,
    required this.size,
    required this.isCampaign,
  });

  @override
  Widget build(BuildContext context) {
    final BorderRadius radius = BorderRadius.circular(Dimensions.radiusLarge);
    return InkWell(
      borderRadius: radius,
      onTap: () => Get.find<ItemController>().navigateToItemPage(
        item,
        context,
        isCampaign: isCampaign,
      ),
      child: SizedBox(
        width: size,
        height: size,
        child: ClipRRect(
          borderRadius: radius,
          child: Stack(
            children: [
              CustomImage(
                image: item.imageFullUrl ?? '',
                height: size,
                width: size,
                fit: BoxFit.cover,
              ),
              Get.find<ItemController>().isAvailable(item)
                  ? const SizedBox()
                  : const NotAvailableWidget(),
            ],
          ),
        ),
      ),
    );
  }
}

class _JustForYouShimmerCard extends StatelessWidget {
  final double size;
  const _JustForYouShimmerCard({required this.size});

  @override
  Widget build(BuildContext context) {
    return Shimmer(
      duration: const Duration(seconds: 2),
      child: Container(
        height: size,
        width: size,
        decoration: BoxDecoration(
          color: Theme.of(context).disabledColor.withAlpha(60),
          borderRadius: BorderRadius.circular(Dimensions.radiusLarge),
        ),
      ),
    );
  }
}
