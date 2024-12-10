import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:imela_core/branch/model/branch.model.dart';
import 'package:imela_core/shared/localized_field.model.dart';
import 'package:imela_core/staff/model/staff_model.dart';
import 'package:imela_pos/app/app_viewmodel.dart';
import 'package:imela_pos/ui/staff/create_staff/viewmodel.create_staff.dart';

class CreateStaffPage extends StatefulWidget {
  static const routeName = '/create-staff';
  final bool showAppBar;
  final Function(Staff?)? onStaffCreated;
  const CreateStaffPage({super.key, this.showAppBar = true, this.onStaffCreated});
  @override
  State<CreateStaffPage> createState() => _CreateStaffPageState();

  static void navigate(BuildContext context) {
    final router = AppViewmodel.getInstance().appRouter;
    router.navigateTo(context, CreateStaffPage.routeName);
  }
}

class _CreateStaffPageState extends State<CreateStaffPage> {
  final CreateStaffViewModel viewModel = CreateStaffViewModel.getInstance();
  late final widgetFactory = AppViewmodel.getWidgetFactory(context);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: widget.showAppBar
          ? AppBar(
              title: widgetFactory.createText(context, 'Create Staff'),
            )
          : null,
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          mainAxisSize: MainAxisSize.min,
          children: [
            if (!widget.showAppBar) widgetFactory.createText(context, 'Create Staff', style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 16),
            Obx(
              () => widgetFactory.createDropDownBeta<Branch>(
                context,
                hintText: 'Select Branch',
                showSearch: true,
                options: viewModel.branches,
                itemBuilder: (context, item, isSelected, onItemSelect) {
                  return Text(item.name.localize(viewModel.selectedLanguage));
                },
                headerBuilder: (context, items, isSelected) {
                  return widgetFactory.createText(context, items.name.localize(viewModel.selectedLanguage), style: Theme.of(context).textTheme.labelMedium);
                },
                selectedValues: viewModel.selectedBranch.value != null ? [viewModel.selectedBranch.value!] : [],
                onChanged: (value) {
                  viewModel.setSelectedBranch(value.firstOrNull);
                },
              ),
            ),
            widgetFactory.createTextField(
              controller: viewModel.staffName,
              hintText: 'Staff Name',
              onChanged: viewModel.setStaffName,
            ),
            const SizedBox(height: 16),
            widgetFactory.createTextField(
              controller: viewModel.phoneNumber,
              hintText: 'Phone Number',
              keyboardType: TextInputType.phone,
              onChanged: (value) => viewModel.setPhoneNumber(value),
            ),
            const SizedBox(height: 16),
            widgetFactory.createTextField(
              controller: viewModel.pin,
              hintText: '4 Digit PIN',
              keyboardType: TextInputType.number,
              maxLength: 4,
              onChanged: (value) => viewModel.setPin(value),
            ),
            const Spacer(),
            Obx(
              () => widgetFactory.createButton(
                context: context,
                isLoading: viewModel.isLoading.value,
                content: widgetFactory.createText(context, 'Create Staff'),
                onPressed: viewModel.canEnableCreateButton
                    ? () => viewModel.createStaff(context, onSuccess: (staff) {
                          widget.onStaffCreated?.call(staff);
                        })
                    : null,
              ),
            ),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }
}
