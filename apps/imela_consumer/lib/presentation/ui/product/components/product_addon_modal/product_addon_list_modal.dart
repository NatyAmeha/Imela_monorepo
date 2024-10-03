import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:imela/presentation/ui/app_controller.dart';
import 'package:imela/presentation/ui/product/components/product_addon_modal/addon_viewmodel.dart';
import 'package:imela_core/order/model/order_config.model.dart';
import 'package:imela_core/product/model/product_addon.model.dart';
import 'package:imela_core/shared/localized_field.model.dart';
import 'package:imela_ui_kit/helpers/widget_extesions.dart';

class ProductAddonModal extends StatefulWidget {
  final List<ProductAddon> productAddons;
  final List<OrderConfig> initialOrderConfigs;
  const ProductAddonModal({super.key, required this.productAddons,  this.initialOrderConfigs = const []});

  @override
  State<ProductAddonModal> createState() => _ProductAddonModalState();
}

class _ProductAddonModalState extends State<ProductAddonModal> {
  final viewmodel = ProductAddonViewmodel.getInstance();

  @override
  void initState() {
    super.initState();
    viewmodel.initViewmodel(data: {'productAddons': widget.productAddons});
  }

  @override
  Widget build(BuildContext context) {
    viewmodel.addInitialOrderConfigs(widget.initialOrderConfigs);
    final widgetFactory = AppController.getInstance.getWidgetFactory(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text('Configurations', style: Theme.of(context).textTheme.titleLarge).withPaddingSymetric(horizontal: 16),
        const SizedBox(height: 10),
        Obx(() {
          return ListView.builder(
            shrinkWrap: true,
            itemCount: viewmodel.productAddons.value.length,
            itemBuilder: (context, index) {
              final addon = viewmodel.productAddons[index];
              return widgetFactory.createListTile(
                title: Text(addon.name.localize(viewmodel.selectedLanguage), style: Theme.of(context).textTheme.titleMedium),
                subtitle: Text('Additional Price: ${addon.additionalPrice?.map((e) => e.amount.toString()) ?? "0"}'),
                trailing: Obx(() => viewmodel.getAddonModifierUI(context, addon)),
              );
            },
          );
        }),
        const SizedBox(height: 10),
        widgetFactory
            .createButton(
              context: context,
              content: const Text('Finish'),
              onPressed: () {
                viewmodel.closeAdddonConfigModalWithResult();
              },
            )
            .withPaddingSymetric(vertical: 16, horizontal: 16)
      ],
    );
  }
}
