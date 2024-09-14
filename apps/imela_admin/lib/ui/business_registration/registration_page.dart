import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:imela_admin/app/app_viewmodel.dart';
import 'package:imela_admin/resources/values.dart';
import 'package:imela_admin/shared/component/multi_input_textfield.dart';
import 'package:imela_admin/ui/business_registration/business_registration_viewmodel.dart';
import 'package:imela_ui_kit/components/image/image_uploader.dart';
import 'package:imela_ui_kit/components/page_loading_utils/page_content_loader.dart';
import 'package:imela_ui_kit/components/phone_input_field.dart';
import 'package:imela_ui_kit/widget_factory/widget.factory.dart';

class BusinessRegistrationPage extends StatefulWidget {
  static const routeName = '/business/registration';
  const BusinessRegistrationPage({super.key});

  @override
  State<BusinessRegistrationPage> createState() => _BusinessRegistrationPageState();

  static void navigate(BuildContext context) {
    final router = AppViewmodel.getInstance().appRouter;
    router.navigateTo(context, routeName);
  }
}

class _BusinessRegistrationPageState extends State<BusinessRegistrationPage> {
  BusinessRegistrationViewmodel get viewmodel => BusinessRegistrationViewmodel.getInstance();
  @override
  Widget build(BuildContext context) {
    final appWidgetFactory = WidgetFactory(Theme.of(context).platform);
    return Scaffold(
      appBar: AppBar(
        title: const Text('Register Business'),
      ),
      body: Obx(
        () => PageContentLoader(
          showContent: true,
          isLoading: viewmodel.isLoading.value,
          exception: viewmodel.exception.value,
          hasError: viewmodel.exception.value?.isMainError ?? false,
          content: SingleChildScrollView(
            child: Column(
              children: [
                Center(
                  child: appWidgetFactory.createCard(
                    elevation: 40,
                    color: Theme.of(context).colorScheme.secondaryContainer,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: Theme.of(context).colorScheme.primaryContainer),
                    width: viewmodel.getFormWidth(context),
                    padding: const EdgeInsets.all(32),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        appWidgetFactory.createText(context, 'Main information', style: Theme.of(context).textTheme.titleMedium),
                        const SizedBox(height: 24),
                        appWidgetFactory.createText(context, 'Business name', style: Theme.of(context).textTheme.titleSmall),
                        MultiInputTextfield(viewmodel: viewmodel.businessNameInputViewodel, widgetFactory: appWidgetFactory, values: viewmodel.businessName, selectedKey: viewmodel.selectedBusienssNameKey.value),
                        const SizedBox(height: 16),
                        appWidgetFactory.createText(context, 'Business Description', style: Theme.of(context).textTheme.titleSmall),
                        MultiInputTextfield(viewmodel: viewmodel.businessDescriptionInputViewodel, widgetFactory: appWidgetFactory, values: viewmodel.businessDescription, selectedKey: viewmodel.selectedBusienssDescriptionKey.value),
                        const SizedBox(height: 16),
                        appWidgetFactory.createText(context, 'Phone number', style: Theme.of(context).textTheme.titleSmall),
                        PhoneInputField(
                          controller: viewmodel.phoneNumberController,
                          onChanged: (p0) {},
                        ),
                        if (viewmodel.showEmailInput.value) ...[
                          const SizedBox(height: 16),
                          appWidgetFactory.createText(context, 'Email', style: Theme.of(context).textTheme.titleSmall),
                          MultiInputTextfield(viewmodel: viewmodel.businessEmailInputViewodel, widgetFactory: appWidgetFactory, values: viewmodel.businessDescription, selectedKey: viewmodel.selectedBusienssDescriptionKey.value),
                        ],
                        const SizedBox(height: 24),
                        appWidgetFactory.createText(context, 'Images', style: Theme.of(context).textTheme.titleSmall),
                        const SizedBox(height: 16),
                        ImageUploader(widgetFactory: appWidgetFactory, images: [], showFeaturedOption: true, height: 200),
                        const SizedBox(height: 24),
                        appWidgetFactory.createDropDownBeta<String>(context, options: categories, selectedValue: categories.first, showSearch: true, onChanged: (value) {}),
                        const SizedBox(height: 40),
                        appWidgetFactory.createText(context, 'Address Information', style: Theme.of(context).textTheme.titleMedium),
                        const SizedBox(height: 24),
                        appWidgetFactory.createText(context, 'City', style: Theme.of(context).textTheme.titleSmall),
                        MultiInputTextfield(viewmodel: viewmodel.cityInputViewmodel, widgetFactory: appWidgetFactory, values: viewmodel.businessName, selectedKey: viewmodel.selectedBusienssNameKey.value),
                        const SizedBox(height: 16),
                        appWidgetFactory.createText(context, 'Address', style: Theme.of(context).textTheme.titleSmall),
                        MultiInputTextfield(viewmodel: viewmodel.addressInputViewmodel, widgetFactory: appWidgetFactory, values: viewmodel.businessName, selectedKey: viewmodel.selectedBusienssNameKey.value),
                        const SizedBox(height: 16),
                        appWidgetFactory.createText(context, 'Location', style: Theme.of(context).textTheme.titleSmall),
                        MultiInputTextfield(viewmodel: viewmodel.locationInputViewmodel, widgetFactory: appWidgetFactory, values: viewmodel.businessName, selectedKey: viewmodel.selectedBusienssNameKey.value),
                        const SizedBox(height: 50),
                        appWidgetFactory.createButton(
                          context: context,
                          content: const Text('Register Business'),
                          onPressed: () {
                            viewmodel.registerBusiness(context);
                          },
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
