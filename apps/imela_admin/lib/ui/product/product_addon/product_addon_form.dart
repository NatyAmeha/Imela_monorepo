import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:imela_admin/app/app_viewmodel.dart';
import 'package:imela_admin/shared/component/multi_input_textfield.dart';
import 'package:imela_admin/ui/product/product_addon/product_addon.viewmodel.dart';
import 'package:imela_core/product/model/product_addon.model.dart';
import 'package:imela_ui_kit/helpers/button_style.dart';

class ProductAddonForm extends StatelessWidget {
  final Function(List<ProductAddon> addons) onContinue;
  ProductAddonForm({super.key, required this.onContinue});

  final viewmodel = ProductAddonViewmodel.getInstance();

  @override
  Widget build(BuildContext context) {
    final widgetFactory = AppViewmodel.getWidgetFactory(context);
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Obx(
        () => Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            widgetFactory.createText(context, 'Addons', style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 16),
            if (!viewmodel.isAddonCreateModalVisible.value)
              widgetFactory.createButton(
                  context: context,
                  content: const Text('Create New Addon'),
                  style: AppButtonStyle.textButtonStyle(context),
                  onPressed: () {
                    viewmodel.showAddonCreateModal(context);
                  }),
            // Addon Name
            widgetFactory.createText(context, 'Addon name', style: Theme.of(context).textTheme.titleSmall),

            MultiInputTextfield(viewmodel: viewmodel.addonNameInputViewodel, widgetFactory: widgetFactory, values: Map<String, String>.from(viewmodel.inputOptions), selectedKey: viewmodel.selectedInputOptionKey.value),

            const SizedBox(height: 16),

            widgetFactory.createDropDownBeta<String>(context, options: viewmodel.getInputTypes, selectedValues: [viewmodel.selectedInputType.value.name], showSearch: true, onChanged: (value) {
              viewmodel.updateSelectedInputType(value.first);
            }),
            const SizedBox(height: 40),

            const SizedBox(height: 16),

            // Additional Price
            widgetFactory.createText(context, 'Additional Price', style: Theme.of(context).textTheme.titleSmall),
            MultiInputTextfield(viewmodel: viewmodel.addonAdditionalPriceInputViewmodel, widgetFactory: widgetFactory, values: Map<String, String>.from(viewmodel.priceInputOptions), selectedKey: viewmodel.selectedPriceInputKey.value),

            const SizedBox(height: 16),

            // Min and Max Amount (conditionally visible)
            Obx(() {
              if (viewmodel.selectedInputType.value == AddonInputType.NUMBER_INPUT || viewmodel.selectedInputType.value == AddonInputType.MULTIPLE_SELECTION_INPUT) {
                return Column(
                  children: [
                    widgetFactory.createText(context, 'Min Amount', style: Theme.of(context).textTheme.titleSmall),
                    MultiInputTextfield(viewmodel: viewmodel.addonMinInputViewmodel, widgetFactory: widgetFactory, values: Map<String, String>.from(viewmodel.inputOptions), selectedKey: viewmodel.selectedInputOptionKey.value),
                    const SizedBox(height: 16),
                    widgetFactory.createText(context, 'Maximum amount', style: Theme.of(context).textTheme.titleSmall),
                    MultiInputTextfield(viewmodel: viewmodel.addonMaxAmountInputViewodel, widgetFactory: widgetFactory, values: Map<String, String>.from(viewmodel.inputOptions), selectedKey: viewmodel.selectedInputOptionKey.value),
                    const SizedBox(height: 16),
                  ],
                );
              }
              return const SizedBox.shrink();
            }),

            // Is Required Checkbox
            Obx(() => CheckboxListTile(
                  title: const Text('Is Required'),
                  value: viewmodel.isRequired.value,
                  onChanged: (value) {
                    viewmodel.isRequired.value = value ?? false;
                  },
                )),
            const SizedBox(height: 16),

            // Options (for selection input types)
            Obx(() {
              if (viewmodel.selectedInputType.value == AddonInputType.SINGLE_SELECTION_INPUT || viewmodel.selectedInputType.value == AddonInputType.MULTIPLE_SELECTION_INPUT) {
                return Column(
                  children: [
                    _buildOptionInput(),
                    const SizedBox(height: 16),
                    _buildOptionList(),
                  ],
                );
              }
              return const SizedBox.shrink();
            }),

            // Add Addon Button
            ElevatedButton(
              onPressed: () {
                viewmodel.addAddon();
              },
              child: const Text('Add Addon'),
            ),

            const SizedBox(height: 32),
            // Created Addon List
            _buildCreatedAddonList(),
            const SizedBox(height: 32),
            widgetFactory.createButton(
                context: context,
                content: const Text('Continue'),
                onPressed: () {
                  onContinue(viewmodel.createdAddons);
                }),
          ],
        ),
      ),
    );
  }

  Widget _buildOptionInput() {
    final TextEditingController optionNameController = TextEditingController();
    final TextEditingController optionImageController = TextEditingController();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TextField(
          controller: optionNameController,
          decoration: const InputDecoration(
            labelText: 'Option Name',
            border: OutlineInputBorder(),
          ),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: optionImageController,
          decoration: const InputDecoration(
            labelText: 'Option Image URL',
            border: OutlineInputBorder(),
          ),
        ),
        const SizedBox(height: 8),
        ElevatedButton(
          onPressed: () {
            viewmodel.addOption(
              optionNameController.text,
              optionImageController.text,
            );
            optionNameController.clear();
            optionImageController.clear();
          },
          child: const Text('Add Option'),
        ),
      ],
    );
  }

  // List of added options
  Widget _buildOptionList() {
    return Obx(() {
      return Column(
        children: viewmodel.options
            .map(
              (option) => ListTile(
                title: Text(option.name?.firstOrNull?.value ?? ''),
                // subtitle: Text(option.imageUrl),
              ),
            )
            .toList(),
      );
    });
  }

  // List of created addons
  Widget _buildCreatedAddonList() {
    return Obx(() {
      if (viewmodel.createdAddons.isEmpty) {
        return const Text('No addons created yet.');
      }

      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: viewmodel.createdAddons
            .map(
              (addon) => Card(
                margin: const EdgeInsets.symmetric(vertical: 8.0),
                child: ListTile(
                  title: Text(addon.name?.firstOrNull?.value ?? ''),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Input Type: ${addon.inputType.toString().split('.').last}'),
                      Text('Additional Price: ${addon.additionalPrice}'),
                      if (addon.minAmount != null) Text('Min Amount: ${addon.minAmount}'),
                      if (addon.maxAmount != null) Text('Max Amount: ${addon.maxAmount}'),
                      Text('Is Required: ${addon.isRequired ? "Yes" : "No"}'),
                      if (addon.options.isNotEmpty) ...[
                        const SizedBox(height: 8),
                        const Text('Options:'),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: addon.options
                              .map(
                                (option) => Padding(
                                  padding: const EdgeInsets.symmetric(vertical: 4.0),
                                  child: Text('- ${option.name}'),
                                ),
                              )
                              .toList(),
                        ),
                      ],
                    ],
                  ),
                  trailing: IconButton(
                    icon: const Icon(Icons.delete),
                    onPressed: () {
                      viewmodel.createdAddons.remove(addon);
                    },
                  ),
                ),
              ),
            )
            .toList(),
      );
    });
  }
}
