import 'package:flutter/material.dart';
import 'package:sixam_mart/features/home/widgets/web/web_most_popular_item_view_widget.dart';
import 'package:sixam_mart/features/item/controllers/campaign_controller.dart';

class WebMostPopularItemBannerViewWidget extends StatelessWidget {
  final CampaignController campaignController;
  const WebMostPopularItemBannerViewWidget({super.key, required this.campaignController});

  @override
  Widget build(BuildContext context) {
    return const WebMostPopularItemViewWidget(isFood: false, isShop: false);
  }
}
