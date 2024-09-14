import 'package:flutter/material.dart';
import 'package:imela_admin/app/app_viewmodel.dart';
import 'package:imela_admin/ui/business_registration/viewmodel.business_registration.dart';
import 'package:imela_ui_kit/components/page_loading_utils/page_content_loader.dart';
import 'package:imela_ui_kit/widget_factory/widget.factory.dart';

class BusinessSignInPage extends StatefulWidget {
  static const routeName = '/business/signin';
  const BusinessSignInPage({super.key});

  @override
  State<BusinessSignInPage> createState() => _BusinessSignInPageState();

  static navigate(BuildContext context) {
    final router = AppViewmodel.getInstance().appRouter;
    router.navigateTo(context, routeName);
  }
}

class _BusinessSignInPageState extends State<BusinessSignInPage> {
  BusinessAuthViewmodel get viewmodel => BusinessAuthViewmodel.getInstance();
  @override
  Widget build(BuildContext context) {
    final appWidgetFactory = WidgetFactory(Theme.of(context).platform);
    return Scaffold(
      appBar: AppBar(
        title: Text('Sign in'),
      ),
      body: PageContentLoader(
        showContent: true,
        isLoading: viewmodel.isLoading.value,
        exception: viewmodel.exception.value,
        hasError: viewmodel.exception.value?.isMainError ?? false,
        content: appWidgetFactory.createCard(
          height: MediaQuery.sizeOf(context).height * 0.8,
          width: MediaQuery.sizeOf(context).width * 0.5,
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              appWidgetFactory.createText(context, 'Sign in'),
              const SizedBox(height: 16),
              appWidgetFactory.createText(context, 'Sign in with your email and password'),
              const SizedBox(height: 16),
              appWidgetFactory.createTextField(controller: viewmodel.emailController, hintText: 'Enter you email'),
              const SizedBox(height: 16),
              appWidgetFactory.createTextField(controller: viewmodel.passwordController, hintText: 'Enter you password'),
              const SizedBox(height: 16),
              appWidgetFactory.createButton(context: context, content: Text('Sign in'), onPressed: () {}),
              const Divider(),
              appWidgetFactory.createText(context, 'or'),
              const SizedBox(height: 16),
              appWidgetFactory.createButton(context: context, content: Text('Google'), onPressed: () {}),
            ],
          ),
        ),
      ),
    );
  }
}
