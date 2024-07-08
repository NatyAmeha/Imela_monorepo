import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:melegna_customer/domain/shared/gallery.model.dart';
import 'package:melegna_customer/presentation/resources/values.dart';
import 'package:melegna_customer/presentation/ui/factory/widget.factory.dart';
import 'package:melegna_customer/presentation/ui/product/components/product_call_to_action_bottom.component.dart';
import 'package:melegna_customer/presentation/ui/product/components/product_features_list.dart';
import 'package:melegna_customer/presentation/ui/product/components/product_option_item.dart';
import 'package:melegna_customer/presentation/ui/product/product_details/product_details.viewmodel.dart';
import 'package:melegna_customer/presentation/ui/shared/app_image.dart';
import 'package:melegna_customer/presentation/ui/shared/list/gridview.component.dart';

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
            title: widget.viewmodel.isAppbarExpanded.value ? null :  Text(widget.viewmodel.getProductName),
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
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  widget.widgetFactory.createText(context, widget.viewmodel.getProductName, style: Theme.of(context).textTheme.headlineMedium),
                  const SizedBox(height: 8),
                  widget.widgetFactory.createText(context, widget.viewmodel.getProductDescription, maxLines: 4, style: Theme.of(context).textTheme.bodyLarge),
                  const SizedBox(height: 16),
                  ProductFeaturesListComponent(widgetFactory: widget.widgetFactory, features: widget.viewmodel.getProductFeatures()),
                  if (widget.viewmodel.productOptions.isNotEmpty) ...[
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
                        return ProductOptionItemComponent(productOption: productOption, isOptionSelected: widget.viewmodel.isProductOptionSelected(productOption) , widgetFactory: widget.widgetFactory);
                      },
                    )
                  ]
                ],
              ),
            ),
          ),
          Positioned(
            child: Align(
              alignment: Alignment.bottomCenter,
              child: ProductCallToActionBottomComponenet(
                product: widget.viewmodel.productInfo!,
                widgetFactory: widget.widgetFactory,
                onPressed: () async {
                  widget.viewmodel.handleJourney(context, widget.widgetFactory);
                },
              ),
            ),
          )
        ],
      ),
    );
  }
}
