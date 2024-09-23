import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:imela_admin/app/app_viewmodel.dart';
import 'package:imela_admin/ui/business_registration/auth.viewmodel.dart';
import 'package:imela_ui_kit/components/page_loading_utils/page_content_loader.dart';
import 'package:imela_ui_kit/helpers/button_style.dart';
import 'package:imela_ui_kit/widget_factory/widget.factory.dart';
import 'package:imela_utils/helpers/screen_size_utils.dart';

class BusinessSignupPage extends StatefulWidget {
  static const routeName = '/business/signup';
  const BusinessSignupPage({super.key});

  @override
  State<BusinessSignupPage> createState() => _BusinessSignupPageState();

  static void navigate(BuildContext context, {bool replaceRoute = false}) {
    final router = AppViewmodel.getInstance().appRouter;
    router.navigateTo(context, routeName, replace: replaceRoute);
  }
}

class _BusinessSignupPageState extends State<BusinessSignupPage> {
  BusinessAuthViewmodel get viewmodel => BusinessAuthViewmodel.getInstance();

  @override
  void initState() {
    // TODO: implement initState
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
                // height: MediaQuery.sizeOf(context).height * 0.7,
                width: viewmodel.signupFormWidth(context),
                padding: const EdgeInsets.all(32),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    appWidgetFactory.createText(context, 'Sign up', style: Theme.of(context).textTheme.titleLarge),
                    const SizedBox(height: 8),
                    appWidgetFactory.createText(context, 'Regisster with you email', style: Theme.of(context).textTheme.labelMedium),
                    const SizedBox(height: 16),
                    appWidgetFactory.createTextField(controller: viewmodel.firstNameController, hintText: 'Enter you First name'),
                    const SizedBox(height: 16),
                    appWidgetFactory.createTextField(controller: viewmodel.emailController, hintText: 'Enter you email'),
                    const SizedBox(height: 16),
                    appWidgetFactory.createTextField(controller: viewmodel.passwordController, hintText: 'Enter you password'),
                    const SizedBox(height: 40),
                    Obx(
                      () => appWidgetFactory.createButton(
                          context: context,
                          content: const Text('Sign up'),
                          isLoading: viewmodel.isLoading.value,
                          onPressed: () {
                            viewmodel.registerWithEmail(context);
                          }),
                    ),
                    const Divider(),
                    appWidgetFactory.createText(context, 'or', textAlign: TextAlign.center),
                    const SizedBox(height: 16),
                    appWidgetFactory.createButton(context: context, content: const Text('Google'), onPressed: () {}),
                    const SizedBox(height: 40),
                    appWidgetFactory.createText(context, 'Already have an account?'),
                    appWidgetFactory.createButton(
                        context: context,
                        content: const Text('Sign in'),
                        style: AppButtonStyle.textButtonStyle(context),
                        onPressed: () {
                          viewmodel.navigateToSigninPage(context);
                        }),
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
