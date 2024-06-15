import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:melegna_customer/domain/shared/localized_field.model.dart';
import 'package:melegna_customer/presentation/resources/colors.dart';
import 'package:melegna_customer/presentation/ui/business/business_details.viewmodel.dart';
import 'package:melegna_customer/presentation/ui/business/component/business_details_header.componenet.dart';
import 'package:melegna_customer/presentation/ui/business/component/business_quick_action.component.dart';
import 'package:melegna_customer/presentation/ui/factory/widget.factory.dart';
import 'package:melegna_customer/presentation/ui/product/components/grid_product_list_item.component.dart';
import 'package:melegna_customer/presentation/ui/shared/app_tabview.dart';
import 'package:melegna_customer/presentation/ui/shared/gridview.component.dart';
import 'package:melegna_customer/presentation/ui/shared/page_content_loader.dart';
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
    print("section data ${widget.businessDetailsViewmodel.sectionsWithProducts.length}");
    widget.businessDetailsViewmodel.assignTabController(widget.businessDetailsViewmodel.sectionsWithProducts.keys.length, this);
  }

  @override
  Widget build(BuildContext context) {
    appWidgetFactory = WidgetFactory(Theme.of(context).platform);
    return NestedScrollView(
      headerSliverBuilder: (context, innerBoxIsScrolled) => [
        SliverAppBar(
          expandedHeight: 220,
          collapsedHeight: 60,
          pinned: true,
          title: Text('${widget.businessDetailsViewmodel.businessData?.getLocalizedBusinessName(AppLanguage.ENGLISH.name)}'),
          floating: false,
          backgroundColor: ColorManager.alternate,
          automaticallyImplyLeading: false,
          leading: appWidgetFactory.createIcon(
            materialIcon: Icons.arrow_back_ios,
            onPressed: () {
              Navigator.of(context).pop();
            },
          ),
          actions: [],
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
          bottom: TabBar(controller: widget.businessDetailsViewmodel.businessSectionTabControllers, tabs: widget.businessDetailsViewmodel.sectionsWithProducts.keys.map((e) => Tab(text: e)).toList()),
        ),
      ],
      body: AppTabView(
        tabs: widget.businessDetailsViewmodel.sectionsWithProducts.keys.map((e) => Tab(text: e)).toList(),
        controller: widget.businessDetailsViewmodel.businessSectionTabControllers,
        tabViews: widget.businessDetailsViewmodel.sectionsWithProducts.entries.map((entry) {
          if (entry.key == "Overview") {
            return buildBusinessOverview();
          }
          return AppGridView(
            controller: entry.value,
            crossAxisCount: 2,
            isStaggered: true,
            header: appWidgetFactory.createListTile(title: Text("Services"), subtitle: Text("description of list tile "), trailing: appWidgetFactory.createIcon(materialIcon: Icons.arrow_forward_ios), onTap: () {}),
            itemBuilder: (context, productData, index) {
              return GridProductListItem(product: productData, imageHeight: 150, imageWidth: double.infinity);
            },
          );
        }).toList(),
      ),
    );
  }

  Widget buildBusinessOverview() {
    return SingleChildScrollView(
      primary: true,
      padding: const EdgeInsets.symmetric(horizontal: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // if (businessDetailsViewmodel.sectionNames.isNotEmpty) ...[
          //   AppListView(
          //       scrollDirection: Axis.horizontal,
          //       height: 100,
          //       width: 400,
          //       controller: businessDetailsViewmodel.businessOfferringListController,
          //       itemBuilder: (context, data, index) {
          //         return const BannerItemComponent(title: "Membership", subtitle: "Membership description with subscription, benefits and other perks", width: 300, backgroundColor: ColorManager.primary);
          //       }),
          // ],
          if (widget.businessDetailsViewmodel.businessData?.description?.isNotEmpty == true) ...[
            appWidgetFactory.createText(context, "${widget.businessDetailsViewmodel.businessData?.description.getLocalizedValue(AppLanguage.ENGLISH.name)}", style: Theme.of(context).textTheme.labelMedium, maxLines: 3, overflow: TextOverflow.ellipsis),
          ],
          const SizedBox(height: 16),
          const BusinessAddressQuickActionComponenet(),
          const SizedBox(height: 16),
          appWidgetFactory.createButton(context: context, content: Text("Get more info"), onPressed: () {}),
          const SizedBox(height: 16),

          AppGridView(
            height: 800,
            controller: widget.businessDetailsViewmodel.productListController,
            crossAxisCount: 2,
            crossAxisSpacing: 8,
            mainAxisSpacing: 16,
            primary: false,
            isStaggered: true,
            header: appWidgetFactory.createListTile(title: Text("Services"), subtitle: Text("description of list tile "), trailing: appWidgetFactory.createIcon(materialIcon: Icons.arrow_forward_ios), onTap: () {}),
            itemBuilder: (context, productData, index) {
              return GridProductListItem(product: productData, imageHeight: 150, imageWidth: double.infinity);
            },
          )
        ],
      ),
    );
  }
}
