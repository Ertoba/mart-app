import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:scroll_to_index/scroll_to_index.dart';
import 'package:sixam_mart/common/widgets/avg_review_widget.dart';
import 'package:sixam_mart/common/widgets/back_to_top.dart';
import 'package:sixam_mart/common/widgets/cart_count_view.dart';
import 'package:sixam_mart/common/widgets/closed_ribbon_badge.dart';
import 'package:sixam_mart/common/widgets/custom_asset_image_widget.dart';
import 'package:sixam_mart/common/widgets/custom_button.dart';
import 'package:sixam_mart/common/widgets/custom_favourite_widget.dart';
import 'package:sixam_mart/common/widgets/custom_image.dart';
import 'package:sixam_mart/common/widgets/custom_snackbar.dart';
import 'package:sixam_mart/common/widgets/food_item_card.dart';
import 'package:sixam_mart/common/widgets/footer_view.dart';
import 'package:sixam_mart/common/widgets/menu_drawer.dart';
import 'package:sixam_mart/common/widgets/not_available_widget.dart';
import 'package:sixam_mart/common/widgets/paginated_list_view.dart';
import 'package:sixam_mart/common/widgets/store_header_banner_widget.dart';
import 'package:sixam_mart/common/widgets/web_item_view.dart';
import 'package:sixam_mart/common/widgets/web_item_widget.dart';
import 'package:sixam_mart/common/widgets/web_menu_bar.dart';
import 'package:sixam_mart/features/address/domain/models/address_model.dart';
import 'package:sixam_mart/features/bogo_offer/controllers/bogo_offer_controller.dart';
import 'package:sixam_mart/features/bogo_offer/domain/models/bogo_offer_model.dart';
import 'package:sixam_mart/features/bogo_offer/widgets/bogo_store_section_widget.dart';
import 'package:sixam_mart/features/bundle/controllers/bundle_controller.dart';
import 'package:sixam_mart/features/bundle/widgets/bundle_items_tab_section.dart';
import 'package:sixam_mart/features/bundle/widgets/bundle_store_section_widget.dart';
import 'package:sixam_mart/features/cart/controllers/cart_controller.dart';
import 'package:sixam_mart/features/cart/domain/models/all_carts_model.dart';
import 'package:sixam_mart/features/cart/screens/cart_screen.dart';
import 'package:sixam_mart/features/category/controllers/category_controller.dart';
import 'package:sixam_mart/features/checkout/controllers/checkout_controller.dart';
import 'package:sixam_mart/features/checkout/screens/checkout_screen.dart';
import 'package:sixam_mart/features/coupon/domain/models/coupon_model.dart' hide Store;
import 'package:sixam_mart/features/dashboard/widgets/bogo_offer_card_widget.dart';
import 'package:sixam_mart/features/dashboard/widgets/last_orders_section_widget.dart';
import 'package:sixam_mart/features/favourite/controllers/favourite_controller.dart';
import 'package:sixam_mart/features/happy_hour/controllers/happy_hour_controller.dart';
import 'package:sixam_mart/features/happy_hour/widgets/happy_hour_milestone_banner_widget.dart';
import 'package:sixam_mart/features/item/controllers/item_controller.dart';
import 'package:sixam_mart/features/item/domain/models/item_model.dart';
import 'package:sixam_mart/features/order/controllers/order_controller.dart';
import 'package:sixam_mart/features/pro/controllers/pro_controller.dart';
import 'package:sixam_mart/features/pro/domain/models/pro_active_offer_model.dart';
import 'package:sixam_mart/features/pro/screens/subscription_plan_screen.dart';
import 'package:sixam_mart/features/pro/widgets/pro_plan_banner_widget.dart';
import 'package:sixam_mart/features/profile/controllers/profile_controller.dart';
import 'package:sixam_mart/features/splash/controllers/splash_controller.dart';
import 'package:sixam_mart/features/store/controllers/store_controller.dart';
import 'package:sixam_mart/features/store/domain/models/store_category_item_model.dart';
import 'package:sixam_mart/features/store/domain/models/store_model.dart';
import 'package:sixam_mart/features/store/widgets/bottom_add_to_cart_widget.dart';
import 'package:sixam_mart/features/store/widgets/coupon_clipper.dart';
import 'package:sixam_mart/features/store/widgets/filter_widget.dart';
import 'package:sixam_mart/features/store/widgets/store_bogo_offer_list_sheet.dart';
import 'package:sixam_mart/features/store/widgets/store_description_view_widget.dart';
import 'package:sixam_mart/features/store/widgets/store_screen_shimmer_widget.dart';
import 'package:sixam_mart/helper/auth_helper.dart';
import 'package:sixam_mart/helper/date_converter.dart';
import 'package:sixam_mart/helper/image_cache_helper.dart';
import 'package:sixam_mart/helper/module_helper.dart';
import 'package:sixam_mart/helper/price_converter.dart';
import 'package:sixam_mart/helper/responsive_helper.dart';
import 'package:sixam_mart/helper/route_helper.dart';
import 'package:sixam_mart/util/app_constants.dart';
import 'package:sixam_mart/util/dimensions.dart';
import 'package:sixam_mart/util/gaps.dart';
import 'package:sixam_mart/util/images.dart';
import 'package:sixam_mart/util/styles.dart';
import 'package:sliver_tools/sliver_tools.dart';

class StoreScreen extends StatefulWidget {
  final Store? store;
  final bool fromModule;
  final String slug;
  final bool fromGlobalCart;
  const StoreScreen({
    super.key,
    required this.store,
    required this.fromModule,
    this.slug = '',
    this.fromGlobalCart = false,
  });

  @override
  State<StoreScreen> createState() => _StoreScreenState();
}

class _StoreScreenState extends State<StoreScreen> {
  late final AutoScrollController scrollController = AutoScrollController(
    viewportBoundaryGetter: () => Rect.fromLTRB(0, _pinnedTopInset, 0, 0),
    axis: Axis.vertical,
    suggestedRowHeight: 150,
  );
  double _pinnedTopInset = 0;
  double _appBarBottom = 70;
  final GlobalKey _categoryTabsKey = GlobalKey();
  final Map<int, int> _tabToRowIndex = {0: 0, 1: 1};
  StoreCategoryItemModel? _rowsSource;
  List<_StoreRow> _rows = const <_StoreRow>[];
  final TextEditingController _searchController = TextEditingController();
  final Map<int, GlobalKey> categoryKeys = {};
  final GlobalKey _popularSectionKey = GlobalKey();
  final GlobalKey _bundleSectionKey = GlobalKey();
  final Map<int, double> _sectionOffsets = {};
  int _visibleTabSignature = -1;
  bool _showBackToTop = false;
  static const double _backToTopThreshold = 400;
  static const double _backToTopGap = 12;
  final ValueNotifier<double?> _backToTopTop = ValueNotifier(null);
  final ValueNotifier<int> _categoryScrollIndex = ValueNotifier(0);
  final GlobalKey _cartBarKey = GlobalKey();
  double _cartBarHeight = 0;
  bool _userClickedTab = false;
  int? _pendingTabIndex;
  bool _initialCategorySet = false;
  bool _catalogRequested = false;

  @override
  void initState() {
    super.initState();
    initDataCall();
    if (widget.fromGlobalCart) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) _openCartBottomSheet(widget.store?.id);
      });
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!ResponsiveHelper.isDesktop(context)) {
      _ensureCatalogLoaded();
    }
  }

  void _ensureCatalogLoaded() {
    if (_catalogRequested) return;
    final StoreController storeController = Get.find<StoreController>();
    final int? storeId = widget.store!.id ?? storeController.store?.id;
    if (storeId == null) return;
    _catalogRequested = true;
    storeController.getStoreCategoryItems(storeId, notify: false);
  }

  bool _hasBundlesFor(int? storeId) {
    if (storeId == null) return false;
    return Get.find<BundleController>().storeBundlesOf(storeId)?.isNotEmpty ?? false;
  }

  void _syncCartBarHeight() {
    if (!mounted) return;
    final RenderObject? box = _cartBarKey.currentContext?.findRenderObject();
    final double height = (box is RenderBox && box.hasSize) ? box.size.height : 0;
    if (_cartBarHeight != height) {
      setState(() => _cartBarHeight = height);
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    scrollController.removeListener(() {});
    scrollController.dispose();
    _backToTopTop.dispose();
    _categoryScrollIndex.dispose();
    final StoreController storeController = Get.find<StoreController>();
    if (storeController.store?.id == widget.store?.id) {
      storeController.clearStoreCategoryItems();
    }
    super.dispose();
  }

  Future<void> initDataCall() async {
    final CartController cartController = Get.find<CartController>();
    if (cartController.allCartsGroups == null && !cartController.isAllCartsLoading) {
      cartController.getAllCarts(notify: false);
    }
    Get.find<StoreController>().resetFilter(isUpdate: false);
    if (Get.find<StoreController>().isSearching) {
      Get.find<StoreController>().changeSearchStatus(isUpdate: false);
    }
    Get.find<StoreController>().hideAnimation();
    await Get.find<StoreController>()
        .getStoreDetails(
          Store(id: widget.store!.id),
          widget.fromModule,
          slug: '',
        )
        .then((value) {
          Get.find<StoreController>().showButtonAnimation();
        });
    if (Get.find<CategoryController>().categoryList == null) {
      Get.find<CategoryController>().getCategoryList(true);
    }
    Get.find<StoreController>().getStoreBannerList(
      widget.store!.id ?? Get.find<StoreController>().store!.id,
    );
    Get.find<StoreController>().getRestaurantRecommendedItemList(
      widget.store!.id ?? Get.find<StoreController>().store!.id,
      false,
    );
    Get.find<StoreController>().getStoreItemList(
      widget.store!.id ?? Get.find<StoreController>().store!.id,
      1,
      'all',
      false,
    );

    scrollController.addListener(() {
      if (scrollController.position.userScrollDirection ==
          ScrollDirection.reverse) {
        if (Get.find<StoreController>().showFavButton) {
          Get.find<StoreController>().changeFavVisibility();
          Get.find<StoreController>().hideAnimation();
        }
      } else {
        if (!Get.find<StoreController>().showFavButton) {
          Get.find<StoreController>().changeFavVisibility();
          Get.find<StoreController>().showButtonAnimation();
        }
      }
      if (showBackToTop != _showBackToTop) {
        setState(() => _showBackToTop = showBackToTop);
      }
    });
  }

  void _handleTabTap(int index) {
    _userClickedTab = true;
    _pendingTabIndex = index;
    final int target = _tabToRowIndex[index] ?? 0;
    scrollController.scrollToIndex(
      target,
      preferPosition: AutoScrollPosition.begin,
      duration: const Duration(milliseconds: 400),
    );
    Future.delayed(const Duration(milliseconds: 500), () {
      if (!mounted) return;
      _categoryScrollIndex.value = index;
      _userClickedTab = false;
    });
  }

  void _syncTabsChanged({required bool hasMostPopular, required bool hasBundles, required int categoryCount}) {
    final int signature = (hasMostPopular ? 1 : 0) + (hasBundles ? 2 : 0) + (categoryCount * 4);
    if (_visibleTabSignature == signature) return;
    _visibleTabSignature = signature;

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) _updateCategoryScrollIndex();
    });
  }

  void _updateCategoryScrollIndex() {
    if (_userClickedTab) return;

    final storeController = Get.find<StoreController>();

    final cats = storeController.storeCategoryItemsModel?.categories ?? [];
    final bool hasMostPopular = storeController.recommendedItemModel?.items?.isNotEmpty == true;
    final bool hasBundles = _hasBundlesFor(storeController.store?.id ?? widget.store?.id);
    const double threshold = 180.0;

    final double pixels = scrollController.hasClients ? scrollController.position.pixels : 0;
    final List<MapEntry<int, double>> realized = [];
    void measure(int tabIndex, GlobalKey? key) {
      final RenderObject? box = key?.currentContext?.findRenderObject();
      if (box is RenderBox && box.hasSize) {
        final double top = box.localToGlobal(Offset.zero).dy;
        // Held in scroll space, where it stays true after the section unmounts.
        _sectionOffsets[tabIndex] = pixels + top;
        realized.add(MapEntry(tabIndex, top));
        return;
      }
      final double? lastKnown = _sectionOffsets[tabIndex];
      if (lastKnown != null) {
        realized.add(MapEntry(tabIndex, lastKnown - pixels));
      }
    }
    if (hasMostPopular) measure(0, _popularSectionKey);
    if (hasBundles) measure(1, _bundleSectionKey);
    for (int i = 0; i < cats.length; i++) {
      measure(i + 2, categoryKeys[i]);
    }
    if (realized.isEmpty) return;

    final List<MapEntry<int, double>> passed = realized.where((e) => e.value <= threshold).toList();
    int autoIndex = passed.isNotEmpty
        ? passed.map((e) => e.key).reduce((a, b) => a > b ? a : b)
        : realized.first.key;

    if (_pendingTabIndex != null &&
        scrollController.position.userScrollDirection != ScrollDirection.idle) {
      _pendingTabIndex = null;
    }

    if (_pendingTabIndex != null) {
      if (autoIndex < _pendingTabIndex!) {
        if (_categoryScrollIndex.value != _pendingTabIndex) {
          _categoryScrollIndex.value = _pendingTabIndex!;
        }
        return;
      }
      _pendingTabIndex = null;
    }

    if (_categoryScrollIndex.value != autoIndex) {
      _categoryScrollIndex.value = autoIndex;
    }
  }

  double _resolveBackToTopTop() {
    double anchorBottom = _appBarBottom;
    final BuildContext? tabsContext = _categoryTabsKey.currentContext;
    final RenderObject? renderObject = tabsContext?.findRenderObject();
    if (renderObject is RenderBox && renderObject.attached && renderObject.hasSize) {
      final double tabsTop = renderObject.localToGlobal(Offset.zero).dy;
      if (tabsTop <= _appBarBottom + 1) {
        anchorBottom = tabsTop + renderObject.size.height;
      }
    }
    return anchorBottom + _backToTopGap;
  }

  GlobalKey _getSectionKey(int index) {
    if (!categoryKeys.containsKey(index)) {
      categoryKeys[index] = GlobalKey();
    }
    return categoryKeys[index]!;
  }

  void _syncRows(StoreCategoryItemModel? model) {
    if (identical(_rowsSource, model)) return;
    _rowsSource = model;
    _sectionOffsets.clear();
    _tabToRowIndex..clear()..[0] = 0..[1] = 1;
    if (model == null) {
      _rows = const <_StoreRow>[];
      return;
    }

    final List<StoreItemCategory> cats = model.categories ?? [];
    final Map<String, List<StoreCardItem>> itemMap = model.categoryWiseItems ?? {};

    final List<_StoreRow> rows = [];
    for (int ci = 0; ci < cats.length; ci++) {
      final List<StoreCardItem> items = itemMap[cats[ci].id.toString()] ?? [];
      if (items.isEmpty) continue;
      _tabToRowIndex[ci + 2] = rows.length + 2; // header row's AutoScroll index
      rows.add(_HeaderRow(catIndex: ci, name: cats[ci].name ?? ''));
      for (int ii = 0; ii < items.length; ii++) {
        rows.add(_ItemRow(item: items[ii], indexInCat: ii, isFirst: ii == 0));
      }
    }

    assert(() {
      final Set<String> reachable = cats.map((StoreItemCategory c) => c.id.toString()).toSet();
      final Iterable<String> orphaned = itemMap.keys.where((String k) => !reachable.contains(k));
      if (orphaned.isNotEmpty) {
        final int lost = orphaned.fold(0, (int sum, String k) => sum + (itemMap[k]?.length ?? 0));
        debugPrint('StoreScreen: $lost item(s) under category id(s) ${orphaned.join(', ')} have no matching '
            'entry in `categories` and will NOT render.');
      }
      final int renderedItems = rows.whereType<_ItemRow>().length;
      if (model.totalSize != null && renderedItems < model.totalSize!) {
        debugPrint('StoreScreen: rendering $renderedItems of ${model.totalSize} items '
            '(server sent limit=${model.limit}, offset=${model.offset}) — response is truncated server-side.');
      }
      return true;
    }());

    _rows = rows;
  }

  Widget _buildMobileItemsSliver(Store store, StoreController storeController) {
    final StoreCategoryItemModel? model = storeController.storeCategoryItemsModel;
    _syncRows(model);

    if (model == null) {
      return const SliverToBoxAdapter(child: _StoreItemsLoadingList());
    }

    final List<_StoreRow> rows = _rows;
    final bool hasMostPopular = !storeController.isSearching &&
        (storeController.recommendedItemModel?.items?.isNotEmpty ?? false);
    final bool hasBundles = !storeController.isSearching && _hasBundlesFor(store.id);
    _syncTabsChanged(
      hasMostPopular: hasMostPopular, hasBundles: hasBundles,
      categoryCount: storeController.storeCategoryItemsModel?.categories?.length ?? 0,
    );
    if (rows.isEmpty && !hasMostPopular && !hasBundles) {
      return MultiSliver(children: [
        SliverFillRemaining(hasScrollBody: false,
          child: Container(height: 300, alignment: Alignment.center, child: Text('no_item_available'.tr)),
        ),
      ]);
    }

    return MultiSliver(children: [
      SliverToBoxAdapter(
        child: AutoScrollTag(
          key: const ValueKey('sec_0'),
          controller: scrollController,
          index: 0,
          child: KeyedSubtree(
            key: _popularSectionKey,
            child: _MostPopularItemsSection(store: store, storeController: storeController),
          ),
        ),
      ),
      if (hasBundles)
        SliverToBoxAdapter(
          child: AutoScrollTag(
            key: const ValueKey('sec_1'),
            controller: scrollController,
            index: 1,
            child: KeyedSubtree(key: _bundleSectionKey, child: BundleItemsTabSection(storeId: store.id!)),
          ),
        ),
      SliverList.builder(
        itemCount: rows.length + 1,
        itemBuilder: (context, i) {
          if (i == rows.length) {
            return Container(color: Theme.of(context).cardColor, height: _cartBarHeight);
          }
          return _buildStoreRow(context, rows[i], store, i + 2);
        },
      ),
    ]);
  }

  Widget _buildStoreRow(BuildContext context, _StoreRow row, Store store, int autoIndex) {
    if (row is _HeaderRow) {
      return AutoScrollTag(
        key: ValueKey('row_$autoIndex'),
        controller: scrollController,
        index: autoIndex,
        child: Container(
          key: _getSectionKey(row.catIndex),
          margin: const EdgeInsets.only(top: 4),
          color: Theme.of(context).cardColor,
          padding: const EdgeInsets.fromLTRB(Dimensions.paddingSizeDefault, 28, Dimensions.paddingSizeDefault, 6),
          child: Text(row.name, maxLines: 1, overflow: TextOverflow.ellipsis,
            style: robotoBold.copyWith(fontSize: Dimensions.fontSizeLarge),
          ),
        ),
      );
    }
    final _ItemRow itemRow = row as _ItemRow;
    return AutoScrollTag(
      key: ValueKey('row_$autoIndex'),
      controller: scrollController,
      index: autoIndex,
      child: Container(
        color: Theme.of(context).cardColor,
        child: Column(children: [
          if (!itemRow.isFirst) Padding(
            padding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeDefault),
            child: Divider(height: 1, color: Theme.of(context).dividerColor.withValues(alpha: 0.5)),
          ),
          _StoreCompactItemCard(data: itemRow.item, store: store, index: itemRow.indexInCat),
        ]),
      ),
    );
  }

  void _scrollToTop() {
    if (!scrollController.hasClients) return;
    scrollController.animateTo(0, duration: const Duration(milliseconds: 400), curve: Curves.easeOut);
  }

  void _openCartBottomSheet(int? storeId) {
    if (storeId == null || !mounted) return;
    CartScreen.openAsBottomSheet(context, storeId: storeId);
  }

  void _handleBack() {
    if (widget.fromDeeplink) {
      Get.find<SplashController>().setDeeplink(null);
      Get.offAllNamed(RouteHelper.getInitialRoute());
    } else {
      Get.back();
    }
  }

  void _openStoreSearch(Store store) {
    Get.toNamed(RouteHelper.getSearchStoreItemRoute(store.id));
  }

  Widget _buildStoreSliverHeader(BuildContext context, Store store, StoreController storeController) {
    final double topPadding = MediaQuery.of(context).padding.top;
    final double screenWidth = MediaQuery.of(context).size.width;
    final double bannerHeight = (screenWidth / 2).clamp(160.0, 320.0).toDouble();
    final double maxH = bannerHeight - topPadding;
    final double minH = 52 + topPadding;

    return SliverAppBar(
      pinned: true,
      expandedHeight: maxH,
      collapsedHeight: 52,
      toolbarHeight: 52,
      backgroundColor: Theme.of(context).cardColor,
      surfaceTintColor: Colors.transparent,
      elevation: 0,
      automaticallyImplyLeading: false,
      actions: const [SizedBox()],
      flexibleSpace: LayoutBuilder(builder: (BuildContext context, BoxConstraints constraints) {
        final double t = ((maxH - constraints.maxHeight) / (maxH - minH)).clamp(0.0, 1.0);
        final double coverOpacity = (1 - t * 1.6).clamp(0.0, 1.0);    
        final double barOpacity = ((t - 0.55) / 0.45).clamp(0.0, 1.0); 
        final double verifiedOpacity = (1 - t * 2).clamp(0.0, 1.0);   
        final double titleT = ((t - 0.8) / 0.2).clamp(0.0, 1.0);      
        return Stack(fit: StackFit.expand, children: <Widget>[
          Container(color: Theme.of(context).cardColor),

          Opacity(
            opacity: coverOpacity,
            child: IgnorePointer(
              ignoring: t > 0.5,
              child: Stack(children: <Widget>[
                Positioned.fill(
                  child: (storeController.storeBanners != null && storeController.storeBanners!.isNotEmpty)
                      ? StoreHeaderBanner(banners: storeController.storeBanners!, height: constraints.maxHeight)
                      : _StoreCoverImage(
                          url: store.coverPhotoFullUrl,
                          height: constraints.maxHeight,
                        ),
                ),

                PositionedDirectional(
                  top: topPadding + 12, start: Dimensions.paddingSizeDefault,
                  child: _StoreCircleIconButton(icon: Icons.arrow_back, onTap: _handleBack),
                ),

                PositionedDirectional(
                  top: topPadding + 12, end: Dimensions.paddingSizeDefault,
                  child: Row(mainAxisSize: MainAxisSize.min, children: <Widget>[
                    _StoreCircleIconButton(icon: CupertinoIcons.search, onTap: () => _openStoreSearch(store)),
                    const SizedBox(width: Dimensions.paddingSizeSmall),
                    if (AppConstants.webHostedUrl.isNotEmpty) ...[
                      _StoreCircleIconButton(icon: Icons.share_outlined, onTap: storeController.shareStore),
                      const SizedBox(width: Dimensions.paddingSizeSmall),
                    ],
                    _StoreFavouriteCircleButton(store: store),
                  ]),
                ),

                if (store.verifiedSeller == 1 && verifiedOpacity > 0)
                  Positioned(
                    left: Dimensions.paddingSizeDefault, bottom: Dimensions.paddingSizeDefault,
                    child: Opacity(opacity: verifiedOpacity, child: const _VerifiedChip()),
                  ),
              ]),
            ),
          ),

          Align(
            alignment: Alignment.topCenter,
            child: Opacity(
              opacity: barOpacity,
              child: IgnorePointer(
                ignoring: t < 0.5,
                child: Padding(
                  padding: EdgeInsets.only(top: topPadding, left: Dimensions.paddingSizeDefault, right: Dimensions.paddingSizeDefault),
                  child: Container(
                    height: 52,
                    alignment: Alignment.bottomCenter,
                    padding: const EdgeInsets.only(bottom: Dimensions.paddingSizeSmall),
                    child: Row(children: <Widget>[
                      _StoreSoftIconButton(icon: Icons.arrow_back, onTap: _handleBack),
                      const SizedBox(width: Dimensions.paddingSizeSmall),
                      Expanded(
                        child: ClipRect(
                          child: Transform.translate(
                            offset: Offset(0, (1 - titleT) * 14),
                            child: Opacity(
                              opacity: titleT,
                              child: Text(store.name ?? '', maxLines: 1, overflow: TextOverflow.ellipsis,
                                style: robotoBold.copyWith(fontSize: Dimensions.fontSizeLarge),
                              ),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: Dimensions.paddingSizeSmall),
                      _StoreSoftIconButton(icon: CupertinoIcons.search, onTap: () => _openStoreSearch(store)),
                    ]),
                  ),
                ),
              ),
            ),
          ),
        ]);
      }),
    );
  }

  @override
  Widget build(BuildContext context) {
    _appBarBottom = 70 + MediaQuery.of(context).padding.top;
    _pinnedTopInset = _appBarBottom + 40;
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) async {
        print('===did pop: $didPop, result: $result');
        if (Get.find<SplashController>().deeplinkRoute != null) {
          Get.find<SplashController>().setDeeplink(null);
          Get.offAllNamed(RouteHelper.getInitialRoute());
        } else {
          try {
            Get.back();
          } catch (e) {
            return;
          }
        }
      },
      child: Scaffold(
        appBar: ResponsiveHelper.isDesktop(context) ? const WebMenuBar() : null,
        endDrawer: const MenuDrawer(),
        endDrawerEnableOpenDragGesture: false,
        backgroundColor: Theme.of(context).colorScheme.surface,
        body: GetBuilder<StoreController>(
          builder: (storeController) {
            return GetBuilder<CategoryController>(
              builder: (categoryController) {
                Store? store;
                if (storeController.store != null &&
                    storeController.store!.name != null &&
                    categoryController.categoryList != null) {
                  store = storeController.store;
                  storeController.setCategoryList();

                  print(
                    '=====> store zone id: ${store!.zoneId}, schedule length: ${store.schedules != null ? store.schedules!.length : 'null'}',
                  );
                }

                final double mobileStoreCoverHeight =
                    MediaQuery.sizeOf(context).width / 3;
                final double mobileStoreInfoHeight = store?.discount != null
                    ? 165
                    : 100;
                final double mobileStoreExpandedHeight =
                    mobileStoreCoverHeight + mobileStoreInfoHeight;

                return (storeController.store != null &&
                        storeController.store!.name != null &&
                        categoryController.categoryList != null)
                    ? CustomScrollView(
                        physics: const AlwaysScrollableScrollPhysics(),
                        controller: scrollController,
                        slivers: [
                          ResponsiveHelper.isDesktop(context)
                              ? SliverToBoxAdapter(
                                  child: Container(
                                    color: const Color(0xFF171A29),
                                    padding: const EdgeInsets.all(
                                      Dimensions.paddingSizeLarge,
                                    ),
                                    alignment: Alignment.center,
                                    child: Center(
                                      child: SizedBox(
                                        width: Dimensions.webMaxWidth,
                                        child: Padding(
                                          padding: const EdgeInsets.symmetric(
                                            horizontal:
                                                Dimensions.paddingSizeSmall,
                                          ),
                                          child: Row(
                                            children: [
                                              Expanded(
                                                child: ClipRRect(
                                                  borderRadius:
                                                      BorderRadius.circular(
                                                        Dimensions
                                                            .radiusDefault,
                                                      ),
                                                  child: Stack(
                                                    children: [
                                                      CustomImage(
                                                        fit: BoxFit.cover,
                                                        height: 240,
                                                        width: 590,
                                                        image:
                                                            store
                                                                ?.coverPhotoFullUrl ??
                                                            '',
                                                      ),

                                                      store?.discount != null
                                                          ? Positioned(
                                                              bottom: 0,
                                                              left: 0,
                                                              right: 0,
                                                              child: Container(
                                                                width: double
                                                                    .infinity,
                                                                decoration: BoxDecoration(
                                                                  color: Theme.of(
                                                                    context,
                                                                  ).primaryColor,
                                                                ),
                                                                padding:
                                                                    const EdgeInsets.all(
                                                                      Dimensions
                                                                          .paddingSizeExtraSmall,
                                                                    ),
                                                                child: Text(
                                                                  '${store?.discount!.discountType == 'percent' ? '${store?.discount!.discount}%' : PriceConverter.convertPrice(store?.discount!.discount)} '
                                                                  '${'discount_will_be_applicable_when_order_amount_exceeds_is_more_than'.tr} ${PriceConverter.convertPrice(store?.discount!.minPurchase)},'
                                                                  ' ${'Max'.tr}: ${PriceConverter.convertPrice(store?.discount!.maxDiscount)} ${'discount_is_applicable'.tr}',
                                                                  style: robotoMedium.copyWith(
                                                                    fontSize:
                                                                        Dimensions
                                                                            .fontSizeSmall,
                                                                    color: Colors
                                                                        .white,
                                                                  ),
                                                                  textAlign:
                                                                      TextAlign
                                                                          .center,
                                                                  maxLines: 2,
                                                                  overflow:
                                                                      TextOverflow
                                                                          .ellipsis,
                                                                ),
                                                              ),
                                                            )
                                                          : const SizedBox(),
                                                    ],
                                                  ),
                                                ),
                                              ),
                                              const SizedBox(
                                                width:
                                                    Dimensions.paddingSizeLarge,
                                              ),

                                              Expanded(
                                                child:
                                                    StoreDescriptionViewWidget(
                                                      store: store,
                                                    ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                )
                              : SliverAppBar(
                                  expandedHeight: mobileStoreExpandedHeight,
                                  toolbarHeight: mobileStoreInfoHeight,
                                  pinned: true,
                                  floating: false,
                                  elevation: 0.5,
                                  backgroundColor: Theme.of(context).cardColor,
                                  leading: IconButton(
                                    icon: Container(
                                      height: 50,
                                      width: 50,
                                      decoration: BoxDecoration(
                                        shape: BoxShape.circle,
                                        color: Theme.of(context).primaryColor,
                                      ),
                                      alignment: Alignment.center,
                                      child: Icon(
                                        Icons.chevron_left,
                                        color: Theme.of(context).cardColor,
                                      ),
                                    ),
                                    onPressed: () {
                                      if (Get.find<SplashController>()
                                              .deeplinkRoute !=
                                          null) {
                                        Get.find<SplashController>()
                                            .setDeeplink(null);
                                        Get.offAllNamed(
                                          RouteHelper.getInitialRoute(),
                                        );
                                      } else {
                                        Get.back();
                                      }
                                    },
                                  ),
                                  flexibleSpace: FlexibleSpaceBar(
                                    titlePadding: EdgeInsets.zero,
                                    centerTitle: true,
                                    expandedTitleScale: 1.1,
                                    title: CustomizableSpaceBarWidget(
                                      builder: (context, scrollingRate) {
                                        final Store currentStore = store!;
                                        return Container(
                                          height: mobileStoreInfoHeight,
                                          decoration: BoxDecoration(
                                            color: Theme.of(context).cardColor,
                                            borderRadius:
                                                const BorderRadius.vertical(
                                                  top: Radius.circular(
                                                    Dimensions.radiusLarge,
                                                  ),
                                                ),
                                          ),
                                          child: Column(
                                            children: [
                                              currentStore.discount != null
                                                  ? Container(
                                                      width: double.infinity,
                                                      decoration: BoxDecoration(
                                                        color: Theme.of(context)
                                                            .primaryColor
                                                            .withValues(
                                                              alpha:
                                                                  1 -
                                                                  scrollingRate,
                                                            ),
                                                        borderRadius:
                                                            const BorderRadius.vertical(
                                                              top: Radius.circular(
                                                                Dimensions
                                                                    .radiusLarge,
                                                              ),
                                                            ),
                                                      ),
                                                      padding: EdgeInsets.all(
                                                        Dimensions
                                                                .paddingSizeSmall -
                                                            (GetPlatform
                                                                    .isAndroid
                                                                ? (scrollingRate *
                                                                      Dimensions
                                                                          .paddingSizeSmall)
                                                                : 0),
                                                      ),
                                                      child: Text(
                                                        '${currentStore.discount!.discountType == 'percent' ? '${currentStore.discount!.discount}%' : PriceConverter.convertPrice(currentStore.discount!.discount)} '
                                                        '${'discount_will_be_applicable_when_order_amount_exceeds_is_more_than'.tr} ${PriceConverter.convertPrice(currentStore.discount!.minPurchase)},'
                                                        ' ${'Max'.tr}: ${PriceConverter.convertPrice(currentStore.discount!.maxDiscount)} ${'discount_is_applicable'.tr}',
                                                        style: robotoMedium.copyWith(
                                                          fontSize: Dimensions
                                                              .fontSizeSmall,
                                                          color: Colors.white
                                                              .withValues(
                                                                alpha:
                                                                    1 -
                                                                    scrollingRate,
                                                              ),
                                                        ),
                                                        textAlign:
                                                            TextAlign.center,
                                                        maxLines: 3,
                                                        overflow: TextOverflow
                                                            .ellipsis,
                                                      ),
                                                    )
                                                  : const SizedBox(),

                                              Container(
                                                color: Theme.of(context)
                                                    .cardColor
                                                    .withValues(
                                                      alpha: scrollingRate,
                                                    ),
                                                padding: EdgeInsets.only(
                                                  bottom: 0,
                                                  left:
                                                      Get.find<
                                                            LocalizationController
                                                          >()
                                                          .isLtr
                                                      ? 40 * scrollingRate
                                                      : 0,
                                                  right:
                                                      Get.find<
                                                            LocalizationController
                                                          >()
                                                          .isLtr
                                                      ? 0
                                                      : 40 * scrollingRate,
                                                ),
                                                child: Align(
                                                  alignment:
                                                      Alignment.bottomLeft,
                                                  child: Container(
                                                    height: 89,
                                                    color: Theme.of(context)
                                                        .cardColor
                                                        .withValues(
                                                          alpha:
                                                              scrollingRate ==
                                                                  0.0
                                                              ? 1
                                                              : 0,
                                                        ),
                                                    padding: EdgeInsets.only(
                                                      left:
                                                          Get.find<
                                                                LocalizationController
                                                              >()
                                                              .isLtr
                                                          ? 20
                                                          : 0,
                                                      right:
                                                          Get.find<
                                                                LocalizationController
                                                              >()
                                                              .isLtr
                                                          ? 0
                                                          : 20,
                                                    ),
                                                    child: Row(
                                                      children: [
                                                        ClipRRect(
                                                          borderRadius:
                                                              BorderRadius.circular(
                                                                Dimensions
                                                                    .radiusSmall,
                                                              ),
                                                          child: Stack(
                                                            children: [
                                                              CustomImage(
                                                                image:
                                                                    '${currentStore.logoFullUrl}',
                                                                height:
                                                                    60 -
                                                                    (scrollingRate *
                                                                        15),
                                                                width:
                                                                    70 -
                                                                    (scrollingRate *
                                                                        15),
                                                                fit: BoxFit
                                                                    .cover,
                                                              ),

                                                              storeController.isStoreOpenNow(
                                                                    currentStore
                                                                        .active!,
                                                                    currentStore
                                                                        .schedules,
                                                                  )
                                                                  ? const SizedBox()
                                                                  : Positioned(
                                                                      bottom: 0,
                                                                      left: 0,
                                                                      right: 0,
                                                                      child: Container(
                                                                        height:
                                                                            30,
                                                                        alignment:
                                                                            Alignment.center,
                                                                        decoration: BoxDecoration(
                                                                          borderRadius: const BorderRadius.vertical(
                                                                            bottom: Radius.circular(
                                                                              Dimensions.radiusSmall,
                                                                            ),
                                                                          ),
                                                                          color: Colors.black.withValues(
                                                                            alpha:
                                                                                0.6,
                                                                          ),
                                                                        ),
                                                                        child: Text(
                                                                          'closed_now'
                                                                              .tr,
                                                                          textAlign:
                                                                              TextAlign.center,
                                                                          style: robotoRegular.copyWith(
                                                                            color:
                                                                                Colors.white,
                                                                            fontSize:
                                                                                Dimensions.fontSizeSmall,
                                                                          ),
                                                                        ),
                                                                      ),
                                                                    ),
                                                            ],
                                                          ),
                                                        ),
                                                        const SizedBox(
                                                          width: Dimensions
                                                              .paddingSizeSmall,
                                                        ),

                                                        Expanded(
                                                          child: Column(
                                                            crossAxisAlignment:
                                                                CrossAxisAlignment
                                                                    .start,
                                                            mainAxisAlignment:
                                                                MainAxisAlignment
                                                                    .center,
                                                            children: [
                                                              Row(
                                                                children: [
                                                                  Flexible(
                                                                    child: Text(
                                                                      currentStore
                                                                          .name!,
                                                                      style: robotoMedium.copyWith(
                                                                        fontSize:
                                                                            Dimensions.fontSizeLarge -
                                                                            (scrollingRate *
                                                                                3),
                                                                        color: Theme.of(
                                                                          context,
                                                                        ).textTheme.bodyMedium!.color,
                                                                      ),
                                                                      maxLines:
                                                                          1,
                                                                      overflow:
                                                                          TextOverflow
                                                                              .ellipsis,
                                                                    ),
                                                                  ),
                                                                  if (currentStore
                                                                          .verifiedSeller ==
                                                                      1) ...[
                                                                    const SizedBox(
                                                                      width: 5,
                                                                    ),
                                                                    VerifiedSellerBadge(
                                                                      verified:
                                                                          true,
                                                                      size:
                                                                          16 -
                                                                          (scrollingRate *
                                                                              2),
                                                                    ),
                                                                  ],
                                                                  const SizedBox(
                                                                    width: Dimensions
                                                                        .paddingSizeSmall,
                                                                  ),
                                                                ],
                                                              ),
                                                              const SizedBox(
                                                                height: Dimensions
                                                                    .paddingSizeExtraSmall,
                                                              ),
                                                              Text(
                                                                currentStore
                                                                        .address ??
                                                                    '',
                                                                maxLines: 1,
                                                                overflow:
                                                                    TextOverflow
                                                                        .ellipsis,
                                                                style: robotoRegular.copyWith(
                                                                  fontSize:
                                                                      Dimensions
                                                                          .fontSizeSmall -
                                                                      (scrollingRate *
                                                                          2),
                                                                  color: Theme.of(
                                                                    context,
                                                                  ).disabledColor,
                                                                ),
                                                              ),
                                                              SizedBox(
                                                                height:
                                                                    ResponsiveHelper.isDesktop(
                                                                      context,
                                                                    )
                                                                    ? Dimensions
                                                                          .paddingSizeExtraSmall
                                                                    : 0,
                                                              ),
                                                              Row(
                                                                children: [
                                                                  Flexible(
                                                                    child: Text(
                                                                      'minimum_order'
                                                                          .tr,
                                                                      style: robotoRegular.copyWith(
                                                                        fontSize:
                                                                            Dimensions.fontSizeExtraSmall -
                                                                            (scrollingRate *
                                                                                2),
                                                                        color: Theme.of(
                                                                          context,
                                                                        ).disabledColor,
                                                                      ),
                                                                      maxLines:
                                                                          1,
                                                                      overflow:
                                                                          TextOverflow
                                                                              .ellipsis,
                                                                    ),
                                                                  ),
                                                                  const SizedBox(
                                                                    width: Dimensions
                                                                        .paddingSizeExtraSmall,
                                                                  ),
                                                                  Text(
                                                                    PriceConverter.convertPrice(
                                                                      currentStore
                                                                          .minimumOrder,
                                                                    ),
                                                                    textDirection:
                                                                        TextDirection
                                                                            .ltr,
                                                                    style: robotoMedium.copyWith(
                                                                      fontSize:
                                                                          Dimensions
                                                                              .fontSizeExtraSmall -
                                                                          (scrollingRate *
                                                                              2),
                                                                      color: Theme.of(
                                                                        context,
                                                                      ).primaryColor,
                                                                    ),
                                                                  ),
                                                                ],
                                                              ),
                                                            ],
                                                          ),
                                                        ),

                                                        GetBuilder<
                                                          FavouriteController
                                                        >(
                                                          builder: (favouriteController) {
                                                            bool isWished =
                                                                favouriteController
                                                                    .wishStoreIdList
                                                                    .contains(
                                                                      currentStore
                                                                          .id,
                                                                    );
                                                            return InkWell(
                                                              onTap: () {
                                                                if (AuthHelper.isLoggedIn()) {
                                                                  isWished
                                                                      ? favouriteController.removeFromFavouriteList(
                                                                          currentStore
                                                                              .id,
                                                                          true,
                                                                        )
                                                                      : favouriteController.addToFavouriteList(
                                                                          null,
                                                                          currentStore
                                                                              .id,
                                                                          true,
                                                                        );
                                                                } else {
                                                                  showCustomSnackBar(
                                                                    'you_are_not_logged_in'
                                                                        .tr,
                                                                  );
                                                                }
                                                              },
                                                              child: Container(
                                                                decoration: BoxDecoration(
                                                                  color:
                                                                      Theme.of(
                                                                        context,
                                                                      ).primaryColor.withValues(
                                                                        alpha:
                                                                            0.1,
                                                                      ),
                                                                  borderRadius:
                                                                      BorderRadius.circular(
                                                                        Dimensions
                                                                            .radiusDefault,
                                                                      ),
                                                                ),
                                                                padding:
                                                                    const EdgeInsets.all(
                                                                      Dimensions
                                                                          .paddingSizeExtraSmall,
                                                                    ),
                                                                child: Icon(
                                                                  isWished
                                                                      ? Icons
                                                                            .favorite
                                                                      : Icons
                                                                            .favorite_border,
                                                                  color:
                                                                      isWished
                                                                      ? Theme.of(
                                                                          context,
                                                                        ).primaryColor
                                                                      : Theme.of(
                                                                          context,
                                                                        ).disabledColor,
                                                                  size:
                                                                      24 -
                                                                      (scrollingRate *
                                                                          4),
                                                                ),
                                                              ),
                                                            );
                                                          },
                                                        ),
                                                        const SizedBox(
                                                          width: Dimensions
                                                              .paddingSizeSmall,
                                                        ),

                                                        AppConstants
                                                                .webHostedUrl
                                                                .isNotEmpty
                                                            ? InkWell(
                                                                onTap: () {
                                                                  storeController
                                                                      .shareStore();
                                                                },
                                                                child: Container(
                                                                  decoration: BoxDecoration(
                                                                    color:
                                                                        Theme.of(
                                                                          context,
                                                                        ).primaryColor.withValues(
                                                                          alpha:
                                                                              0.1,
                                                                        ),
                                                                    borderRadius:
                                                                        BorderRadius.circular(
                                                                          Dimensions
                                                                              .radiusDefault,
                                                                        ),
                                                                  ),
                                                                  padding: const EdgeInsets.all(
                                                                    Dimensions
                                                                        .paddingSizeExtraSmall,
                                                                  ),
                                                                  child: Icon(
                                                                    Icons.share,
                                                                    size:
                                                                        24 -
                                                                        (scrollingRate *
                                                                            4),
                                                                  ),
                                                                ),
                                                              )
                                                            : const SizedBox(),
                                                        const SizedBox(
                                                          width: Dimensions
                                                              .paddingSizeSmall,
                                                        ),
                                                      ],
                                                    ),
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                        );
                                      },
                                    ),
                                    background: ColoredBox(
                                      color: Theme.of(context).cardColor,
                                      child: Align(
                                        alignment: Alignment.topCenter,
                                        child: SizedBox(
                                          height: mobileStoreCoverHeight,
                                          width: double.infinity,
                                          child: CustomImage(
                                            fit: BoxFit.contain,
                                            height: mobileStoreCoverHeight,
                                            width: double.infinity,
                                            image:
                                                '${store!.coverPhotoFullUrl}',
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                  actions: const [SizedBox()],
                                ),

                          (ResponsiveHelper.isDesktop(context) &&
                                  storeController.recommendedItemModel !=
                                      null &&
                                  storeController
                                      .recommendedItemModel!
                                      .items!
                                      .isNotEmpty)
                              ? SliverToBoxAdapter(
                                  child: Container(
                                    color: Theme.of(
                                      context,
                                    ).primaryColor.withValues(alpha: 0.10),
                                    child: Center(
                                      child: SizedBox(
                                        width: Dimensions.webMaxWidth,
                                        height:
                                            ResponsiveHelper.isDesktop(context)
                                            ? 325
                                            : 125,
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            const SizedBox(
                                              height:
                                                  Dimensions.paddingSizeSmall,
                                            ),
                                            Text(
                                              'recommended_for_you'.tr,
                                              style: robotoMedium.copyWith(
                                                fontSize:
                                                    Dimensions.fontSizeLarge,
                                                fontWeight: FontWeight.w700,
                                              ),
                                            ),
                                            const SizedBox(
                                              height: Dimensions
                                                  .paddingSizeExtraSmall,
                                            ),
                                            Text(
                                              'here_is_what_you_might_like'.tr,
                                              style: robotoRegular.copyWith(
                                                fontSize:
                                                    Dimensions.fontSizeSmall,
                                                color: Theme.of(
                                                  context,
                                                ).disabledColor,
                                              ),
                                            ),
                                            const SizedBox(
                                              height: Dimensions
                                                  .paddingSizeExtraSmall,
                                            ),

                                            SizedBox(
                                              height: 250,
                                              child: ListView.builder(
                                                shrinkWrap: true,
                                                scrollDirection:
                                                    Axis.horizontal,
                                                itemCount: storeController
                                                    .recommendedItemModel!
                                                    .items!
                                                    .length,
                                                physics:
                                                    const BouncingScrollPhysics(),
                                                padding:
                                                    const EdgeInsets.symmetric(
                                                      vertical: Dimensions
                                                          .paddingSizeExtraSmall,
                                                    ),
                                                itemBuilder: (context, index) {
                                                  return Container(
                                                    width: 225,
                                                    padding: const EdgeInsets.only(
                                                      right: Dimensions
                                                          .paddingSizeSmall,
                                                      left: Dimensions
                                                          .paddingSizeExtraSmall,
                                                    ),
                                                    margin:
                                                        const EdgeInsets.only(
                                                          right: Dimensions
                                                              .paddingSizeSmall,
                                                        ),
                                                    child: WebItemWidget(
                                                      isStore: false,
                                                      item: storeController
                                                          .recommendedItemModel!
                                                          .items![index],
                                                      store: null,
                                                      index: index,
                                                      length: null,
                                                      isCampaign: false,
                                                      inStore: true,
                                                    ),
                                                  );
                                                },
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ),
                                )
                              : const SliverToBoxAdapter(child: SizedBox()),
                          const SliverToBoxAdapter(
                            child: SizedBox(
                              height: Dimensions.paddingSizeSmall,
                            ),
                          ),

                          ///web view..
                          ResponsiveHelper.isDesktop(context)
                              ? SliverToBoxAdapter(
                                  child: FooterView(
                                    child: SizedBox(
                                      width: Dimensions.webMaxWidth,
                                      child: Padding(
                                        padding: const EdgeInsets.only(
                                          top: Dimensions.paddingSizeSmall,
                                        ),
                                        child: Row(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          mainAxisAlignment:
                                              MainAxisAlignment.start,
                                          children: [
                                            SizedBox(
                                              width: 175,
                                              child: Row(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                children: [
                                                  Expanded(
                                                    child: ListView.builder(
                                                      shrinkWrap: true,
                                                      scrollDirection:
                                                          Axis.vertical,
                                                      itemCount: storeController
                                                          .categoryList!
                                                          .length,
                                                      padding:
                                                          const EdgeInsets.only(
                                                            left: Dimensions
                                                                .paddingSizeSmall,
                                                          ),
                                                      physics:
                                                          const NeverScrollableScrollPhysics(),
                                                      itemBuilder: (context, index) {
                                                        return InkWell(
                                                          onTap: () {
                                                            storeController
                                                                .setCategoryIndex(
                                                                  index,
                                                                  itemSearching:
                                                                      storeController
                                                                          .isSearching,
                                                                );
                                                          },
                                                          child: Padding(
                                                            padding: const EdgeInsets.only(
                                                              bottom: Dimensions
                                                                  .paddingSizeSmall,
                                                            ),
                                                            child: Container(
                                                              padding: const EdgeInsets.symmetric(
                                                                horizontal:
                                                                    Dimensions
                                                                        .paddingSizeSmall,
                                                                vertical: Dimensions
                                                                    .paddingSizeExtraSmall,
                                                              ),
                                                              decoration: BoxDecoration(
                                                                gradient: LinearGradient(
                                                                  begin: Alignment
                                                                      .bottomRight,
                                                                  end: Alignment
                                                                      .topLeft,
                                                                  colors: <Color>[
                                                                    index ==
                                                                            storeController.categoryIndex
                                                                        ? Theme.of(
                                                                            context,
                                                                          ).primaryColor.withValues(
                                                                            alpha:
                                                                                0.50,
                                                                          )
                                                                        : Colors
                                                                              .transparent,
                                                                    index ==
                                                                            storeController.categoryIndex
                                                                        ? Theme.of(
                                                                            context,
                                                                          ).cardColor
                                                                        : Colors
                                                                              .transparent,
                                                                  ],
                                                                ),
                                                              ),
                                                              child: Column(
                                                                mainAxisAlignment:
                                                                    MainAxisAlignment
                                                                        .center,
                                                                crossAxisAlignment:
                                                                    CrossAxisAlignment
                                                                        .start,
                                                                children: [
                                                                  Text(
                                                                    storeController
                                                                        .categoryList![index]
                                                                        .name!,
                                                                    maxLines: 1,
                                                                    overflow:
                                                                        TextOverflow
                                                                            .ellipsis,
                                                                    style:
                                                                        index ==
                                                                            storeController.categoryIndex
                                                                        ? robotoMedium.copyWith(
                                                                            fontSize:
                                                                                Dimensions.fontSizeSmall,
                                                                            color: Theme.of(
                                                                              context,
                                                                            ).primaryColor,
                                                                          )
                                                                        : robotoRegular.copyWith(
                                                                            fontSize:
                                                                                Dimensions.fontSizeSmall,
                                                                          ),
                                                                  ),
                                                                ],
                                                              ),
                                                            ),
                                                          ),
                                                        );
                                                      },
                                                    ),
                                                  ),

                                                  Container(
                                                    height:
                                                        storeController
                                                            .categoryList!
                                                            .length *
                                                        50,
                                                    width: 1,
                                                    color: Theme.of(context)
                                                        .disabledColor
                                                        .withValues(alpha: 0.5),
                                                  ),
                                                ],
                                              ),
                                            ),
                                            const SizedBox(
                                              width:
                                                  Dimensions.paddingSizeLarge,
                                            ),

                                            Expanded(
                                              child: Column(
                                                children: [
                                                  Row(
                                                    mainAxisAlignment:
                                                        MainAxisAlignment.end,
                                                    children: [
                                                      Container(
                                                        padding:
                                                            const EdgeInsets.all(
                                                              Dimensions
                                                                  .paddingSizeExtraSmall,
                                                            ),
                                                        height: 45,
                                                        width: 430,
                                                        decoration: BoxDecoration(
                                                          borderRadius:
                                                              BorderRadius.circular(
                                                                Dimensions
                                                                    .radiusDefault,
                                                              ),
                                                          color: Theme.of(
                                                            context,
                                                          ).cardColor,
                                                          border: Border.all(
                                                            color:
                                                                Theme.of(
                                                                      context,
                                                                    )
                                                                    .primaryColor
                                                                    .withValues(
                                                                      alpha:
                                                                          0.40,
                                                                    ),
                                                          ),
                                                        ),
                                                        child: Row(
                                                          children: [
                                                            Expanded(
                                                              child: TextField(
                                                                controller:
                                                                    _searchController,
                                                                textInputAction:
                                                                    TextInputAction
                                                                        .search,
                                                                decoration: InputDecoration(
                                                                  contentPadding:
                                                                      const EdgeInsets.symmetric(
                                                                        horizontal:
                                                                            0,
                                                                        vertical:
                                                                            0,
                                                                      ),
                                                                  hintText:
                                                                      'search_for_items'
                                                                          .tr,
                                                                  hintStyle: robotoRegular.copyWith(
                                                                    fontSize:
                                                                        Dimensions
                                                                            .fontSizeSmall,
                                                                    color: Theme.of(
                                                                      context,
                                                                    ).disabledColor,
                                                                  ),
                                                                  border: OutlineInputBorder(
                                                                    borderRadius:
                                                                        BorderRadius.circular(
                                                                          Dimensions
                                                                              .radiusSmall,
                                                                        ),
                                                                    borderSide:
                                                                        BorderSide
                                                                            .none,
                                                                  ),
                                                                  filled: true,
                                                                  fillColor:
                                                                      Theme.of(
                                                                        context,
                                                                      ).cardColor,
                                                                  isDense: true,
                                                                  prefixIcon: Icon(
                                                                    Icons
                                                                        .search,
                                                                    color: Theme.of(context)
                                                                        .primaryColor
                                                                        .withValues(
                                                                          alpha:
                                                                              0.50,
                                                                        ),
                                                                  ),
                                                                ),
                                                                onSubmitted: (String? value) {
                                                                  if (value!
                                                                      .isNotEmpty) {
                                                                    Get.find<
                                                                          StoreController
                                                                        >()
                                                                        .getStoreSearchItemList(
                                                                          _searchController
                                                                              .text
                                                                              .trim(),
                                                                          widget
                                                                              .store!
                                                                              .id
                                                                              .toString(),
                                                                          1,
                                                                          storeController
                                                                              .type,
                                                                        );
                                                                  }
                                                                },
                                                                onChanged:
                                                                    (
                                                                      String?
                                                                      value,
                                                                    ) {},
                                                              ),
                                                            ),
                                                            const SizedBox(
                                                              width: Dimensions
                                                                  .paddingSizeSmall,
                                                            ),

                                                            !storeController
                                                                    .isSearching
                                                                ? CustomButton(
                                                                    radius: Dimensions
                                                                        .radiusSmall,
                                                                    height: 40,
                                                                    width: 74,
                                                                    buttonText:
                                                                        'search'
                                                                            .tr,
                                                                    isBold:
                                                                        false,
                                                                    fontSize:
                                                                        Dimensions
                                                                            .fontSizeSmall,
                                                                    onPressed: () {
                                                                      storeController.getStoreSearchItemList(
                                                                        _searchController
                                                                            .text
                                                                            .trim(),
                                                                        widget
                                                                            .store!
                                                                            .id
                                                                            .toString(),
                                                                        1,
                                                                        storeController
                                                                            .type,
                                                                      );
                                                                    },
                                                                  )
                                                                : InkWell(
                                                                    onTap: () {
                                                                      _searchController
                                                                              .text =
                                                                          '';
                                                                      storeController
                                                                          .initSearchData();
                                                                      storeController
                                                                          .changeSearchStatus();
                                                                    },
                                                                    child: Container(
                                                                      decoration: BoxDecoration(
                                                                        color: Theme.of(
                                                                          context,
                                                                        ).primaryColor,
                                                                        borderRadius: BorderRadius.circular(
                                                                          Dimensions
                                                                              .radiusSmall,
                                                                        ),
                                                                      ),
                                                                      padding: const EdgeInsets.symmetric(
                                                                        vertical:
                                                                            3,
                                                                        horizontal:
                                                                            Dimensions.paddingSizeSmall,
                                                                      ),
                                                                      child: const Icon(
                                                                        Icons
                                                                            .clear,
                                                                        color: Colors
                                                                            .white,
                                                                      ),
                                                                    ),
                                                                  ),
                                                          ],
                                                        ),
                                                      ),
                                                      const SizedBox(
                                                        width: Dimensions
                                                            .paddingSizeDefault,
                                                      ),

                                                      InkWell(
                                                        onTap: () {
                                                          List<double?> prices =
                                                              [];
                                                          for (var product
                                                              in Get.find<
                                                                    StoreController
                                                                  >()
                                                                  .storeItemModel!
                                                                  .items!) {
                                                            prices.add(
                                                              product.price,
                                                            );
                                                          }
                                                          prices.sort();
                                                          double? maxValue =
                                                              prices.isNotEmpty
                                                              ? prices[prices
                                                                        .length -
                                                                    1]
                                                              : 1000;
                                                          Get.dialog(
                                                            FilterWidget(
                                                              maxValue:
                                                                  maxValue,
                                                            ),
                                                          );
                                                        },
                                                        child: Container(
                                                          decoration: BoxDecoration(
                                                            borderRadius:
                                                                BorderRadius.circular(
                                                                  Dimensions
                                                                      .radiusDefault,
                                                                ),
                                                            color: Theme.of(
                                                              context,
                                                            ).cardColor,
                                                            border: Border.all(
                                                              color: Theme.of(
                                                                context,
                                                              ).primaryColor,
                                                              width: 1,
                                                            ),
                                                          ),
                                                          padding:
                                                              const EdgeInsets.all(
                                                                Dimensions
                                                                    .paddingSizeExtraSmall,
                                                              ),
                                                          child: Icon(
                                                            Icons.filter_list,
                                                            size: 24,
                                                            color: Theme.of(
                                                              context,
                                                            ).primaryColor,
                                                          ),
                                                        ),
                                                      ),

                                                      /*(Get.find<SplashController>().configModel!.moduleConfig!.module!.vegNonVeg! && Get.find<SplashController>().configModel!.toggleVegNonVeg!)
                                    ? SizedBox(
                                      width: 300,
                                      height:  30,
                                      child:  ListView.builder(
                                        shrinkWrap: true,
                                        scrollDirection: Axis.horizontal,
                                        itemCount: Get.find<ItemController>().itemTypeList.length,
                                        padding: const EdgeInsets.only(left: Dimensions.paddingSizeSmall),
                                        physics: const NeverScrollableScrollPhysics(),
                                        itemBuilder: (context, index) {
                                          return Padding(
                                            padding: const EdgeInsets.only(right: Dimensions.paddingSizeSmall),
                                            child:  CustomCheckBoxWidget(
                                              title: Get.find<ItemController>().itemTypeList[index].tr,
                                              value: storeController.type == Get.find<ItemController>().itemTypeList[index],
                                              onClick: () {
                                                if(storeController.isSearching){
                                                  storeController.getStoreSearchItemList(
                                                    storeController.searchText, widget.store!.id.toString(), 1, Get.find<ItemController>().itemTypeList[index],
                                                  );
                                                } else {
                                                  storeController.getStoreItemList(storeController.store!.id, 1, Get.find<ItemController>().itemTypeList[index], true);
                                                }
                                              },
                                            ),
                                          );
                                        },
                                      ),
                                    ) : const SizedBox(),*/
                                                    ],
                                                  ),
                                                  const SizedBox(
                                                    height: Dimensions
                                                        .paddingSizeSmall,
                                                  ),

                                                  PaginatedListView(
                                                    scrollController:
                                                        scrollController,
                                                    onPaginate: (int? offset) async {
                                                      if (storeController
                                                          .isSearching) {
                                                        await storeController
                                                            .getStoreSearchItemList(
                                                              storeController
                                                                  .searchText,
                                                              widget.store!.id
                                                                  .toString(),
                                                              offset!,
                                                              storeController
                                                                  .type,
                                                            );
                                                      } else {
                                                        await storeController
                                                            .getStoreItemList(
                                                              widget
                                                                      .store!
                                                                      .id ??
                                                                  storeController
                                                                      .store!
                                                                      .id,
                                                              offset!,
                                                              storeController
                                                                  .type,
                                                              false,
                                                            );
                                                      }
                                                    },
                                                    totalSize:
                                                        storeController
                                                            .isSearching
                                                        ? storeController
                                                              .storeSearchItemModel
                                                              ?.totalSize
                                                        : storeController
                                                              .storeItemModel
                                                              ?.totalSize,
                                                    offset:
                                                        storeController
                                                            .isSearching
                                                        ? storeController
                                                              .storeSearchItemModel
                                                              ?.offset
                                                        : storeController
                                                              .storeItemModel
                                                              ?.offset,
                                                    itemView: WebItemsView(
                                                      isStore: false,
                                                      stores: null,
                                                      fromStore: true,
                                                      items:
                                                          storeController
                                                              .isSearching
                                                          ? storeController
                                                                .storeSearchItemModel
                                                                ?.items
                                                          : (storeController
                                                                    .categoryList!
                                                                    .isNotEmpty &&
                                                                storeController
                                                                        .storeItemModel !=
                                                                    null)
                                                          ? storeController
                                                                .storeItemModel!
                                                                .items
                                                          : null,
                                                      inStorePage: true,
                                                      padding: const EdgeInsets.symmetric(
                                                        horizontal: Dimensions
                                                            .paddingSizeSmall,
                                                        vertical: Dimensions
                                                            .paddingSizeSmall,
                                                      ),
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ),
                                )
                              : const SliverToBoxAdapter(child: SizedBox()),

                          ///mobile view..
                          ResponsiveHelper.isDesktop(context)
                              ? const SliverToBoxAdapter(child: SizedBox())
                              : SliverToBoxAdapter(
                                  child: Center(
                                    child: Container(
                                      width: Dimensions.webMaxWidth,
                                      padding: const EdgeInsets.all(
                                        Dimensions.paddingSizeSmall,
                                      ),
                                      color: Theme.of(context).cardColor,
                                      child: Column(
                                        children: [
                                          ResponsiveHelper.isDesktop(context)
                                              ? const SizedBox()
                                              : StoreDescriptionViewWidget(
                                                  store: store,
                                                ),
                                          const SizedBox(
                                            height: Dimensions.paddingSizeSmall,
                                          ),

                                          store?.announcementActive ?? false
                                              ? Container(
                                                  decoration: BoxDecoration(
                                                    color: Theme.of(context)
                                                        .primaryColor
                                                        .withValues(
                                                          alpha: 0.05,
                                                        ),
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                          Dimensions
                                                              .radiusDefault,
                                                        ),
                                                    border: Border.all(
                                                      color: Theme.of(context)
                                                          .primaryColor
                                                          .withValues(
                                                            alpha: 0.2,
                                                          ),
                                                    ),
                                                  ),
                                                  padding: const EdgeInsets.all(
                                                    Dimensions.paddingSizeSmall,
                                                  ),
                                                  margin: const EdgeInsets.only(
                                                    top: Dimensions
                                                        .paddingSizeSmall,
                                                  ),
                                                  child: Row(
                                                    children: [
                                                      Image.asset(
                                                        Images.announcement,
                                                        height: 20,
                                                        width: 20,
                                                      ),
                                                      const SizedBox(
                                                        width: Dimensions
                                                            .paddingSizeSmall,
                                                      ),

                                                      Flexible(
                                                        child: Text(
                                                          store?.announcementMessage ??
                                                              '',
                                                          style: robotoRegular
                                                              .copyWith(
                                                                fontSize: Dimensions
                                                                    .fontSizeSmall,
                                                              ),
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                )
                                              : const SizedBox(),

                                          StoreBannerWidget(
                                            storeController: storeController,
                                          ),

                                          const SizedBox(
                                            height: Dimensions.paddingSizeLarge,
                                          ),

                                          (!ResponsiveHelper.isDesktop(
                                                    context,
                                                  ) &&
                                                  storeController
                                                          .recommendedItemModel !=
                                                      null &&
                                                  storeController
                                                      .recommendedItemModel!
                                                      .items!
                                                      .isNotEmpty)
                                              ? Column(
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.start,
                                                  children: [
                                                    Text(
                                                      'recommended_for_you'.tr,
                                                      style: robotoMedium,
                                                    ),
                                                    const SizedBox(
                                                      height: Dimensions
                                                          .paddingSizeExtraSmall,
                                                    ),

                                                    SizedBox(
                                                      height:
                                                          ResponsiveHelper.isDesktop(
                                                            context,
                                                          )
                                                          ? 150
                                                          : 130,
                                                      child: ListView.builder(
                                                        scrollDirection:
                                                            Axis.horizontal,
                                                        itemCount: storeController
                                                            .recommendedItemModel!
                                                            .items!
                                                            .length,
                                                        physics:
                                                            const BouncingScrollPhysics(),
                                                        itemBuilder: (context, index) {
                                                          return Padding(
                                                            padding:
                                                                ResponsiveHelper.isDesktop(
                                                                  context,
                                                                )
                                                                ? const EdgeInsets.symmetric(
                                                                    vertical:
                                                                        20,
                                                                  )
                                                                : const EdgeInsets.symmetric(
                                                                    vertical:
                                                                        10,
                                                                  ),
                                                            child: Container(
                                                              width:
                                                                  ResponsiveHelper.isDesktop(
                                                                    context,
                                                                  )
                                                                  ? 500
                                                                  : 300,
                                                              padding: const EdgeInsets.only(
                                                                right: Dimensions
                                                                    .paddingSizeSmall,
                                                                left: Dimensions
                                                                    .paddingSizeExtraSmall,
                                                              ),
                                                              margin: const EdgeInsets.only(
                                                                right: Dimensions
                                                                    .paddingSizeSmall,
                                                              ),
                                                              child: ItemWidget(
                                                                isStore: false,
                                                                item: storeController
                                                                    .recommendedItemModel!
                                                                    .items![index],
                                                                store: null,
                                                                index: index,
                                                                length: null,
                                                                isCampaign:
                                                                    false,
                                                                inStore: true,
                                                              ),
                                                            ),
                                                          );
                                                        },
                                                      ),
                                                    ),
                                                  ],
                                                )
                                              : const SizedBox(),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),

                          ResponsiveHelper.isDesktop(context)
                              ? const SliverToBoxAdapter(child: SizedBox())
                              : (storeController.categoryList!.isNotEmpty)
                              ? SliverPersistentHeader(
                                  pinned: true,
                                  delegate: SliverDelegate(
                                    height: 90,
                                    child: Center(
                                      child: Container(
                                        width: Dimensions.webMaxWidth,
                                        decoration: BoxDecoration(
                                          color: Theme.of(context).cardColor,
                                          boxShadow: const [
                                            BoxShadow(
                                              color: Colors.black12,
                                              blurRadius: 5,
                                              spreadRadius: 1,
                                            ),
                                          ],
                                        ),
                                        padding: const EdgeInsets.symmetric(
                                          vertical:
                                              Dimensions.paddingSizeExtraSmall,
                                        ),
                                        child: Column(
                                          children: [
                                            Padding(
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                    horizontal: Dimensions
                                                        .paddingSizeSmall,
                                                  ),
                                              child: Row(
                                                children: [
                                                  Text(
                                                    'all_products'.tr,
                                                    style: robotoBold.copyWith(
                                                      fontSize: Dimensions
                                                          .fontSizeDefault,
                                                    ),
                                                  ),
                                                  const Expanded(
                                                    child: SizedBox(),
                                                  ),

                                                  !ResponsiveHelper.isDesktop(
                                                        context,
                                                      )
                                                      ? InkWell(
                                                          onTap: () => Get.toNamed(
                                                            RouteHelper.getSearchStoreItemRoute(
                                                              store!.id,
                                                            ),
                                                          ),
                                                          child: Container(
                                                            decoration: BoxDecoration(
                                                              borderRadius:
                                                                  BorderRadius.circular(
                                                                    Dimensions
                                                                        .radiusDefault,
                                                                  ),
                                                              color:
                                                                  Theme.of(
                                                                        context,
                                                                      )
                                                                      .primaryColor
                                                                      .withValues(
                                                                        alpha:
                                                                            0.1,
                                                                      ),
                                                            ),
                                                            padding:
                                                                const EdgeInsets.all(
                                                                  Dimensions
                                                                      .paddingSizeExtraSmall,
                                                                ),
                                                            child: Icon(
                                                              Icons.search,
                                                              size: 28,
                                                              color: Theme.of(
                                                                context,
                                                              ).primaryColor,
                                                            ),
                                                          ),
                                                        )
                                                      : const SizedBox(),
                                                  const SizedBox(
                                                    width: Dimensions
                                                        .paddingSizeSmall,
                                                  ),

                                                  InkWell(
                                                    onTap: () {
                                                      List<double?> prices = [];
                                                      for (var product
                                                          in Get.find<
                                                                StoreController
                                                              >()
                                                              .storeItemModel!
                                                              .items!) {
                                                        prices.add(
                                                          product.price,
                                                        );
                                                      }
                                                      prices.sort();
                                                      double? maxValue =
                                                          prices.isNotEmpty
                                                          ? prices[prices
                                                                    .length -
                                                                1]
                                                          : 1000;
                                                      Get.dialog(
                                                        FilterWidget(
                                                          maxValue: maxValue,
                                                        ),
                                                      );
                                                    },
                                                    child: Container(
                                                      decoration: BoxDecoration(
                                                        borderRadius:
                                                            BorderRadius.circular(
                                                              Dimensions
                                                                  .radiusDefault,
                                                            ),
                                                        color: Theme.of(
                                                          context,
                                                        ).cardColor,
                                                        border: Border.all(
                                                          color: Theme.of(
                                                            context,
                                                          ).primaryColor,
                                                          width: 1,
                                                        ),
                                                      ),
                                                      padding: const EdgeInsets.all(
                                                        Dimensions
                                                            .paddingSizeExtraSmall,
                                                      ),
                                                      child: Icon(
                                                        Icons.filter_list,
                                                        size: 24,
                                                        color: Theme.of(
                                                          context,
                                                        ).primaryColor,
                                                      ),
                                                    ),
                                                  ),

                                                  /*storeController.type.isNotEmpty ? VegFilterWidget(
                                type: storeController.type,
                                onSelected: (String type) {
                                  storeController.getStoreItemList(storeController.store!.id, 1,  true);
                                },
                            ) : const SizedBox(),*/
                                                ],
                                              ),
                                            ),
                                            const SizedBox(
                                              height:
                                                  Dimensions.paddingSizeSmall,
                                            ),

                                            SizedBox(
                                              height: 30,
                                              child: ListView.builder(
                                                scrollDirection:
                                                    Axis.horizontal,
                                                itemCount: storeController
                                                    .categoryList!
                                                    .length,
                                                padding: const EdgeInsets.only(
                                                  left: Dimensions
                                                      .paddingSizeSmall,
                                                ),
                                                physics:
                                                    const BouncingScrollPhysics(),
                                                itemBuilder: (context, index) {
                                                  return InkWell(
                                                    onTap: () => storeController
                                                        .setCategoryIndex(
                                                          index,
                                                        ),
                                                    child: Container(
                                                      padding: const EdgeInsets.symmetric(
                                                        horizontal: Dimensions
                                                            .paddingSizeSmall,
                                                        vertical: Dimensions
                                                            .paddingSizeExtraSmall,
                                                      ),
                                                      margin:
                                                          const EdgeInsets.only(
                                                            right: Dimensions
                                                                .paddingSizeSmall,
                                                          ),
                                                      decoration: BoxDecoration(
                                                        borderRadius:
                                                            BorderRadius.circular(
                                                              Dimensions
                                                                  .radiusDefault,
                                                            ),
                                                        color:
                                                            index ==
                                                                storeController
                                                                    .categoryIndex
                                                            ? Theme.of(context)
                                                                  .primaryColor
                                                                  .withValues(
                                                                    alpha: 0.1,
                                                                  )
                                                            : Colors
                                                                  .transparent,
                                                      ),
                                                      child: Column(
                                                        mainAxisAlignment:
                                                            MainAxisAlignment
                                                                .center,
                                                        children: [
                                                          Text(
                                                            storeController
                                                                .categoryList![index]
                                                                .name!,
                                                            style:
                                                                index ==
                                                                    storeController
                                                                        .categoryIndex
                                                                ? robotoMedium.copyWith(
                                                                    fontSize:
                                                                        Dimensions
                                                                            .fontSizeSmall,
                                                                    color: Theme.of(
                                                                      context,
                                                                    ).primaryColor,
                                                                  )
                                                                : robotoRegular
                                                                      .copyWith(
                                                                        fontSize:
                                                                            Dimensions.fontSizeSmall,
                                                                      ),
                                                          ),
                                                        ],
                                                      ),
                                                    ),
                                                  );
                                                },
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ),
                                )
                              : const SliverToBoxAdapter(child: SizedBox()),

                          ResponsiveHelper.isDesktop(context)
                              ? const SliverToBoxAdapter(child: SizedBox())
                              : SliverToBoxAdapter(
                                  child: Container(
                                    width: Dimensions.webMaxWidth,
                                    decoration: BoxDecoration(
                                      color: Theme.of(
                                        context,
                                      ).colorScheme.surface,
                                    ),
                                    child: PaginatedListView(
                                      scrollController: scrollController,
                                      onPaginate: (int? offset) async =>
                                          await storeController
                                              .getStoreItemList(
                                                widget.store!.id ??
                                                    storeController.store!.id,
                                                offset!,
                                                storeController.type,
                                                false,
                                              ),
                                      totalSize: storeController
                                          .storeItemModel
                                          ?.totalSize,
                                      offset: storeController
                                          .storeItemModel
                                          ?.offset,
                                      itemView: ItemsView(
                                        isStore: false,
                                        stores: null,
                                        items:
                                            (storeController
                                                    .categoryList!
                                                    .isNotEmpty &&
                                                storeController
                                                        .storeItemModel !=
                                                    null)
                                            ? storeController
                                                  .storeItemModel!
                                                  .items
                                            : null,
                                        inStorePage: true,
                                        padding: const EdgeInsets.symmetric(
                                          horizontal:
                                              Dimensions.paddingSizeSmall,
                                          vertical: Dimensions.paddingSizeSmall,
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                        ],
                      )
                    : const StoreDetailsScreenShimmerWidget();
              },
            );
          },
        ),

        floatingActionButton: GetBuilder<StoreController>(
          builder: (storeController) {
            return Visibility(
              visible:
                  storeController.showFavButton &&
                  Get.find<SplashController>()
                      .configModel!
                      .moduleConfig!
                      .module!
                      .orderAttachment! &&
                  (storeController.store != null &&
                      storeController.store!.prescriptionOrder!) &&
                  Get.find<SplashController>()
                      .configModel!
                      .prescriptionStatus! &&
                  AuthHelper.isLoggedIn(),
              child: Container(
                decoration: BoxDecoration(
                  color: Theme.of(context).cardColor,
                  borderRadius: BorderRadius.circular(Dimensions.radiusSmall),
                  boxShadow: [
                    BoxShadow(
                      color: Theme.of(
                        context,
                      ).primaryColor.withValues(alpha: 0.5),
                      blurRadius: 10,
                      offset: const Offset(2, 2),
                    ),
                  ],
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    AnimatedContainer(
                      duration: const Duration(milliseconds: 800),
                      width: storeController.currentState == true
                          ? 0
                          : ResponsiveHelper.isDesktop(context)
                          ? 180
                          : 150,
                      height: 30,
                      curve: Curves.linear,
                      child: Center(
                        child: Text(
                          'prescription_order'.tr,
                          textAlign: TextAlign.center,
                          style: robotoMedium.copyWith(
                            color: Theme.of(context).primaryColor,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ),

                    InkWell(
                      onTap: () {
                        Get.find<CheckoutController>().updateFirstTime();
                        Get.find<CheckoutController>()
                            .updateFirstTimeCodActive();
                        Get.toNamed(
                          RouteHelper.getCheckoutRoute(
                            'prescription',
                            storeId: storeController.store!.id,
                          ),
                          arguments: CheckoutScreen(
                            fromCart: false,
                            cartList: null,
                            storeId: storeController.store!.id,
                          ),
                        );
                      },
                      child: Container(
                        decoration: BoxDecoration(
                          color: Theme.of(context).primaryColor,
                          borderRadius: BorderRadius.circular(
                            Dimensions.radiusSmall,
                          ),
                        ),
                        padding: const EdgeInsets.all(
                          Dimensions.paddingSizeSmall,
                        ),
                        child: Image.asset(
                          Images.prescriptionIcon,
                          height: 25,
                          width: 25,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      );
    }
    return offers;
  }

  String _discountTitle(Store store) {
    final double discount = store.discount?.discount ?? 0;
    if (store.discount?.discountType == 'percent') {return '${discount.toStringAsFixed(discount % 1 == 0 ? 0 : 1)}% OFF';}
    return '${PriceConverter.convertPrice(discount)} OFF';
  }
}

class _AnnouncementPalette {
  const _AnnouncementPalette._();

  static bool _isDark(BuildContext context) => Theme.of(context).brightness == Brightness.dark;

  static Color card(BuildContext context, Color light, {Color? tint}) => _isDark(context)
      ? Color.alphaBlend((tint ?? light).withValues(alpha: 0.20), Theme.of(context).cardColor) : light;

  static Color title(BuildContext context) => _isDark(context)
      ? (Theme.of(context).textTheme.bodyLarge?.color ?? Colors.white) : const Color(0xFF1F2A44);

  static Color body(BuildContext context) => _isDark(context)
      ? Theme.of(context).hintColor : const Color(0xFF777777);
}

class _StoreOfferData {
  final String title;
  final String? subTitle;
  final String message;
  final String imageUrl;
  final Color color;
  final Color? tint;
  final bool isCoupon;
  final CouponModel? coupon;

  const _StoreOfferData({
    required this.title,
    required this.message,
    required this.imageUrl,
    required this.color,
    this.tint,
    this.isCoupon = false,
    this.subTitle,
    this.coupon,
  });
}

class _StoreOfferCard extends StatelessWidget {
  final _StoreOfferData data;

  const _StoreOfferCard({required this.data});

  @override
  Widget build(BuildContext context) {
    final cardContent = Container(
      width: 200,
      padding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeDefault, vertical: Dimensions.paddingSizeSmall,),
      decoration: BoxDecoration(color: _AnnouncementPalette.card(context, data.color, tint: data.tint), borderRadius: data.isCoupon ? null : BorderRadius.circular(12)),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          Container(
            padding: const EdgeInsets.all(Dimensions.paddingSizeExtraSmall),
            child: Row(mainAxisSize: MainAxisSize.min, children: [
              Image.asset(data.imageUrl, height: 14, width: 14),
              const SizedBox(width: 4),
              Text(data.title, maxLines: 1, overflow: TextOverflow.ellipsis,
                style: robotoBold.copyWith(fontSize: Dimensions.fontSizeLarge, color: _AnnouncementPalette.title(context)),
              ),
            ]),
          ),
        ]),
        data.subTitle == null ? const SizedBox.shrink() : Padding(
          padding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeExtraSmall),
          child: Text(data.subTitle ?? '', maxLines: 1, overflow: TextOverflow.ellipsis,
            style: robotoBold.copyWith(fontSize: Dimensions.fontSizeDefault, color: _AnnouncementPalette.title(context)),
          ),
        ),
        data.subTitle == null ? const SizedBox.shrink() : const SizedBox(height: 4),
        Text(
          data.message,
          style: robotoRegular.copyWith(fontSize: Dimensions.fontSizeSmall, color: _AnnouncementPalette.body(context)),
        ),
      ]),
    );

    final Widget card = data.isCoupon
      ? ClipPath(
          clipper: CouponClipper(borderRadius: 16, notchRadius: 12),
          child: cardContent,
        )
      : cardContent;

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () => _showStoreOfferSheet(context, _OfferDetailSheet(
        title: data.title,
        subTitle: data.subTitle,
        message: data.message,
        accentColor: data.color,
        imageAsset: data.imageUrl,
        coupon: data.coupon,
      )),
      child: card,
    );
  }
}

        bottomNavigationBar: GetBuilder<CartController>(
          builder: (cartController) {
            return cartController.cartList.isNotEmpty &&
                    !ResponsiveHelper.isDesktop(context)
                ? const BottomCartWidget()
                : const SizedBox();
          },
        ),
      ),
      child: SafeArea(
        top: false,
        child: Stack(children: [
        ConstrainedBox(
          constraints: BoxConstraints(maxHeight: MediaQuery.of(context).size.height * 0.8),
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(Dimensions.paddingSizeLarge, Dimensions.paddingSizeSmall, Dimensions.paddingSizeLarge, Dimensions.paddingSizeLarge),
            child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, children: [

              Center(child: Container(
                width: 40, height: 4,
                margin: const EdgeInsets.only(bottom: Dimensions.paddingSizeDefault),
                decoration: BoxDecoration(color: Theme.of(context).disabledColor.withValues(alpha: 0.4), borderRadius: BorderRadius.circular(10)),
              )),

              Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Container(
                  height: 48, width: 48, alignment: Alignment.center,
                  decoration: BoxDecoration(color: accentColor, borderRadius: BorderRadius.circular(Dimensions.radiusDefault)),
                  child: isPro
                      ? const Icon(Icons.star_rounded, color: Color(0xFF3B5BDB), size: 26)
                      : (imageAsset != null
                          ? Image.asset(imageAsset!, height: 24, width: 24)
                          : Icon(Icons.local_offer_outlined, color: Theme.of(context).primaryColor, size: 24)),
                ),
                const SizedBox(width: Dimensions.paddingSizeDefault),
                Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text(title, style: robotoBold.copyWith(fontSize: Dimensions.fontSizeExtraLarge, color: textColor)),
                  if (subTitle != null && subTitle!.isNotEmpty) ...[
                    const SizedBox(height: 2),
                    Text(subTitle!, style: robotoMedium.copyWith(fontSize: Dimensions.fontSizeSmall, color: hint)),
                  ],
                ])),
                const SizedBox(width: 30),
              ]),

              const SizedBox(height: Dimensions.paddingSizeDefault),
              Text(message, style: robotoRegular.copyWith(fontSize: Dimensions.fontSizeDefault, color: hint, height: 1.4)),

              if (coupon != null) ...[
                const SizedBox(height: Dimensions.paddingSizeLarge),
                Text('coupon_code'.tr, style: robotoMedium.copyWith(fontSize: Dimensions.fontSizeSmall, color: hint)),
                const SizedBox(height: Dimensions.paddingSizeSmall),
                _CouponCodeBox(code: coupon!.code ?? '', accent: Theme.of(context).primaryColor),
                const SizedBox(height: Dimensions.paddingSizeDefault),
                if ((coupon!.minPurchase ?? 0) > 0) _detailRow(context, 'min_order'.tr, PriceConverter.convertPrice(coupon!.minPurchase)),
                if ((coupon!.maxDiscount ?? 0) > 0) _detailRow(context, 'max_discount'.tr, PriceConverter.convertPrice(coupon!.maxDiscount)),
                if ((coupon!.expireDate ?? '').isNotEmpty) _detailRow(context, 'valid_till'.tr, coupon!.expireDate!.split(' ').first),
              ],
            ]),
          ),
        ),

        Positioned(
          top: Dimensions.paddingSizeDefault,
          right: Dimensions.paddingSizeDefault,
          child: InkWell(
            onTap: () => Get.back(),
            borderRadius: BorderRadius.circular(50),
            child: Container(
              padding: const EdgeInsets.all(Dimensions.paddingSizeExtraSmall),
              decoration: BoxDecoration(color: Theme.of(context).disabledColor.withValues(alpha: 0.12), shape: BoxShape.circle),
              child: Icon(Icons.close, size: 18, color: hint),
            ),
          ),
        ),
      ]),
      ),
    );
  }

  Widget _detailRow(BuildContext context, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: Row(children: [
        Text(label, style: robotoRegular.copyWith(fontSize: Dimensions.fontSizeSmall, color: Theme.of(context).hintColor)),
        const Spacer(),
        Text(value, style: robotoMedium.copyWith(fontSize: Dimensions.fontSizeSmall, color: Theme.of(context).textTheme.bodyLarge!.color)),
      ]),
    );
  }
}

class _CouponCodeBox extends StatelessWidget {
  final String code;
  final Color accent;

  const _CouponCodeBox({required this.code, required this.accent});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeDefault, vertical: Dimensions.paddingSizeDefault),
      decoration: BoxDecoration(
        color: accent.withValues(alpha: 0.06),
        borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
        border: Border.all(color: accent.withValues(alpha: 0.5)),
      ),
      child: Row(children: [
        Expanded(
          child: Text(code, maxLines: 1, overflow: TextOverflow.ellipsis,
            style: robotoBold.copyWith(fontSize: Dimensions.fontSizeLarge, letterSpacing: 1.5, color: Theme.of(context).textTheme.bodyLarge!.color),
          ),
        ),
        const SizedBox(width: Dimensions.paddingSizeSmall),
        InkWell(
          onTap: () {
            if (code.isEmpty) return;
            Clipboard.setData(ClipboardData(text: code));
            showCustomSnackBar('coupon_code_copied'.tr, isError: false);
          },
          borderRadius: BorderRadius.circular(Dimensions.radiusSmall),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeSmall, vertical: 4),
            child: Row(mainAxisSize: MainAxisSize.min, children: [
              Icon(Icons.copy_rounded, size: 16, color: accent),
              const SizedBox(width: 4),
              Text('copy'.tr.toUpperCase(), style: robotoBold.copyWith(fontSize: Dimensions.fontSizeSmall, color: accent)),
            ]),
          ),
        ),
      ]),
    );
  }
}

class _StoreCategoryTabs extends StatefulWidget {
  final StoreController storeController;
  final ValueNotifier<int> activeIndexNotifier;
  final void Function(int index) onTabTap;
  final bool hasBundles;

  const _StoreCategoryTabs({super.key,
    required this.storeController, required this.activeIndexNotifier, required this.onTabTap, required this.hasBundles,
  });

  @override
  State<_StoreCategoryTabs> createState() => _StoreCategoryTabsState();
}

class _StoreCategoryTabsState extends State<_StoreCategoryTabs> {
  final ScrollController _tabScrollController = ScrollController();
  final Map<int, GlobalKey> _tabKeys = {};
  final GlobalKey _containerKey = GlobalKey();

  GlobalKey _getTabKey(int index) => _tabKeys.putIfAbsent(index, () => GlobalKey());

  @override
  void initState() {
    super.initState();
    widget.activeIndexNotifier.addListener(_onActiveIndexChanged);
  }

  @override
  void didUpdateWidget(_StoreCategoryTabs oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.activeIndexNotifier != widget.activeIndexNotifier) {
      oldWidget.activeIndexNotifier.removeListener(_onActiveIndexChanged);
      widget.activeIndexNotifier.addListener(_onActiveIndexChanged);
    }
  }

  @override
  void dispose() {
    widget.activeIndexNotifier.removeListener(_onActiveIndexChanged);
    _tabScrollController.dispose();
    super.dispose();
  }

  void _onActiveIndexChanged() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) _scrollToActiveTab(widget.activeIndexNotifier.value);
    });
  }

  void _scrollToActiveTab(int index) {
    if (!_tabScrollController.hasClients) return;
    final key = _tabKeys[index];
    if (key?.currentContext == null) return;

    final RenderBox? tabBox = key!.currentContext!.findRenderObject() as RenderBox?;
    final RenderBox? containerBox = _containerKey.currentContext?.findRenderObject() as RenderBox?;
    if (tabBox == null || containerBox == null || !tabBox.attached || !containerBox.attached) return;

    final double tabScreenLeft = tabBox.localToGlobal(Offset.zero).dx;
    final double containerScreenLeft = containerBox.localToGlobal(Offset.zero).dx;
    final double tabWidth = tabBox.size.width;
    final double currentOffset = _tabScrollController.offset;
    final double viewportWidth = _tabScrollController.position.viewportDimension;

    final double tabContentLeft = currentOffset + (tabScreenLeft - containerScreenLeft);
    final double targetOffset = (tabContentLeft + tabWidth / 2 - viewportWidth / 2)
        .clamp(0.0, _tabScrollController.position.maxScrollExtent);

    _tabScrollController.animateTo(targetOffset,
        duration: const Duration(milliseconds: 250), curve: Curves.easeOut);
  }

  @override
  Widget build(BuildContext context) {
    final StoreController storeController = widget.storeController;
    final bool hasMostPopular = storeController.recommendedItemModel?.items?.isNotEmpty == true;
    final List<StoreItemCategory> cats = storeController.storeCategoryItemsModel?.categories ?? [];

    final List<int> visibleTabs = <int>[
      if (hasMostPopular) 0,
      if (widget.hasBundles) 1,
      for (int ci = 0; ci < cats.length; ci++) ci + 2,
    ];
    final int tabCount = visibleTabs.length;

    return ValueListenableBuilder<int>(
      valueListenable: widget.activeIndexNotifier,
      builder: (context, activeIndex, _) => Center(
        child: Container(
          key: _containerKey,
          width: Dimensions.webMaxWidth,
          height: 44,
          decoration: BoxDecoration(
            color: Theme.of(context).cardColor,
            boxShadow: const [BoxShadow(color: Color(0x12000000), blurRadius: 8, offset: Offset(0, 2))],
          ),
          child: tabCount == 0 ? const SizedBox() : ListView.builder(
            controller: _tabScrollController,
            scrollDirection: Axis.horizontal,
            physics: const BouncingScrollPhysics(),
            itemCount: tabCount,
            padding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeDefault),
            itemBuilder: (context, i) {
              final int index = visibleTabs[i];
              final bool selected = index == activeIndex;
              final String label = index == 0 ? 'most_popular'.tr : index == 1 ? 'bundle_offer'.tr : (cats[index - 2].name ?? '');
              return InkWell(
                key: _getTabKey(index),
                onTap: () => widget.onTabTap(index),
                child: Container(height: 52,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(border: Border(bottom: BorderSide(width: 3,
                    color: selected ? Theme.of(context).primaryColor : Colors.transparent))),
                  child: Text('  $label  ', maxLines: 1, overflow: TextOverflow.ellipsis,
                    style: (selected ? robotoBold : robotoBold).copyWith(fontSize: Dimensions.fontSizeDefault,
                      color: selected ? Theme.of(context).primaryColor : Theme.of(context).textTheme.bodyLarge!.color!.withValues(alpha: 0.5),
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}
class _MostPopularItemsSection extends StatelessWidget {
  final Store store;
  final StoreController storeController;

  const _MostPopularItemsSection({required this.store, required this.storeController});

  @override
  Widget build(BuildContext context) {
    final List<Item>? items = storeController.recommendedItemModel?.items;
    if (storeController.isSearching || items == null || items.isEmpty) {
      return const SizedBox.shrink();
    }

    return Container(width: double.infinity, color: Theme.of(context).cardColor,
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          const SizedBox(height: 26),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeDefault),
            child: Text('most_popular'.tr,
              style: robotoBold.copyWith(fontSize: Dimensions.fontSizeLarge),
            ),
          ),
          const SizedBox(height: 14),
          GetBuilder<FavouriteController>(
            builder: (favouriteController) {
              return SizedBox(
                height: 310,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  primary: false,
                  padding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeDefault),
                  itemCount: items.length,
                  separatorBuilder: (BuildContext context, int index) => Gaps.horizontalGapOf(Dimensions.paddingSizeSmall),
                  itemBuilder: (BuildContext context, int index) => FoodItemCard(data: items[index], width: 158, index: index),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}

sealed class _StoreRow {
  const _StoreRow();
}

class _HeaderRow extends _StoreRow {
  final int catIndex;
  final String name;
  const _HeaderRow({required this.catIndex, required this.name});
}

class _ItemRow extends _StoreRow {
  final StoreCardItem item;
  final int indexInCat;
  final bool isFirst;
  const _ItemRow({required this.item, required this.indexInCat, required this.isFirst});
}

class _StoreCompactItemCard extends StatelessWidget {
  final StoreCardItem data;
  final Store store;
  final int index;

  const _StoreCompactItemCard({required this.data, required this.store, required this.index});

  @override
  Widget build(BuildContext context) {
    final Item item = data.toItem();
    final double discount = item.discount ?? 0;
    final bool hasDiscount = discount > 0;
    final bool hasFreeDelivery = store.delivery == true && store.freeDelivery == true;
    final bool isAvailable = DateConverter.isAvailable(item.availableTimeStarts, item.availableTimeEnds);

    return InkWell(
      onTap: () => Get.find<ItemController>().navigateToItemPage(item, context, inStore: true, isCampaign: false, ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeDefault, vertical: Dimensions.paddingSizeDefault),
        child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(right: Dimensions.paddingSizeDefault),
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text(
                  item.name ?? '', maxLines: 2, overflow: TextOverflow.ellipsis,
                  style: robotoRegular.copyWith(fontSize: Dimensions.fontSizeDefault),
                ),
                const SizedBox(height: 7),
                AvgReviewWidget(avgRating: item.avgRating ?? 0, ratingCount: item.ratingCount ?? 0),
                if (AvgReviewWidget.showRating(item.avgRating ?? 0)) const SizedBox(height: 9),
                Row(children: [
                  Text(
                    PriceConverter.convertPrice(item.price, discount: item.discount, discountType: item.discountType),
                    textDirection: TextDirection.ltr,
                    style: robotoBold.copyWith(fontSize: Dimensions.fontSizeDefault),
                  ),
                  if (hasDiscount) ...[
                    const SizedBox(width: 6),
                    Flexible(child: Text(
                      PriceConverter.convertPrice(item.price),
                      textDirection: TextDirection.ltr,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: robotoRegular.copyWith(fontSize: Dimensions.fontSizeSmall, color: Theme.of(context).disabledColor, decoration: TextDecoration.lineThrough),
                    )),
                  ],
                ]),
                const SizedBox(height: 12),
                Wrap(spacing: 7, runSpacing: 7, children: [
                  if (hasDiscount)_SmallDealBadge(text: _discountBadgeText(item), textDirection: TextDirection.ltr),
                  if (hasFreeDelivery) _SmallDealBadge(text: 'free'.tr, icon: Icons.pedal_bike_outlined, soft: true),
                ]),
              ]),
            ),
          ),
          SizedBox(width: 132, height: 132,
            child: ClipRRect(borderRadius: BorderRadius.circular(12),
              child: Stack(children: [
                Positioned.fill(
                  child: CustomImage(image: item.imageFullUrl ?? '', fit: BoxFit.cover, placeholder: Images.placeholder,
                    cacheWidth: ImageCacheHelper.pixels(context, 132),
                  ),
                ),
                Positioned(top: 8, left: 8,
                  child: Row(children: [
                    if (item.isStoreHalalActive == true && item.isHalalItem == true)
                      const _ImageRoundBadge(assetPath: Images.halalTag),

                    if (item.isStoreHalalActive == true && item.isHalalItem == true && item.veg == 1) const SizedBox(width: 5),
                    if (item.veg == 1)const _ImageRoundBadge(assetPath: Images.vegTag),
                  ]),
                ),
                Positioned(top: 8, right: 8,
                  child: GetBuilder<FavouriteController>(
                    builder: (favouriteController) {
                      final bool isWished = favouriteController.wishItemIdList.contains(item.id);
                      return _CardCircleButton(
                        size: 28,
                        child: CustomFavouriteWidget(item: item, isWished: isWished, size: 21),
                      );
                    },
                  ),
                ),
                if(isAvailable) Positioned(right: 7, bottom: 7,
                  child: CartCountView(item: item, index: index, child: const _AddSquareButton(size: 36)),
                ),

                if (!isAvailable) const NotAvailableWidget(isStore: false, radius: 12),
              ]),
            ),
          ),
        ]),
      ),
    );
  }

  String _discountBadgeText(Item item) {
    final double discount = item.discount ?? 0;
    if (item.discountType == 'percent') {return '-${discount.toStringAsFixed(discount % 1 == 0 ? 0 : 1)}%';}
    return '-${PriceConverter.convertPrice(discount)}';
  }
}

class _StoreItemsLoadingList extends StatelessWidget {
  const _StoreItemsLoadingList();

  @override
  Widget build(BuildContext context) {
    return Container(color: Theme.of(context).cardColor,
      child: Column(children: List.generate(4, (index) {
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeDefault, vertical: Dimensions.paddingSizeDefault),
            child: Row(children: [
              const Expanded(
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  _LoadingBar(width: double.infinity),
                  SizedBox(height: 10),
                  _LoadingBar(width: 150),
                  SizedBox(height: 10),
                  _LoadingBar(width: 92),
                ]),
              ),
              const SizedBox(width: Dimensions.paddingSizeDefault),
              Container(height: 112, width: 112,
                decoration: BoxDecoration(color: const Color(0xFFE9E9E9), borderRadius: BorderRadius.circular(12)),
              ),
            ]),
          );
        }),
      ),
    );
  }
}

class _LoadingBar extends StatelessWidget {
  final double width;

  const _LoadingBar({required this.width});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 12, width: width,
      decoration: BoxDecoration(color: const Color(0xFFE9E9E9), borderRadius: BorderRadius.circular(99)),
    );
  }
}

class _StoreCoverImage extends StatelessWidget {
  final String? url;

  final double height;

  const _StoreCoverImage({required this.url, required this.height});

  @override
  Widget build(BuildContext context) {
    final String source = url?.trim() ?? '';

    if (source.isEmpty) {
      return _placeholder();
    }

    return Image.network(
      source,
      fit: BoxFit.cover,
      errorBuilder: (BuildContext context, Object error, StackTrace? stackTrace) => _placeholder(),
      loadingBuilder: (BuildContext context, Widget child, ImageChunkEvent? progress) =>
          progress == null ? child : _placeholder(),
    );
  }

  Widget _placeholder() => Image.asset(Images.placeholder, fit: BoxFit.cover);
}

class _StoreCircleIconButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;

  const _StoreCircleIconButton({required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Material(
      color:  Theme.of(context).cardColor, shape: const CircleBorder(), elevation: 2,
      shadowColor: const Color(0x22000000),
      child: Padding(
        padding: const EdgeInsets.all(4.0),
        child: InkWell(
          customBorder: const CircleBorder(), onTap: onTap,
          child: Icon(icon, size: 24),
        ),
      ),
    );
  }
}

class _StoreSoftIconButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;

  const _StoreSoftIconButton({required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Theme.of(context).disabledColor.withValues(alpha: 0.2),
      borderRadius: BorderRadius.circular(50),
      child: Padding(
        padding: const EdgeInsets.all(4.0),
        child: InkWell(
          borderRadius: BorderRadius.circular(50),
          onTap: onTap,
          child: Icon(icon, size: 24),
        ),
      ),
    );
  }
}

class _StoreFavouriteCircleButton extends StatelessWidget {
  final Store store;

  const _StoreFavouriteCircleButton({required this.store});

  @override
  Widget build(BuildContext context) {
    return GetBuilder<FavouriteController>(
      builder: (favouriteController) {
        final bool isWished = favouriteController.wishStoreIdList.contains(store.id);
        return _StoreCircleIconButton(
          icon: isWished ? Icons.favorite : Icons.favorite_border,
          onTap: () {
            if (AuthHelper.isLoggedIn()) {
              isWished ? favouriteController.removeFromFavouriteList(store.id, true) : favouriteController.addToFavouriteList(null, store.id, true);
            } else {
              showCustomSnackBar('you_are_not_logged_in'.tr);
            }
          },
        );
      },
    );
  }
}

class _VerifiedChip extends StatelessWidget {
  const _VerifiedChip();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
      decoration: BoxDecoration(
        color: const Color(0xFF4285F4), borderRadius: BorderRadius.circular(Dimensions.radiusExtraLarge),
      ),
      child: Row(mainAxisSize: MainAxisSize.min, children: [
        const Icon(Icons.verified, color: Colors.white, size: 16),
        const SizedBox(width: 4),
        Text(
          'Verified',
          style: robotoBold.copyWith(fontSize: Dimensions.fontSizeSmall, color: Colors.white),
        ),
      ]),
    );
  }
}

class _CardCircleButton extends StatelessWidget {
  final Widget child;
  final double size;

  const _CardCircleButton({required this.child, required this.size});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size, height: size,
      alignment: Alignment.center,
      padding: const EdgeInsets.only(top: 3),
      decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle,
        boxShadow: [BoxShadow(color: Color(0x1A000000), blurRadius: 6, offset: Offset(0, 2))],
      ),
      child: child,
    );
  }
}

class _AddSquareButton extends StatelessWidget {
  final double size;

  const _AddSquareButton({required this.size});

  @override
  Widget build(BuildContext context) {
    return Container(width: size, height: size,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: const [BoxShadow(color: Color(0x26000000), blurRadius: 10, offset: Offset(0, 3))],
      ),
      child: const Icon(Icons.add, size: 24, color: Color(0xFF111111)),
    );
  }
}

class _SmallDealBadge extends StatelessWidget {
  final String text;
  final IconData? icon;
  final bool soft;
  final TextDirection? textDirection;

  const _SmallDealBadge({required this.text, this.icon, this.soft = false, this.textDirection});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: soft ? const Color(0xFFFFE8E8) : const Color(0xFFFF2020),
        borderRadius: BorderRadius.circular(99),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(icon, size: 13, color: const Color(0xFFFF2020)),
            const SizedBox(width: 3),
          ],
          Text(
            text,
            textDirection: textDirection,
            style: robotoMedium.copyWith(
              fontSize: Dimensions.fontSizeExtraSmall,
              color: soft ? const Color(0xFFFF2020) : Colors.white,
            ),
          ),
        ],
      ),
    );
  }
}

class _ImageRoundBadge extends StatelessWidget {
  final String assetPath;

  const _ImageRoundBadge({required this.assetPath});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 26, width: 26,
      padding: const EdgeInsets.all(3),
      decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle),
      child: CustomAssetImageWidget(assetPath),
    );
  }
}

class SliverDelegate extends SliverPersistentHeaderDelegate {
  Widget child;
  double height;

  SliverDelegate({required this.child, this.height = 100});

  @override
  Widget build(
    BuildContext context,
    double shrinkOffset,
    bool overlapsContent,
  ) {
    return child;
  }

  @override
  double get maxExtent => height;

  @override
  double get minExtent => height;

  @override
  bool shouldRebuild(SliverDelegate oldDelegate) {
    return oldDelegate.maxExtent != height ||
        oldDelegate.minExtent != height ||
        child != oldDelegate.child;
  }
}

class CategoryProduct {
  CategoryModel category;
  List<Item> products;
  CategoryProduct(this.category, this.products);
}
