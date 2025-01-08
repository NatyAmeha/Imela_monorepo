import 'package:flutter/material.dart';
import 'package:get/get.dart';
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
              if (nonMembershipAddons.isNotEmpty) const Tab(text: 'Additional perks'),
              if (membershipAddons.isNotEmpty) const Tab(text: 'Membership perks'),
            ],
          ),
          Expanded(
            child: TabBarView(
              controller: tabController,
              children: [
                if (nonMembershipAddons.isNotEmpty) buildAddonList(context, nonMembershipAddons).paddingSymmetric(vertical: 16),
                if (membershipAddons.isNotEmpty) buildAddonList(context, membershipAddons).paddingSymmetric(vertical: 16),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget buildAddonList(BuildContext context, List<ProductAddon> addons, {bool isMembership = false}) {
    final emptyAddonText = isMembership ? 'No membership perks' : 'No additional perks';
    return Column(
      children: [
        if (addons.isEmpty) widget.widgetFactory.createText(context, emptyAddonText).paddingSymmetric(vertical: 40),
        AppListView(
          items: addons,
          shrinkWrap: true,
          primary: false,
          contentPadding: const EdgeInsets.symmetric(vertical: 4),
          itemBuilder: (context, addon, index) {
            return Row(
              children: [
                widget.widgetFactory.createIcon(materialIcon: Icons.check_circle, color: Theme.of(context).colorScheme.primary),
                const SizedBox(width: 10),
                widget.widgetFactory.createText(context, addon.name.localize(widget.selectedLanguage)),
              ],
            );
          },
        ),
      ],
    );
  }
}
