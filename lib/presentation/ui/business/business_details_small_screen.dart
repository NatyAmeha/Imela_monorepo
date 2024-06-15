import 'package:flutter/material.dart';
import 'package:melegna_customer/domain/business/model/business.model.dart';
import 'package:melegna_customer/presentation/resources/colors.dart';
import 'package:melegna_customer/presentation/ui/business/business_details.viewmodel.dart';
import 'package:melegna_customer/presentation/ui/business/component/business_details_header.componenet.dart';
import 'package:melegna_customer/presentation/ui/factory/widget.factory.dart';
import 'package:melegna_customer/presentation/ui/product/components/grid_product_list_item.component.dart';
import 'package:melegna_customer/presentation/ui/shared/app_tabview.dart';
import 'package:melegna_customer/presentation/ui/shared/banner_item.dart';
import 'package:melegna_customer/presentation/ui/shared/gridview.component.dart';
import 'package:melegna_customer/presentation/ui/shared/list.viewmodel.dart';
import 'package:melegna_customer/presentation/ui/shared/listview.component.dart';

class BusinessDetailsSmallScreen extends StatelessWidget {
  final BusinessDetailsViewModel businessDetailsViewmodel;
  final String? businessName;
  BusinessDetailsSmallScreen({super.key, required this.businessDetailsViewmodel, this.businessName});
  var customListController = CustomListController<int>();

  @override
  Widget build(BuildContext context) {
    customListController.addItems([1, 2, 3, 4, 5, 6, 7, 8, 9, 10]);
    var appWidgetFactory = WidgetFactory(Theme.of(context).platform);
    return Scaffold(
      body: NestedScrollView(
          headerSliverBuilder: (context, innerBoxIsScrolled) => [
                SliverAppBar(
                  expandedHeight: 220,
                  collapsedHeight: 70,
                  pinned: true,
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
                    // title: appWidgetFactory.createText(context, "Business Name", style: Theme.of(context).textTheme.headlineMedium),
                    centerTitle: true,
                    expandedTitleScale: 1.0,
                    background: BusinessDetailsHeader(
                      business: Business(id: ""),
                      width: double.infinity,
                      height: 150,
                      controller: PageController(initialPage: 0),
                    ),
                  ),
                ),
              ],
          body: AppTabView(
            tabs: [
              Tab(text: "About"),
              Tab(text: "Services"),
              Tab(text: "Reviews"),
            ],
            tabViews: [
              SingleChildScrollView(
                primary: true,
                child: Column(
                  children: [
                    AppListView(
                        scrollDirection: Axis.horizontal,
                        height: 100,
                        width: 400,
                        controller: customListController,
                        itemBuilder: (context, data, index) {
                          return const BannerItemComponent(title: "Membership", subtitle: "Membership description with subscription, benefits and other perks", width: 300, backgroundColor: ColorManager.primary);
                        }),
                    appWidgetFactory.createText(context, "business description here" * 12, style: Theme.of(context).textTheme.labelMedium, maxLines: 3, overflow: TextOverflow.ellipsis),
                    appWidgetFactory.createButton(context: context, content: Text("Get more info"), onPressed: () {}),
                    const SizedBox(height: 16),
                    AppGridView(
                        height: 800,
                        controller: customListController,
                        crossAxisCount: 2,
                        primary: false,
                        isStaggered: true,
                        // childAspectRatio: 0.6,
                        header: appWidgetFactory.createListTile(title: Text("Services"), subtitle: Text("description of list tile "), trailing: appWidgetFactory.createIcon(materialIcon: Icons.arrow_forward_ios), onTap: () {}),
                        itemBuilder: (context, data, index) {
                          return const GridProductListItem(imageHeight: 100, imageWidth: double.infinity);
                        })
                  ],
                ),
              )
            ],
          )),
    );
  }
}
