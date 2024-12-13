import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:imela_core/product/model/product.model.dart';
import 'package:imela_core/product/model/product_addon.model.dart';
import 'package:imela_core/shared/localized_field.model.dart';
import 'package:imela_ui_kit/components/list/listview.component.dart';
import 'package:imela_ui_kit/helpers/button_style.dart';
import 'package:imela_ui_kit/widget_factory/widget.factory.dart';

class ProductMembershipPerk extends StatefulWidget {
  final Product product;
  final WidgetFactory widgetFactory;
  final String selectedLanguage;
  final Function() onBecomeMemberPressed;
  const ProductMembershipPerk({super.key, required this.widgetFactory, required this.product, required this.selectedLanguage, required this.onBecomeMemberPressed});

  @override
  State<ProductMembershipPerk> createState() => _ProductMembershipPerkState();
}

class _ProductMembershipPerkState extends State<ProductMembershipPerk> with SingleTickerProviderStateMixin {
  late final TabController tabController;
  List<ProductAddon> get membershipAddons => widget.product.getAddons(getDefault: true).where((addon) => addon.membershipIds?.isNotEmpty == true).toList();

  List<ProductAddon> get nonMembershipAddons => widget.product.getAddons(getDefault: true).where((addon) => addon.membershipIds?.isEmpty == true || addon.membershipIds == null).toList();
  
  @override
  void initState() {
    super.initState();
    tabController = TabController(length: 2, vsync: this);
  }

  @override
  Widget build(BuildContext context) {
    return widget.widgetFactory.createCard(
      height: 300,
      child: Column(
        children: [
          TabBar(
           
            tabAlignment: TabAlignment.start,
            isScrollable: true,
            controller: tabController,
            tabs: [
              Tab(text: 'Additional perks'),
              Tab(text: 'Membership perks'),
            ],
          ),
          Expanded(
            child: TabBarView(
              controller: tabController,
              children: [
                buildAddonList(context, nonMembershipAddons),
                buildAddonList(context, membershipAddons),
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
          itemBuilder: (context, addon, index) {
            return Row(
              children: [widget.widgetFactory.createIcon(materialIcon: Icons.check_circle, color: Theme.of(context).colorScheme.primary), widget.widgetFactory.createText(context, addon.name.localize(widget.selectedLanguage))],
            );
          },
        ),
        const SizedBox(height: 16),
        if (isMembership)
          widget.widgetFactory.createButton(
            context: context,
            style: AppButtonStyle.textButtonStyle(context),
            content: const Text('Become a member'),
            onPressed: () {
              widget.onBecomeMemberPressed();
            },
          )
      ],
    );
  }
}
