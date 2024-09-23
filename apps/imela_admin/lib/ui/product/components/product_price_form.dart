import 'package:flutter/material.dart';
import 'package:get/get_state_manager/src/rx_flutter/rx_obx_widget.dart';
import 'package:imela_admin/app/app_viewmodel.dart';
import 'package:imela_admin/shared/component/multi_input_textfield.dart';
import 'package:imela_admin/ui/product/components/product_options_form.dart';
import 'package:imela_admin/ui/product/product_price.viewmodel.dart';
import 'package:imela_core/branch/model/branch.model.dart';
import 'package:imela_core/shared/localized_field.model.dart';
import 'package:imela_ui_kit/widget_factory/widget.factory.dart';
import 'package:imela_utils/helpers/localization_utils.dart';

class ProductPriceForm extends StatelessWidget {
  final List<ProductVariant> variants;
  final List<Branch> branches;
  final Function(List<ProductVariant> updatedVariants) onContinue;
  ProductPriceForm({super.key, required this.variants, required this.branches, required this.onContinue});
  final viewModel = ProductPriceViewmodel.getInstance();
  late final WidgetFactory widgetFactory;

  void updateViewmodelData() {
    Future.delayed(Duration.zero, () {
      viewModel.setVariants(variants);
      viewModel.setBranches(branches);
      viewModel.initPriceInputs();
    });
  }

  @override
  Widget build(BuildContext context) {
    updateViewmodelData();
    widgetFactory = AppViewmodel.getWidgetFactory(context);
    return Stack(
      children: [
        widgetFactory.createCard(
          height: MediaQuery.of(context).size.height * 0.8,
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.only(bottom: 100),
            child: Obx(() {
              return DataTable(
                columns: _buildColumns(),
                rows: _buildRows(),
              );
            }),
          ),
        ),
        Positioned(
          bottom: 0,
          left: 0,
          right: 0,
          child: widgetFactory.createButton(
            context: context,
            content: const Text('Complete Product Creation'),
            onPressed: () {
              viewModel.updateVariantsPriceInputs();
              onContinue(viewModel.variants);
            },
          ),
        ),
      ],
    );
  }

  // Build the column headers for the table
  List<DataColumn> _buildColumns() {
    return [
      const DataColumn(label: Text('Variant Name')),
      const DataColumn(label: Text('Default Price')),
      ...viewModel.branches.map((branch) => DataColumn(label: Text(branch.name.localize(AppLanguage.ENGLISH.name)))),
    ];
  }

  // Build the rows for the table (one row per variant)
  List<DataRow> _buildRows() {
    return viewModel.variants.map((variant) {
      return DataRow(
        cells: [
          // Product variant name
          DataCell(Text(variant.variantName)),

          // Default price field
          if (viewModel.priceInputOptions.isNotEmpty == true) ...[
            DataCell(
              MultiInputTextfield(
                viewmodel: viewModel.getInputViewmodelByKey(viewModel.getDefaultPriceInputKey(variant)),
                widgetFactory: widgetFactory,
                values: Map<String, String>.from(viewModel.priceInputOptions),
                selectedKey: viewModel.selectedPriceInputKey.value,
              ),
            ),

            // Price fields for each branch

            ...viewModel.branches.map((branch) {
              return DataCell(
                MultiInputTextfield(
                  viewmodel: viewModel.getInputViewmodelByKey(viewModel.getBranchPriceInputKey(variant, branch)),
                  widgetFactory: widgetFactory,
                  values: Map<String, String>.from(viewModel.priceInputOptions),
                  selectedKey: viewModel.selectedPriceInputKey.value,
                ),
              );
            }),
          ],
        ],
      );
    }).toList();
  }
}
