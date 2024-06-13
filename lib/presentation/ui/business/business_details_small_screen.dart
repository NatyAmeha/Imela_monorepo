import 'package:flutter/material.dart';
import 'package:get/get_state_manager/src/rx_flutter/rx_obx_widget.dart';
import 'package:melegna_customer/presentation/resources/colors.dart';
import 'package:melegna_customer/presentation/ui/business/business.viewmodel.dart';
import 'package:melegna_customer/presentation/ui/factory/widget.factory.dart';
import 'package:melegna_customer/presentation/ui/shared/app_image.dart';
import 'package:melegna_customer/presentation/ui/shared/app_tabview.dart';
import 'package:melegna_customer/presentation/ui/shared/banner_item.dart';
import 'package:melegna_customer/presentation/ui/shared/listview.component.dart';
import 'package:melegna_customer/presentation/ui/shared/page_content_loader.dart';
import 'package:melegna_customer/services/routing_service.dart';

class BusinessDetailsSmallScreen extends StatelessWidget {
  final BusinessDetailsViewModel businessDetailsViewmodel;
  final String? businessName;
  BusinessDetailsSmallScreen({super.key, required this.businessDetailsViewmodel, this.businessName});

  final _routingService = GoRouterService();

  @override
  Widget build(BuildContext context) {
    var appWidgetFactory = WidgetFactory(TargetPlatform.iOS);
    return Scaffold(
      appBar: AppBar(
        title: businessName != null ? Text(businessName!) : null,
      ),
      body: Obx(
        () => PageContentLoader(
          showContent: businessDetailsViewmodel.businessDetails.value != null,
          isLoading: businessDetailsViewmodel.isLoading.value,
          hasError: businessDetailsViewmodel.exception.value?.isMainError ?? false,
          content: Column(
            children: [
              Container(
                width: 400,
                height: 500,
                child: AppTabView(tabs: [
                  appWidgetFactory.createText(context, "Overview"),
                  appWidgetFactory.createText(context, "Products"),
                ], tabViews: [
                  CustomListView(
                    scrollDirection: Axis.vertical,
                    header: appWidgetFactory.createListTile(title: Text("Products"), subtitle: Text("Product list subtitle"), trailing: Icon(Icons.add)),
                    controller: businessDetailsViewmodel.productListController,
                    itemBuilder: (context, item, index) {
                      return appWidgetFactory.createCard(
                        padding: EdgeInsets.all(8),
                        borderRadius: BorderRadius.circular(16),
                        color: Theme.of(context).colorScheme.primaryContainer,
                        child: Column(
                          children: [
                            appWidgetFactory.createText(context, "${item.name?.firstOrNull?.value}"),
                            Text("${item.description?.firstOrNull?.value}"),
                            Text(item.loyaltyPoint.toString()),
                          ],
                        ),
                      );
                    },
                  ),
                  Column(
                    children: [
                      AppImage(
                        imageUrl: "https://images.unsplash.com/photo-1588286840104-8957b019727f?crop=entropy&cs=tinysrgb&fit=max&fm=jpg&ixid=M3w0NTYyMDF8MHwxfHNlYXJjaHw0fHx5b2dhfGVufDB8fHx8MTcwODAxMDkwOHww&ixlib=rb-4.0.3&q=80&w=1080",
                        width: 120,
                        height: 200,
                        borderRadius: BorderRadius.circular(15),
                        gradient: LinearGradient(
                          colors: [Colors.black.withOpacity(0.3), Colors.transparent],
                          begin: Alignment.bottomCenter,
                          end: Alignment.topCenter,
                        ),
                        heroTag: 'exampleHeroTag',
                      ),
                      const SizedBox(height: 16),
                      const BannerItemComponent(title: "Become a member", width: 300, backgroundColor: ColorManager.success),
                    ],
                  )
                ]),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
