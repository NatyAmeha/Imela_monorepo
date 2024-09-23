import 'package:flutter/material.dart';
import 'package:get/get_state_manager/src/rx_flutter/rx_obx_widget.dart';
import 'package:imela_admin/app/app_viewmodel.dart';
import 'package:imela_admin/shared/component/multi_input_textfield.dart';
import 'package:imela_admin/ui/product/create_product_viewmodel.dart';
import 'package:imela_core/business/model/business.section.dart';
import 'package:imela_core/shared/localized_field.model.dart';
import 'package:imela_ui_kit/components/image/image_uploader.dart';
import 'package:imela_ui_kit/helpers/button_style.dart';
import 'package:imela_utils/helpers/screen_size_utils.dart';

class MainProductInfoForm extends StatelessWidget {
  final Function onContinue;
  MainProductInfoForm({super.key, required this.onContinue});

  final viewmodel = CreateProductViewmodel.getInstance();

  @override
  Widget build(BuildContext context) {
    final widgetFactory = AppViewmodel.getWidgetFactory(context);
    return widgetFactory.createCard(
      padding: Responsive.paddingSymetric(context, largeHorizontal: 32),
      width: viewmodel.getFormWidth(context),
      child: Obx(
        () => Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          mainAxisSize: MainAxisSize.min,
          children: [
            widgetFactory.createText(context, 'Main information', style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 24),
            widgetFactory.createText(context, 'Product name', style: Theme.of(context).textTheme.titleSmall),
            MultiInputTextfield(viewmodel: viewmodel.businessNameInputViewodel, widgetFactory: widgetFactory, values: Map<String, String>.from(viewmodel.inputOptions), selectedKey: viewmodel.selectedInputOptionKey.value),
            const SizedBox(height: 24),
            widgetFactory.createText(context, 'Description', style: Theme.of(context).textTheme.titleSmall),
            MultiInputTextfield(viewmodel: viewmodel.businessDescriptionInputViewodel, widgetFactory: widgetFactory, values: Map<String, String>.from(viewmodel.inputOptions), selectedKey: viewmodel.selectedInputOptionKey.value),
            const SizedBox(height: 16),
            widgetFactory.createDropDownBeta<String>(context, options: viewmodel.allCategories.value, selectedValues: viewmodel.selectedCategories.value, showSearch: true, onChanged: (value) {
              viewmodel.updateSelectedCategories(value);
            }),
            const SizedBox(height: 16),
            widgetFactory.createText(context, 'Select sections', style: Theme.of(context).textTheme.titleSmall),
            if (viewmodel.allBusinessSections.isNotEmpty == true) ...[
              widgetFactory.createDropDownBeta(context, options: viewmodel.allBusinessSectionNames, selectedValues: viewmodel.selectedSectionNames, showSearch: true, isMultiSelection: true, onChanged: (selectedValues) {
                viewmodel.updateSelectedSections(selectedValues);
              }),
            ],
            const SizedBox(height: 16),
            widgetFactory.createButton(
                context: context,
                content: Text('Add section'),
                style: AppButtonStyle.textButtonStyle(context),
                onPressed: () {
                  viewmodel.openCreateProductSectionModal(context);
                }),
            const SizedBox(height: 24),
            ImageUploader(widgetFactory: widgetFactory, images: [], showFeaturedOption: true, height: 200),
            const SizedBox(height: 24),
            widgetFactory.createCheckboxListTile(context, title: 'Can order online', value: viewmodel.canOrderOnline.value, onChanged: (value) {
              viewmodel.updateCanOrderOnline(value);
            }),
            widgetFactory.createText(context, 'Call to action', style: Theme.of(context).textTheme.titleSmall),
            MultiInputTextfield(viewmodel: viewmodel.callToaActionInputViewodel, widgetFactory: widgetFactory, values: Map<String, String>.from(viewmodel.inputOptions), selectedKey: viewmodel.selectedInputOptionKey.value),
            const SizedBox(height: 16),
            widgetFactory.createTextField(controller: viewmodel.minOrderQtyController, hintText: 'Enter ', onChanged: (value) {}),
            const SizedBox(height: 50),
            widgetFactory.createButton(
              context: context,
              content: const Text('Continue'),
              onPressed: () {
                onContinue();
              },
            ),
          ],
        ),
      ),
    );
  }
}
