import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:get/get_state_manager/src/rx_flutter/rx_obx_widget.dart';
import 'package:imela_admin/app/app_viewmodel.dart';
import 'package:imela_admin/shared/component/multi_input_textfield.dart';
import 'package:imela_admin/ui/product/product_section/create_product_section.viewmodel.dart';
import 'package:imela_core/business/model/business.section.dart';
import 'package:imela_ui_kit/widget_factory/widget.factory.dart';

class SmallScreenProductSectionCreatePage extends StatelessWidget {
  final Function(List<BusinessSection>) onSectionCreateFinished;
  SmallScreenProductSectionCreatePage({super.key, required this.onSectionCreateFinished});

  static ProductSectionViewmodel viewmodel = ProductSectionViewmodel.getInstance();
  late WidgetFactory widgetFactory;

  @override
  Widget build(BuildContext context) {
    widgetFactory = AppViewmodel.getWidgetFactory(context);
    return Obx(
      () => SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            widgetFactory.createText(context, 'Product section', style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 24),
            widgetFactory.createText(context, 'Section name', style: Theme.of(context).textTheme.titleSmall),
            MultiInputTextfield(viewmodel: viewmodel.sectionNameInputViewodel, widgetFactory: widgetFactory, values: Map<String, String>.from(viewmodel.inputOptions), selectedKey: viewmodel.selectedInputOptionKey.value),
            const SizedBox(height: 16),
            widgetFactory.createText(context, 'Section description', style: Theme.of(context).textTheme.titleSmall),
            const SizedBox(height: 8),
            MultiInputTextfield(viewmodel: viewmodel.sectionDescriptionInputViewodel, widgetFactory: widgetFactory, values: Map<String, String>.from(viewmodel.inputOptions), selectedKey: viewmodel.selectedInputOptionKey.value),
            const SizedBox(height: 32),
            widgetFactory.createButton(
                context: context,
                content: Text("Create Productd section"),
                isLoading:  viewmodel.isLoading.value,
                onPressed: () {
                  viewmodel.createSection(context, onSectionCreateFinished);
                }),
          ],
        ),
      ),
    );
  }
}
