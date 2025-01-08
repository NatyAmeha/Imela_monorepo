import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:imela/presentation/ui/app_controller.dart';
import 'package:imela/presentation/ui/business/business_section/business_section.viewmodel.dart';
import 'package:imela/presentation/ui/product/components/grid_product_list_item.component.dart';
import 'package:imela/presentation/ui/product/components/product_item_badge.dart';
import 'package:imela/presentation/ui/shared/app_choicechip_group.component.dart';
import 'package:imela_core/business/model/business.section.dart';
import 'package:imela_ui_kit/components/list/gridview.component.dart';
import 'package:imela_ui_kit/components/page_loading_utils/page_content_loader.dart';
import 'package:imela_ui_kit/helpers/widget_extesions.dart';
import 'package:imela_ui_kit/widget_factory/widget.factory.dart';

class BusinessSectionPage extends StatefulWidget {
  static const routeName = '/business/:business_id/section/:section_id';
  static const BUSINESS_ID_KEY = 'business_id';
  static const SECTION_ID_KEY = 'section_id';
  static const SECTION_INFO_KEY = 'section_info';

  final String businessId;
  final String sectionId;
  final BusinessSection? sectionInfo;

  const BusinessSectionPage({
    super.key,
    required this.businessId,
    required this.sectionId,
    this.sectionInfo,
  });

  @override
  State<BusinessSectionPage> createState() => _BusinessSectionPageState();

  static void navigate(BuildContext context, String businessId, {required BusinessSection section}) {
    final router = AppController.getInstance.router;
    router.navigateTo(context, '/business/$businessId/section/${section.id!}', extra: {BusinessSectionPage.SECTION_INFO_KEY: section});
  }
}

class _BusinessSectionPageState extends State<BusinessSectionPage> {
  var viewmodel = BusinessSectionViewModel.getInstance();
  late WidgetFactory widgetFactory;

  @override
  void initState() {
    super.initState();
    widgetFactory = AppController.getInstance.getWidgetFactory(context);
    viewmodel.initViewmodel(data: {BusinessSectionPage.BUSINESS_ID_KEY: widget.businessId, BusinessSectionPage.SECTION_ID_KEY: widget.sectionId, BusinessSectionPage.SECTION_INFO_KEY: widget.sectionInfo});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: NestedScrollView(
        controller: viewmodel.businessHeaderScrollController,
        headerSliverBuilder: (context, innerBoxIsScrolled) => [
          Obx(
            () => SliverAppBar(
              expandedHeight: 60,
              collapsedHeight: 60,
              pinned: true,
              title: Text(viewmodel.sectionName),
              floating: false,
              backgroundColor: Theme.of(context).colorScheme.primary,
              // flexibleSpace: FlexibleSpaceBar(
              //   background: Column(
              //     mainAxisAlignment: MainAxisAlignment.end,
              //     children: [
              //       SearchBar(
              //         hintText: 'Search products and bundles',
              //         leading: widgetFactory.createIcon(materialIcon: Icons.search),
              //         onTap: () {},
              //       ).paddingSymmetric(vertical: 10, horizontal: 16),
              //     ],
              //   ),
              //   centerTitle: false,
              // ),
              bottom: PreferredSize(
                preferredSize: Size(MediaQuery.of(context).size.width, 40),
                child: viewmodel.businessSectionDetails.value != null
                    ? Obx(
                        () => AppChoiceChipGroup(
                          height: 40,
                          isScrollable: true,
                          choices: viewmodel.sectionProductstags,
                          selectedChoices: [viewmodel.selectedTag.value],
                          onSelectionChanged: (value) {
                            viewmodel.chooseProductsByTags(value);
                          },
                        ), 
                      )
                    : const SizedBox.shrink(),
              ),
            ),
          ),
        ],
        body: Obx(
          () => PageContentLoader(
            isLoading: viewmodel.isLoading.value,
            showContent: viewmodel.businessSectionDetails.value != null && (viewmodel.filteredProducts.isNotEmpty),
            exception: viewmodel.exception.value,
            hasError: viewmodel.exception.value?.isMainError ?? false,
            onTryAgain: () {
              viewmodel.getBusinessSectionDetails(isRefresh: true);
            },
            content: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    widgetFactory.createText(context, 'Products', style: Theme.of(context).textTheme.titleMedium).withPaddingSymetric(horizontal: 12, vertical: 8),
                    widgetFactory.createText(context, 'View all', style: Theme.of(context).textTheme.bodySmall).withPaddingSymetric(horizontal: 12, vertical: 8),
                  ],
                ),
                if (viewmodel.filteredProducts.isEmpty)
                  _buildEmptySection()
                else
                  AppGridView(
                    height: MediaQuery.of(context).size.height - 225,
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                    crossAxisCount: 2,
                    isStaggered: true,
                    items: viewmodel.filteredProducts,
                    itemBuilder: (context, item, index) {
                      return GridProductListItem(
                        product: item,
                        badgeInfos: ProductBadgeInfo.getProductBadgeInfo(item),
                        widgetFactory: widgetFactory,
                        discounts: viewmodel.businessDetailsViewModel.allDiscounts,
                        onTap: () {
                          viewmodel.navigateToProductDetails(context, item);
                        },
                      );
                    },
                  )
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildEmptySection() {
    return widgetFactory.createText(context, 'No products found in this section', style: Theme.of(context).textTheme.bodySmall).withPaddingSymetric(horizontal: 12, vertical: 8);
  }
}
