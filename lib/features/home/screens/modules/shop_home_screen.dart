import 'package:flutter/material.dart';
import 'package:sixam_mart/features/reels/widgets/reels_section_widget.dart';
import 'package:sixam_mart/features/home/widgets/brands_view_widget.dart';
import 'package:sixam_mart/features/home/widgets/highlight_widget.dart';
import 'package:sixam_mart/features/home/widgets/views/recommended_store_view.dart';
import 'package:sixam_mart/features/home/widgets/views/top_offers_near_me.dart';
import 'package:sixam_mart/helper/auth_helper.dart';
import 'package:sixam_mart/features/flash_sale/widgets/flash_sale_view_widget.dart';
import 'package:sixam_mart/features/home/widgets/views/product_with_categories_view.dart';
import 'package:sixam_mart/features/home/widgets/views/featured_categories_view.dart';
import 'package:sixam_mart/features/home/widgets/views/popular_store_view.dart';
import 'package:sixam_mart/features/home/widgets/views/shop_item_recommendations_view.dart';
import 'package:sixam_mart/features/home/widgets/views/just_for_you_view.dart';
import 'package:sixam_mart/features/home/widgets/views/most_popular_item_view.dart';
import 'package:sixam_mart/features/home/widgets/views/new_on_mart_view.dart';
import 'package:sixam_mart/features/home/widgets/views/middle_section_banner_view.dart';
import 'package:sixam_mart/features/home/widgets/views/special_offer_view.dart';
import 'package:sixam_mart/features/home/widgets/views/promotional_banner_view.dart';
import 'package:sixam_mart/features/home/widgets/views/visit_again_view.dart';
import 'package:sixam_mart/features/home/widgets/banner_view.dart';
import 'package:sixam_mart/features/home/widgets/views/category_view.dart';

class ShopHomeScreen extends StatelessWidget {
  const ShopHomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    bool isLoggedIn = AuthHelper.isLoggedIn();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: MediaQuery.of(context).size.width,
          color: Theme.of(context).disabledColor.withValues(alpha: 0.1),
          child: const Column(
            children: [BannerView(isFeatured: false), SizedBox(height: 12)],
          ),
        ),
        const CategoryView(),
        const ReelsSectionWidget(),
        isLoggedIn ? const VisitAgainView() : const SizedBox(),
        const RecommendedStoreView(),
        const MostPopularItemView(isFood: false, isShop: true),
        const FlashSaleViewWidget(),
        const MiddleSectionBannerView(),
        const HighlightWidget(),
        const PopularStoreView(),
        const BrandsViewWidget(),
        const SpecialOfferView(isFood: false, isShop: true),
        const ProductWithCategoriesView(fromShop: true),
        const JustForYouView(),
        const TopOffersNearMe(),
        const FeaturedCategoriesView(),
        const ShopItemRecommendationsView(),
        const NewOnMartView(isShop: true, isPharmacy: false),
        const PromotionalBannerView(),
      ],
    );
  }
}
