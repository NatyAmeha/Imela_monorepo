import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:melegna_customer/domain/product/model/product.model.dart';
import 'package:melegna_customer/domain/shared/list_header.component.dart';
import 'package:melegna_customer/domain/shared/localized_field.model.dart';
import 'package:melegna_customer/presentation/resources/colors.dart';
import 'package:melegna_customer/presentation/ui/business/business_details.viewmodel.dart';
import 'package:melegna_customer/presentation/ui/business/component/business_details_header.componenet.dart';
import 'package:melegna_customer/presentation/ui/business/component/business_quick_action.component.dart';
import 'package:melegna_customer/presentation/ui/factory/widget.factory.dart';
import 'package:melegna_customer/presentation/ui/product/components/grid_product_list_item.component.dart';
import 'package:melegna_customer/presentation/ui/shared/app_tabview.dart';
import 'package:melegna_customer/presentation/ui/shared/list/gridview.component.dart';
import 'package:melegna_customer/presentation/utils/localization_utils.dart';

class BusinessDetailsSmallScreen extends StatefulWidget {
  final BusinessDetailsViewModel businessDetailsViewmodel;
  final String? businessName;
  const BusinessDetailsSmallScreen({super.key, required this.businessDetailsViewmodel, this.businessName});

  @override
  State<BusinessDetailsSmallScreen> createState() => _BusinessDetailsSmallScreenState();
}

class _BusinessDetailsSmallScreenState extends State<BusinessDetailsSmallScreen> with SingleTickerProviderStateMixin {
  late TabController controller;
  late WidgetFactory appWidgetFactory;
  @override
  void initState() {
    super.initState();
    widget.businessDetailsViewmodel.assignTabController(widget.businessDetailsViewmodel.sectionsWithProductsControllers.keys.length, this);
    widget.businessDetailsViewmodel.listenAppbarHeaderScroll();
  }

  @override
  Widget build(BuildContext context) {
    appWidgetFactory = WidgetFactory(Theme.of(context).platform);
    return NestedScrollView(
      controller: widget.businessDetailsViewmodel.businessHeaderScrollController,
      headerSliverBuilder: (context, innerBoxIsScrolled) => [
        Obx(
          () => SliverAppBar(
            expandedHeight: 225,
            collapsedHeight: 60,
            pinned: true,
            title: widget.businessDetailsViewmodel.isAppbarExpanded.value ? null : Text('${widget.businessDetailsViewmodel.businessData?.getLocalizedBusinessName(AppLanguage.ENGLISH.name)}'),
            floating: false,
            backgroundColor: ColorManager.alternate,
            automaticallyImplyLeading: false,
            leading: appWidgetFactory.createIcon(
              materialIcon: Icons.arrow_back_ios,
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            actions: const [],
            toolbarHeight: 60,
            flexibleSpace: FlexibleSpaceBar(
              centerTitle: true,
              expandedTitleScale: 1.0,
              background: BusinessDetailsHeader(
                business: widget.businessDetailsViewmodel.businessData!,
                width: double.infinity,
                height: 150,
                controller: PageController(initialPage: 0),
              ),
            ),
            bottom: widget.businessDetailsViewmodel.isAppbarExpanded.value ? null : TabBar(controller: widget.businessDetailsViewmodel.businessSectionTabControllers, tabs: widget.businessDetailsViewmodel.getBusinessSectionTabs()),
          ),
        ),
      ],
      body: AppTabView(
        tabs: widget.businessDetailsViewmodel.getBusinessSectionTabs(),
        controller: widget.businessDetailsViewmodel.businessSectionTabControllers,
        tabViews: widget.businessDetailsViewmodel.sectionsWithProductsControllers.entries.map((entry) {
          if (entry.key == 'Overview') {
            return buildBusinessOverview(appWidgetFactory);
          }
          return SingleChildScrollView(
            primary: true,
            child: AppGridView(
              items: entry.value.items,
              crossAxisCount: 2,
              shrinkWrap: true,
              isStaggered: true,
              crossAxisSpacing: 8,
              mainAxisSpacing: 16,
              primary: false,
             
              itemBuilder: (context, productData, index) {
                return GridProductListItem(
                  product: productData,
                  imageHeight: 150,
                  imageWidth: double.infinity,
                  widgetFactory: appWidgetFactory,
                  onTap: () {
                    widget.businessDetailsViewmodel.navigateToProductDetails(context, productData);
                  },
                );
              },
            ),
          );
        }).toList(),
      ),
    );
  }

  @override
  void dispose() {
    if (kDebugMode) {
      print('business details dispose');
    }
    widget.businessDetailsViewmodel.dispose();
    super.dispose();
  } 

  Widget buildBusinessOverview( WidgetFactory widgetFactory) {
    return SingleChildScrollView(
      primary: true,
      padding: const EdgeInsets.symmetric(horizontal: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          appWidgetFactory.createCard(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                if (widget.businessDetailsViewmodel.businessData?.description?.isNotEmpty == true) ...[
                  appWidgetFactory.createText(context, '${widget.businessDetailsViewmodel.businessData?.description.localize()}', style: Theme.of(context).textTheme.labelMedium, maxLines: 3, overflow: TextOverflow.ellipsis),
                ],
                const SizedBox(height: 16),
                const BusinessAddressQuickActionComponenet(),
                const SizedBox(height: 16),
                appWidgetFactory.createButton(context: context, content: const Text('Get more info'), onPressed: () {}),
                const SizedBox(height: 16),
              ],
            ),
          ),
          const SizedBox(height: 16),
          AppGridView(
            shrinkWrap: true,
            // controller: widget.businessDetailsViewmodel.productListController,
            items: widget.businessDetailsViewmodel.featuredProducts,
            crossAxisCount: 2,
            crossAxisSpacing: 8,
            mainAxisSpacing: 16,
            primary: false,
            isStaggered: true,
            header: AppListHeader(
              title: 'Featured Products',
              subtitle: 'View all fetured products from this business',
              trailing: appWidgetFactory.createIcon(materialIcon: Icons.arrow_forward_ios, color: Theme.of(context).primaryColor, backgroundColor: Theme.of(context).colorScheme.primaryContainer, padding: const EdgeInsets.all(8)),
              onActionClicked: () {
                widget.businessDetailsViewmodel.navigateToFeaturedProductListPage(context);
              },
            ),
            itemBuilder: (context, productData, index) {
              return GridProductListItem(product: productData, imageHeight: 150, imageWidth: double.infinity, widgetFactory: widgetFactory, onTap: () {
                widget.businessDetailsViewmodel.navigateToProductDetails(context, productData);
              });
            },
          ),
          const SizedBox(height: 24),
          widgetFactory.createButton(context: context, content: const Text('View all products'), onPressed: () {
            widget.businessDetailsViewmodel.navigateToAllProductsPage(context);
          }),
        ],
      ),
    );
  }
}
