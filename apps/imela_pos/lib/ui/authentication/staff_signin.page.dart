import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:imela_pos/app/app_viewmodel.dart';
import 'package:imela_pos/ui/authentication/staff_signin.viewmodel.dart';
import 'package:imela_ui_kit/components/page_loading_utils/page_content_loader.dart';
import 'package:imela_ui_kit/widget_factory/widget.factory.dart';
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
    final appWidgetFactory = WidgetFactory(Theme.of(context).platform);
    return Scaffold(
      body: PageContentLoader(
        showContent: true,
        isLoading: viewmodel.isLoading.value,
        exception: viewmodel.exception.value,
        hasError: viewmodel.exception.value?.isMainError ?? false,
        content: Stack(
          children: [
            Positioned(
              child: appWidgetFactory.createCard(
                margin: Responsive.paddingSymetric(context, smallHorizontal: 0, smallVertical: 0),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Theme.of(context).colorScheme.primaryContainer),
                height: 200, // viewmodel.signupHeaderCard(context),
                color: Theme.of(context).colorScheme.primaryContainer,
                width: MediaQuery.sizeOf(context).width,
                child: const SizedBox(),
              ),
            ),
            Center(
              child: appWidgetFactory.createCard(
                elevation: 40,
                color: Theme.of(context).colorScheme.secondaryContainer,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Theme.of(context).primaryColor),
                height: MediaQuery.sizeOf(context).height * 0.7,
                width: viewmodel.getFormWidth(context),
                padding: const EdgeInsets.all(32),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  mainAxisAlignment: MainAxisAlignment.center,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    appWidgetFactory.createText(context, 'Staff Sign in', style: Theme.of(context).textTheme.titleLarge),
                    const SizedBox(height: 8),
                    appWidgetFactory.createText(context, 'Enter your phone number and pin to sign in. Ask your manager for your pin if you do not know it.', style: Theme.of(context).textTheme.labelMedium),
                    const SizedBox(height: 16),
                    appWidgetFactory.createTextField(controller: viewmodel.phoneNumberController, hintText: 'Enter you phone number (e.g. +251912345678)'),
                    const SizedBox(height: 16),
                    appWidgetFactory.createTextField(controller: viewmodel.pinController, hintText: 'Enter you pin'),
                    const SizedBox(height: 40),
                    Obx(
                      () => appWidgetFactory.createButton(
                        context: context,
                        content: const Text('Sign in'),
                        isLoading: viewmodel.isLoading.value,
                        onPressed: () {
                          viewmodel.signInStaff(context);
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
