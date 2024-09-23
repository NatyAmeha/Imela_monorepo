import 'package:flutter/material.dart';
import 'package:imela_admin/app/app_viewmodel.dart';
import 'package:imela_admin/shared/component/multi_input_textfield.dart';
import 'package:imela_admin/ui/branch/branch_create.viewmodel.dart';
import 'package:imela_core/branch/model/branch.model.dart';
import 'package:imela_ui_kit/components/phone_input_field.dart';

class CreateBranchComponenet extends StatelessWidget {
  final Function(Branch) onCreateBranch;
  CreateBranchComponenet({super.key, required this.onCreateBranch});

  final viewmodel = BranchCreateViewmodel.getInstance();

  @override
  Widget build(BuildContext context) {
    final appWidgetFactory = AppViewmodel.getWidgetFactory(context);
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          appWidgetFactory.createText(context, 'Main information', style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 24),
          appWidgetFactory.createText(context, 'Business name', style: Theme.of(context).textTheme.titleSmall),
          MultiInputTextfield(viewmodel: viewmodel.branchNameInputViewodel, widgetFactory: appWidgetFactory, values: Map<String, String>.from(viewmodel.inputOptions), selectedKey: viewmodel.selectedInputOptionKey.value),
          const SizedBox(height: 16),
          appWidgetFactory.createText(context, 'Phone number', style: Theme.of(context).textTheme.titleSmall),
          const SizedBox(height: 16),
          PhoneInputField(
              controller: TextEditingController(),
              onChanged: (completePhoneNumber) {
                viewmodel.updatePhoneNumber(completePhoneNumber);
              }),
          if (viewmodel.showEmailInput.value) ...[
            const SizedBox(height: 16),
            appWidgetFactory.createText(context, 'Business Email', style: Theme.of(context).textTheme.titleSmall),
            appWidgetFactory.createTextField(controller: viewmodel.branchEmailController, hintText: 'Enter branch email', onChanged: (value) {}),
            const SizedBox(height: 16),
          ],
          const SizedBox(height: 16),
          appWidgetFactory.createText(context, 'Address Information', style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 24),
          appWidgetFactory.createText(context, 'City', style: Theme.of(context).textTheme.titleSmall),
          MultiInputTextfield(viewmodel: viewmodel.cityInputViewmodel, widgetFactory: appWidgetFactory, values: Map<String, String>.from(viewmodel.inputOptions), selectedKey: viewmodel.selectedInputOptionKey.value),
          const SizedBox(height: 16),
          appWidgetFactory.createText(context, 'Address', style: Theme.of(context).textTheme.titleSmall),
          MultiInputTextfield(viewmodel: viewmodel.addressInputViewmodel, widgetFactory: appWidgetFactory, values: Map<String, String>.from(viewmodel.inputOptions), selectedKey: viewmodel.selectedInputOptionKey.value),
          const SizedBox(height: 16),
          appWidgetFactory.createText(context, 'Location', style: Theme.of(context).textTheme.titleSmall),
          appWidgetFactory.createTextField(controller: viewmodel.locationController, hintText: 'Enter business location', onChanged: (value) {}),
          const SizedBox(height: 50),
          appWidgetFactory.createButton(
            context: context,
            content: const Text('Register Business'),
            onPressed: () {
              onCreateBranch(viewmodel.getBranchInfo());
            },
          ),
        ],
      ),
    );
  }
}
