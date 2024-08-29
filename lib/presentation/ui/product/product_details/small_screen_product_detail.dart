import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:imela/domain/shared/gallery.model.dart';
import 'package:imela/domain/shared/localized_field.model.dart';
import 'package:imela/presentation/resources/values.dart';
import 'package:imela/presentation/ui/factory/widget.factory.dart';
import 'package:imela/presentation/ui/product/components/product_call_to_action_bottom.component.dart';
import 'package:imela/presentation/ui/product/components/product_features_list.dart';
import 'package:imela/presentation/ui/product/components/product_option_item.dart';
import 'package:imela/presentation/ui/product/product_details/product_details.viewmodel.dart';
import 'package:imela/presentation/ui/shared/app_image.dart';
import 'package:imela/presentation/ui/shared/list/gridview.component.dart';
import 'package:imela/presentation/utils/widget_extesions.dart';

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
            title: Text(widget.viewmodel.selectedProduct.name.localize()).showIfTrue(widget.viewmodel.isAppbarExpanded.value),
            automaticallyImplyLeading: false,
            leading: widget.widgetFactory.createIcon(
                materialIcon: Icons.arrow_back_ios,
                onPressed: () {
                  widget.viewmodel.handleBackPress(context, widget.viewmodel.router);
                }),
            actions: const [],
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
                  return AppImage(imageUrl: widget.viewmodel.getProductImage[index]);
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
                    ProductFeaturesListComponent(widgetFactory: widget.widgetFactory, features: widget.viewmodel.getProductFeatures()),
                    widget.widgetFactory.createText(context, 'Minimum order: ${widget.viewmodel.selectedProduct.minimumOrderQty}', style: Theme.of(context).textTheme.labelMedium),
                                        widget.widgetFactory.createText(context, 'Remaining items: ${widget.viewmodel.productDetails.value?.product?.remainingAmount}', style: Theme.of(context).textTheme.labelMedium),

                    Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 24),
                        widget.widgetFactory.createText(context, 'Available options', style: Theme.of(context).textTheme.titleMedium),
                        const SizedBox(height: 16),
                        AppGridView(
                          controller: widget.viewmodel.productOptionListController,
                          height: 160,
                          itemExtent: 250,
                          scrollDirection: Axis.horizontal,
                          crossAxisCount: 2,
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
                    ).showIfTrue(widget.viewmodel.productOptions.isNotEmpty),
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
                children: [
                  Obx(
                    () => ProductCallToActionBottomComponenet(
                      product: widget.viewmodel.selectedProduct,
                      widgetFactory: widget.widgetFactory,
                      enableCallToActionBtn: widget.viewmodel.isOptionSelected,
                      onPressed: ()  {
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
