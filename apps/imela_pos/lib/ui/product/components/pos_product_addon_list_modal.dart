import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:imela_core/product/model/product_addon.model.dart';
import 'package:imela_core/shared/localized_field.model.dart';
import 'package:imela_pos/ui/product/components/addon_viewmodel.dart';

class PosProductAddonModal extends StatefulWidget {
  final List<ProductAddon> productAddons;
  const PosProductAddonModal({super.key, required this.productAddons});

  @override
  State<PosProductAddonModal> createState() => _PosProductAddonModalState();
}

class _PosProductAddonModalState extends State<PosProductAddonModal> {
  final viewmodel = ProductAddonViewmodel.getInstance();

  @override
  void initState() {
    super.initState();
    viewmodel.initViewmodel(data: {'productAddons': widget.productAddons});
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Product Add-ons/Configurations', style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 10),
            Obx(() {
              return ListView.builder(
                shrinkWrap: true,
                itemCount: viewmodel.productAddons.value.length,
                itemBuilder: (context, index) {
                  final addon = viewmodel.productAddons[index];
                  return ListTile(
                    title: Text(addon.name.localize(viewmodel.selectedLanguage)),
                    subtitle: Text('Additional Price: ${addon.additionalPrice?.map((e) => e.amount.toString()) ?? "0"}'),
                    trailing: ElevatedButton(
                      onPressed: viewmodel.isAddonSelectable(addon)
                          ? () {
                              viewmodel.showAddonOptionsDialog(context, addon);
                            }
                          : null,
                      child: Text('Select Options'),
                    ),
                    isThreeLine: true,
                  );
                },
              );
            }),
            const SizedBox(height: 10),
            ElevatedButton(
              onPressed: () {
                viewmodel.closeAdddonConfigModalWithResult();
              },
              child: const Text('Finish'),
            ),
          ],
        ),
      );
  }
}
