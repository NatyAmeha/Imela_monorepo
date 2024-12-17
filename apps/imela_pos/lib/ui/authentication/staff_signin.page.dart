import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:imela_core/branch/model/branch.model.dart';
import 'package:imela_core/shared/localized_field.model.dart';
import 'package:imela_pos/app/app_viewmodel.dart';
import 'package:imela_pos/ui/authentication/staff_signin.viewmodel.dart';
import 'package:imela_pos/ui/authentication/workspace_auth/workspace_auth.dart';
import 'package:imela_ui_kit/components/page_loading_utils/page_content_loader.dart';
import 'package:imela_ui_kit/components/phone_input_field.dart';
import 'package:imela_utils/helpers/screen_size_utils.dart';

class POSStaffSignInPage extends StatefulWidget {
  static const routeName = '/pos/signin';
  const POSStaffSignInPage({super.key});

  @override
  State<POSStaffSignInPage> createState() => _POSStaffSignInPageState();

  static void navigate(BuildContext context, {bool replaceRoute = false}) {
    final router = AppViewmodel.getInstance().appRouter;
    router.navigateTo(context, routeName, replace: replaceRoute);
  }
}

class _POSStaffSignInPageState extends State<POSStaffSignInPage> {
  StaffAuthViewmodel get viewmodel => StaffAuthViewmodel.getInstance();

  @override
  void initState() {
    super.initState();
    viewmodel.initViewmodel(data: {'context': context});
  }

  @override
  Widget build(BuildContext context) {
    final appWidgetFactory = AppViewmodel.getWidgetFactory(context);
    return Scaffold(
      appBar: AppBar(
        title: const Text('Staff Sign in'),
        leading: IconButton(
          onPressed: () {
            WorkspaceAuth.navigate(context, replace: true);
          },
          icon: const Icon(Icons.arrow_back),
        ),
      ),
      body: PageContentLoader(
        showContent: true,
        isLoading: viewmodel.isLoading.value,
        exception: viewmodel.exception.value,
        hasError: viewmodel.exception.value?.isMainError ?? false,
        content: Stack(
          children: [
            Positioned(
              top: 0,
              child: appWidgetFactory.createCard(
                margin: Responsive.paddingSymetric(context, smallHorizontal: 0, smallVertical: 0),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Theme.of(context).colorScheme.primaryContainer),
                height: Responsive.getHeight(context, small: 200, large: 400), // viewmodel.signupHeaderCard(context),
                color: Theme.of(context).colorScheme.primary,
                width: MediaQuery.sizeOf(context).width,
                child: const SizedBox(),
              ),
            ),
            Center(
              child: appWidgetFactory.createCard(
                borderRadius: BorderRadius.circular(16),
                elevation: 8,
                border: Border.all(color: Theme.of(context).colorScheme.primaryContainer),
                color: Theme.of(context).scaffoldBackgroundColor,
                height: MediaQuery.sizeOf(context).height * 0.7,
                width: viewmodel.getFormWidth(context),
                padding: const EdgeInsets.all(32),
                margin: Responsive.paddingSymetric(context),
                child: Obx(
                  () => SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      mainAxisAlignment: MainAxisAlignment.center,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        appWidgetFactory.createText(context, 'Staff Sign in', style: Theme.of(context).textTheme.titleLarge),
                        appWidgetFactory.createCheckboxListTile(
                          context,
                          title: 'Are you Admin?',
                          value: viewmodel.isAdmin.value,
                          onChanged: (value) {
                            viewmodel.setIsAdmin(value);
                          },
                        ),
                        const Divider(height: 24, color: Colors.grey),
                        appWidgetFactory.createText(context, 'Enter your phone number and pin to sign in. Ask your manager for your pin if you do not know it.', style: Theme.of(context).textTheme.labelMedium),
                        if (viewmodel.isAdmin.value) ...[
                          const SizedBox(height: 16),
                          appWidgetFactory.createDropDownBeta<Branch>(
                            context,
                            hintText: 'Select Branch',
                            showSearch: true,
                            options: viewmodel.appviewmodel.businessBranches,
                            itemBuilder: (context, item, isSelected, onItemSelect) {
                              return Text(item.name.localize(viewmodel.appviewmodel.selectedLanguage));
                            },
                            headerBuilder: (context, items, isSelected) {
                              return appWidgetFactory.createText(context, items.name.localize(viewmodel.appviewmodel.selectedLanguage), style: Theme.of(context).textTheme.labelMedium);
                            },
                            selectedValues: [],
                            onChanged: (value) {
                              viewmodel.setSelectedBranch(value);
                            },
                          ),
                        ],
                        const SizedBox(height: 16),
                        const SizedBox(height: 16),
                        Obx(
                          () => PhoneInputField(
                            controller: viewmodel.phoneNumberController.value,
                            autoFocus: true,
                            onChanged: (value) {
                              viewmodel.checkInputValidity();
                            },
                          ),
                        ),
                        if (!viewmodel.isAdmin.value) ...[
                          const SizedBox(height: 16),
                          appWidgetFactory.createTextField(
                            controller: viewmodel.pinController.value,
                            hintText: 'Enter you pin',
                            onChanged: (value) {
                              viewmodel.checkInputValidity();
                            },
                          ),
                        ],
                        const SizedBox(height: 40),
                        Obx(
                          () => appWidgetFactory.createButton(
                            context: context,
                            content: Text(viewmodel.isAdmin.value ? 'Sign in as Admin' : 'Sign in'),
                            isLoading: viewmodel.isLoading.value,
                            onPressed: viewmodel.isInputValid.value
                                ? () {
                                    viewmodel.handleSignIn(context);
                                  }
                                : null,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
