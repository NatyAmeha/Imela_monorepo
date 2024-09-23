import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:imela_admin/app/app_viewmodel.dart';
import 'package:imela_admin/ui/product/components/product_variant_listitem.dart';
import 'package:imela_admin/ui/product/create_product_viewmodel.dart';
import 'package:imela_core/product/dto/create_inventory.input.dart';
import 'package:imela_core/product/dto/create_product.input.dart';
import 'package:imela_core/product/model/product.model.dart';
import 'package:imela_core/shared/gallery.model.dart';
import 'package:imela_core/shared/price.model.dart';

class ProductOptionsGenerator {
  String name;
  List<OptionValue> values;

  ProductOptionsGenerator({required this.name, required this.values});
}

class OptionValue {
  String value;

  OptionValue(this.value);
}

class ProductVariant {
  String name;
  final Map<String, String>? options; // Store selected option values (e.g., {'Size': 'Medium', 'Color': 'Red'})
  final String? imageUrl;
  final bool isSelected;
  List<Price> defaultPrice;
  final Map<String, List<Price>>? branchPrices;
  final Map<String, double>? branchQty;
  final bool isMainProduct;
  ProductVariant({
    required this.name,
    this.options,
    this.imageUrl,
    this.isSelected = false,
    this.defaultPrice = const [],
    this.branchPrices,
    required this.isMainProduct,
    this.branchQty,
  });

  String get variantName {
    if (options == null || options?.isEmpty == true) {
      return name;
    }
    return options?.entries.map((e) => '${e.key}: ${e.value}').join(', ') ?? name;
  }

  CreateProductInput converToProductCreateInput(CreateProductInput mainProductInput, List<ProductOptionsGenerator> allOptions) {
    var finalProductInputInfo = CreateProductInput.fromJson(mainProductInput.toJson());

    var inventoryInfo = branchQty?.entries.map((entry) {
          return CreateInventoryInput(inventoryLocationId: entry.key, qty: entry.value, minOrderQty: 1);
        }).toList() ??
        [];
    var optionsData = allOptions.asMap().map((key, value) => MapEntry(value.name, value.values.map((e) => e.value).toList()));
    finalProductInputInfo = finalProductInputInfo.copyWith(
      gallery: Gallery.fakeGalleryData(),
      optionsIncluded: options?.values.toList(),
      defaultPrices: defaultPrice,
      inventoryInfo: inventoryInfo,
      options: optionsData,
    );

    return finalProductInputInfo;
  }
}

class ProductOptionsForm extends StatelessWidget {
  final Function onSkip;
  final Function onContinue;
  ProductOptionsForm({super.key, required this.onSkip, required this.onContinue});
  final viewmode = CreateProductViewmodel.getInstance();

  @override
  Widget build(BuildContext context) {
    final widgetFactory = AppViewmodel.getWidgetFactory(context);
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text('Product Options'),
            widgetFactory.createButton(
                context: context,
                content: Text('Skip'),
                onPressed: () {
                  onSkip();
                })
          ],
        ),
        SizedBox(height: 10),
        Obx(() => ListView.builder(
              shrinkWrap: true,
              itemCount: viewmode.options.length,
              itemBuilder: (context, index) {
                final option = viewmode.options[index];
                return OptionWidget(option: option, index: index);
              },
            )),
        ElevatedButton(
          onPressed: () => viewmode.showAddOptionDialog(context),
          child: Text('Add Option'),
        ),
        SizedBox(height: 20),
        Text('Selected Variants'),
        Obx(() {
          var variants = viewmode.getVariants();
          return ListView.builder(
            shrinkWrap: true,
            itemCount: variants.length,
            itemBuilder: (context, index) {
              final variant = variants[index];
              return ProductVariantListItem(
                variant: variant,
                onVariantSelected: (isSelected) {
                  viewmode.addOrRemoveFromSelectedVariant(variant, isSelected, isDefaultVariant: true);
                  viewmode.getVariants();
                },
              );
            },
          );
        }),
        const SizedBox(height: 20),
        widgetFactory.createButton(
          context: context,
          content: const Text('Continue'),
          onPressed: () {
            onContinue();
          },
        ),
      ],
    );
  }
}

class OptionWidget extends StatelessWidget {
  final ProductOptionsGenerator option;
  final int index;

  OptionWidget({required this.option, required this.index});
  final viewmodel = CreateProductViewmodel.getInstance();

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(option.name, style: TextStyle(fontWeight: FontWeight.bold)),
            Row(
              children: [
                IconButton(
                  icon: Icon(Icons.edit),
                  onPressed: () => _showEditOptionDialog(context),
                ),
                IconButton(
                  icon: Icon(Icons.delete),
                  onPressed: () => viewmodel.deleteOption(index),
                ),
              ],
            ),
          ],
        ),
        Wrap(
          children: option.values
              .map(
                (entry) => Chip(
                  label: Text(entry.value),
                ),
              )
              .toList(),
        ),
        SizedBox(height: 10),
      ],
    );
  }

  void _showEditOptionDialog(BuildContext context) {
    // Reuse the same dialog to edit options
    viewmodel.showAddOptionDialog(context, existingOption: option, index: index);
  }

  void _showEditValueDialog(BuildContext context, int valueIndex) {
    final valueController = TextEditingController(
      text: viewmodel.options[index].values[valueIndex].value,
    );

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Edit Option Value'),
          content: TextField(
            controller: valueController,
            decoration: InputDecoration(labelText: 'Option Value'),
          ),
          actions: [
            TextButton(
              onPressed: () {
                var newValue = valueController.text.trim();
                if (newValue.isNotEmpty) {
                  // Update the option value using the controller
                  viewmodel.editOptionValue(index, valueIndex, newValue);
                }
                Get.back();
              },
              child: Text('Update'),
            ),
            TextButton(
              onPressed: () {
                Get.back(); // Close the dialog without saving
              },
              child: Text('Cancel'),
            ),
          ],
        );
      },
    );
  }
}
