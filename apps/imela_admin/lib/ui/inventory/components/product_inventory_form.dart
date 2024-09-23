import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:imela_admin/app/app_viewmodel.dart';
import 'package:imela_admin/ui/inventory/product_inventory_viewmodel.dart';
import 'package:imela_admin/ui/product/components/product_options_form.dart';
import 'package:imela_core/branch/model/inventory_location.model.dart';
import 'package:imela_ui_kit/helpers/widget_extesions.dart';

class ProductInventoryForm extends StatelessWidget {
  final List<InventoryLocation> locations;
  final List<ProductVariant> variants;
  final Function onCreateNeWBranch;
  final Function(List<ProductVariant> updatedVariants)? onContinue;

  ProductInventoryForm({super.key, required this.locations, required this.variants, required this.onCreateNeWBranch, required this.onContinue});

  final viewmodel = ProductInventoryViewmodel.getInstance();

  void updateViewmodel() {
    Future.delayed(Duration.zero, () {
      viewmodel.updateLocationandVariant(locations, variants);
    });
  }

  @override
  Widget build(BuildContext context) {
    updateViewmodel();
    final widgetFactory = AppViewmodel.getWidgetFactory(context);
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              widgetFactory.createText(context, 'Inventory', style: Theme.of(context).textTheme.titleMedium),
              widgetFactory.createButton(
                  context: context,
                  content: const Text('Create New branch'),
                  onPressed: () {
                    onCreateNeWBranch();
                  }),
            ],
          ),
          _buildTableHeader(),
          _buildTableBody(),
          widgetFactory
              .createButton(
                  context: context,
                  content: const Text('Continue'),
                  onPressed: () {
                    onContinue?.call(viewmodel.selecteProductVariants);
                  })
              .withPaddingAll(32)
        ],
      ),
    );
  }

  Widget _buildTableHeader() {
    return Obx(
      () => Row(
        children: [
          // First column for variants
          Expanded(
            child: Container(
              padding: const EdgeInsets.all(8),
              child: const Text('Product Variants', style: TextStyle(fontWeight: FontWeight.bold)),
            ),
          ),
          // Columns for each inventory location
          ...viewmodel.inventoryLocations.map((location) {
            return Expanded(
              child: Container(
                padding: const EdgeInsets.all(8),
                child: Text(location.name ?? "", style: const TextStyle(fontWeight: FontWeight.bold)),
              ),
            );
          }).toList(),
        ],
      ),
    );
  }

  // Table Body (Rows for each variant)
  Widget _buildTableBody() {
    return Obx(
      () => Column(
        children: viewmodel.selecteProductVariants.map((variant) {
          return Row(
            children: [
              // First column: variant description
              Expanded(
                child: Container(
                  padding: const EdgeInsets.all(8),
                  child: Text(variant.variantName),
                ),
              ),
              // Inventory location columns (TextField + Checkbox)
              ...viewmodel.inventoryLocations.map(
                (location) {
                  var key = viewmodel.generateKey(viewmodel.variantKey(variant), location.name ?? "");
                  return Expanded(
                    child: Container(
                      padding: const EdgeInsets.all(8),
                      child: _buildInventoryCell(key),
                    ),
                  );
                },
              ),
            ],
          );
        }).toList(),
      ),
    );
  }

  // Widget for the inventory cell (TextField + Checkbox)
  Widget _buildInventoryCell(String key) {
    return Column(
      children: [
        // TextField for quantity (with GetX state management)
        Obx(() => TextField(
              controller: viewmodel.quantityControllers[key],
              decoration: const InputDecoration(
                labelText: 'Qty',
                border: OutlineInputBorder(),
                isDense: true,
              ),
              keyboardType: TextInputType.number,
            )),
        const SizedBox(height: 8),
        // Checkbox for availability (with GetX state management)
        Obx(() => Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text('Available'),
                Checkbox(
                  value: viewmodel.availabilityCheckboxes[key],
                  onChanged: (value) {
                    viewmodel.availabilityCheckboxes[key] = value!;
                  },
                ),
              ],
            )),
      ],
    );
  }
}
