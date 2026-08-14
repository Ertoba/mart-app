import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:sixam_mart/common/widgets/card_design/store_card_with_distance.dart';
import 'package:sixam_mart/common/widgets/title_widget.dart';
import 'package:sixam_mart/features/store/controllers/store_controller.dart';
import 'package:sixam_mart/features/store/domain/models/store_model.dart';
import 'package:sixam_mart/helper/module_helper.dart';
import 'package:sixam_mart/helper/route_helper.dart';
import 'package:sixam_mart/util/dimensions.dart';

class GroceryBestStoreNearbyView extends StatelessWidget {
  const GroceryBestStoreNearbyView({super.key});

  @override
  Widget build(BuildContext context) {
    return GetBuilder<StoreController>(
      builder: (storeController) {
        final List<Store>? stores = storeController.popularStoreList;

        if (stores == null || stores.isEmpty) {
          return const SizedBox.shrink();
        }

        return Padding(
          padding: const EdgeInsets.symmetric(
            vertical: Dimensions.paddingSizeDefault,
          ),
          child: Container(
            color: Theme.of(context).disabledColor.withValues(alpha: 0.1),
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.only(
                    top: Dimensions.paddingSizeDefault,
                    left: Dimensions.paddingSizeDefault,
                    right: Dimensions.paddingSizeDefault,
                  ),
                  child: TitleWidget(
                    title: ModuleHelper.bestStoreNearbyKey.tr,
                    seeAllFontSize: Dimensions.fontSizeExtraSmall,
                    onTap: () => Get.toNamed(
                      RouteHelper.getAllStoreRoute(
                        'popular',
                        isNearbyStore: true,
                      ),
                    ),
                  ),
                ),
                SizedBox(
                  height: 215,
                  child: ListView.builder(
                    physics: const BouncingScrollPhysics(),
                    scrollDirection: Axis.horizontal,
                    padding: const EdgeInsets.only(
                      top: Dimensions.paddingSizeDefault,
                      bottom: Dimensions.paddingSizeDefault,
                    ),
                    itemCount: stores.length,
                    itemBuilder: (context, index) {
                      return Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: Dimensions.paddingSizeSmall,
                        ),
                        child: StoreCardWithDistance(store: stores[index]),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
