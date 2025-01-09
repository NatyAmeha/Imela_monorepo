import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:imela/l10n/l10n.dart';
import 'package:imela/presentation/ui/app_controller.dart';
import 'package:imela_core/product/model/product.model.dart';
import 'package:imela_core/product/model/product_addon.model.dart';
import 'package:imela_core/shared/localized_field.model.dart';
import 'package:imela_ui_kit/components/list/listview.component.dart';
import 'package:imela_ui_kit/widget_factory/widget.factory.dart';

class ProductMembershipPerk extends StatefulWidget {
  final Product product;
  final WidgetFactory widgetFactory;
  final String selectedLanguage;
  final double height;
  final Function() onBecomeMemberPressed;
  const ProductMembershipPerk({
    super.key,
    required this.widgetFactory,
    required this.product,
    required this.selectedLanguage,
    required this.onBecomeMemberPressed,
    this.height = 300,
  });

  @override
  State<ProductMembershipPerk> createState() => _ProductMembershipPerkState();
}

class _ProductMembershipPerkState extends State<ProductMembershipPerk> with SingleTickerProviderStateMixin {
  late final TabController tabController;
  final appController = AppController.getInstance;
  List<ProductAddon> get membershipAddons => widget.product.getMembershipAddons();
  List<ProductAddon> get nonMembershipAddons => widget.product.getNonMembershipAddons();

  int get tabLength {
    if (membershipAddons.isNotEmpty && nonMembershipAddons.isNotEmpty) {
      return 2;
    } else if (membershipAddons.isNotEmpty || nonMembershipAddons.isNotEmpty) {
      return 1;
    }
    return 0;
  }

  @override 
  void initState() {
    super.initState();
    tabController = TabController(length: tabLength, vsync: this);
  }

  @override
  Widget build(BuildContext context) {
    return widget.widgetFactory.createCard(
      height: widget.height,
      child: Column(
        children: [
          TabBar(
            tabAlignment: TabAlignment.start,
            isScrollable: true,
            controller: tabController,
            tabs: [
              if (nonMembershipAddons.isNotEmpty) Tab(text: appController.getAppContext().l10n.additionalPerks),
              if (membershipAddons.isNotEmpty) Tab(text: appController.getAppContext().l10n.membershipPerks),
            ],
          ),
          Expanded(
            child: TabBarView(
              controller: tabController,
              children: [
                if (nonMembershipAddons.isNotEmpty)
                  AppListView(
                    items: nonMembershipAddons,
                    shrinkWrap: true,
                    itemBuilder: (context, addon, index) {
                      return ListTile(
                        title: widget.widgetFactory.createText(context, addon.name.localize(widget.selectedLanguage)),
                      );
                    },
                  ),
                if (membershipAddons.isNotEmpty)
                  AppListView(
                    items: membershipAddons,
                    shrinkWrap: true,
                    itemBuilder: (context, addon, index) {
                      return ListTile(
                        title: widget.widgetFactory.createText(context, addon.name.localize(widget.selectedLanguage)),
                      );
                    },
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
