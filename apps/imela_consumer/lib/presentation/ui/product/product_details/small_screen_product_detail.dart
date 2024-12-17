import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:get/get.dart';
import 'package:imela/presentation/resources/values.dart';
import 'package:imela/presentation/ui/product/components/pricing/dynamic_pricing_summary.dart';
import 'package:imela/presentation/ui/product/components/product_call_to_action_bottom.component.dart';
import 'package:imela/presentation/ui/product/components/product_features_list.dart';
import 'package:imela/presentation/ui/product/components/product_membership_perk.dart';
import 'package:imela/presentation/ui/product/components/product_option_item.dart';
import 'package:imela/presentation/ui/product/product_details/product_details.viewmodel.dart';
import 'package:imela/presentation/ui/shared/app_image.dart';
import 'package:imela/presentation/ui/shared/list/gridview.component.dart';
import 'package:imela_core/shared/gallery.model.dart';
import 'package:imela_core/shared/localized_field.model.dart';
import 'package:imela_ui_kit/helpers/widget_extesions.dart';
import 'package:imela_ui_kit/widget_factory/widget.factory.dart';
import 'package:imela_utils/helpers/screen_size_utils.dart';

class SmallScreenProductDetail extends StatefulWidget {
  final WidgetFactory widgetFactory;
  final ProductDetailsViewmodel viewmodel;

  const SmallScreenProductDetail({super.key, required this.widgetFactory, required this.viewmodel});

  @override
  State<SmallScreenProductDetail> createState() => _SmallScreenProductDetailState();
}

class _SmallScreenProductDetailState extends State<SmallScreenProductDetail> {
  @override
  void initState() {
    super.initState();
    widget.viewmodel.listenAppbarHeaderScroll();
  }

  @override
  Widget build(BuildContext context) {
    return NestedScrollView(
      controller: widget.viewmodel.productHeaderScrollController,
      headerSliverBuilder: (context, innerBoxIsScrolled) => [
        Obx(
          () => SliverAppBar(
            expandedHeight: NumberResources.EXPANDED_APPBAR_HEIGHT,
            collapsedHeight: NumberResources.COLLAPSED_APPBAR_HEIGHT,
            pinned: true,
            title: Text(widget.viewmodel.selectedProduct.name.localize('ENGLISH')).showIfTrue(widget.viewmodel.isAppbarExpanded.value),
            automaticallyImplyLeading: false,
            leading: widget.widgetFactory.createIcon(
                materialIcon: Icons.arrow_back_ios,
                onPressed: () {
                  widget.viewmodel.handleBackPress(context, widget.viewmodel.router);
                }),
            actions: [
              widget.widgetFactory.createIcon(
                materialIcon: Icons.shopping_cart,
                onPressed: () {
                  widget.viewmodel.navigateToCartDetailsPage(context);
                },
              )
            ],
            toolbarHeight: NumberResources.COLLAPSED_APPBAR_HEIGHT,
            flexibleSpace: FlexibleSpaceBar(
              centerTitle: true,
              background: widget.widgetFactory.createPageView(
                context,
                itemCount: widget.viewmodel.productDetails.value!.product?.gallery?.getImages().length ?? 0,
                controller: PageController(),
                width: double.infinity,
                height: NumberResources.EXPANDED_APPBAR_HEIGHT,
                itemBuilder: (context, index) {
                  return InkWell(
                    onTap: () {
                      widget.viewmodel.navigateToPhotoViewerPage(context, widget.viewmodel.productDetails.value!.product?.gallery?.getImages() ?? [], index);
                    },
                    child: AppImage(imageUrl: widget.viewmodel.getProductImage[index]),
                  );
                },
              ),
            ),
          ),
        ),
      ],
      body: Stack(
        children: [
          Positioned.fill(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Obx(
                () => Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    widget.widgetFactory.createText(context, widget.viewmodel.productName, style: Theme.of(context).textTheme.headlineMedium),
                    const SizedBox(height: 8),
                    widget.widgetFactory.createText(context, widget.viewmodel.getProductDescription, maxLines: 4, style: Theme.of(context).textTheme.bodyLarge),
                    const SizedBox(height: 16),
                    if (widget.viewmodel.originalProductInfo?.haveDynamicPricing == true) ...[
                      ProductDynamicPriceSummary(product: widget.viewmodel.originalProductInfo!, widgetFactory: widget.widgetFactory, selectedCurrency: widget.viewmodel.selectedCurrency, additionalDiscounts: widget.viewmodel.discounts),
                      const SizedBox(height: 16),
                    ],
                    ProductFeaturesListComponent(
                      widgetFactory: widget.widgetFactory,
                      features: widget.viewmodel.getProductFeatures(),
                      onTap: (selectedFEature) {
                        widget.viewmodel.showFeatureDescriptionModal(context, selectedFEature);
                      },
                    ),
                    // widget.widgetFactory.createText(context, 'Minimum order: ${widget.viewmodel.selectedProduct.minimumOrderQty}', style: Theme.of(context).textTheme.labelMedium),
                    // widget.widgetFactory.createText(context, 'Remaining items: ${widget.viewmodel.productDetails.value?.product?.remainingAmount}', style: Theme.of(context).textTheme.labelMedium),
                    if (widget.viewmodel.productOptions.isNotEmpty)
                      Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const SizedBox(height: 24),
                          widget.widgetFactory.createText(context, 'Choose option', style: Theme.of(context).textTheme.titleMedium),
                          const SizedBox(height: 16),
                          AppGridView(
                            controller: widget.viewmodel.productOptionListController,
                            shrinkWrap: true,
                            primary: false,
                            itemExtent: 90,
                            scrollDirection: Axis.vertical,
                            crossAxisCount: Responsive.getGridCount(context, itemWidth: 200),
                            itemBuilder: (context, productOption, index) {
                              return Obx(
                                () => ProductOptionItemComponent(
                                  productOption: productOption,
                                  isOptionSelected: widget.viewmodel.isProductOptionSelected(productOption),
                                  widgetFactory: widget.widgetFactory,
                                  onOptionSelected: () {
                                    widget.viewmodel.selectProductOption(productOption);
                                  },
                                ),
                              );
                            },
                          ),
                        ],
                      ),
                    if (widget.viewmodel.originalProductInfo?.isMembershipProduct == true) ...[
                      const SizedBox(height: 16),
                      ProductMembershipPerk(
                        widgetFactory: widget.widgetFactory,
                        product: widget.viewmodel.originalProductInfo!,
                        selectedLanguage: widget.viewmodel.selectedLanguage,
                        onBecomeMemberPressed: () {
                          widget.viewmodel.handleMembership(context);
                        },
                      )
                    ]
                  ],
                ),
              ),
            ),
          ),
          Positioned(
            child: Align(
              alignment: Alignment.bottomCenter,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Obx(() => const LinearProgressIndicator().showIfTrue(widget.viewmodel.isSecondaryLoading.value)),
                  Obx(
                    () => ProductCallToActionBottomComponenet(
                      product: widget.viewmodel.selectedProduct,
                      widgetFactory: widget.widgetFactory,
                      enableCallToActionBtn: widget.viewmodel.canEnableOrder,
                      discounts: widget.viewmodel.discounts,
                      unit: widget.viewmodel.selectedProductUnit,
                      callToActionText: widget.viewmodel.originalProductInfo?.getCallToAction(),
                      isMembershipProduct: widget.viewmodel.originalProductInfo?.isMembershipProduct ?? false,
                      onPressed: () {
                        widget.viewmodel.handleJourney(context, widget.widgetFactory);
                      },
                    ),
                  ),
                ],
              ),
            ),
          )
        ],
      ),
    );
  }
}
