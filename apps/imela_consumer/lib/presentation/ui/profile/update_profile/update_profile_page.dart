import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:imela/presentation/ui/app_controller.dart';
import 'package:imela/presentation/ui/profile/update_profile/update_profile.viewmodel.dart';
import 'package:imela_ui_kit/components/page_loading_utils/page_content_loader.dart';
import 'package:imela_ui_kit/widget_factory/widget.factory.dart';

class UpdateProfilePage extends StatefulWidget {
  static const routeName = '/update-profile';
  static const REDIRECT_URL_KEY = 'redirectUrl';
  static const REDIRECT_EXTRA_KEY = 'redirectExtra';
  static const PAGE_TITLE_KEY = 'pageTitle';
  final String? redirectUrl;
  final Map<String, dynamic>? redirectExtra;
  final String? pageTitle;
  const UpdateProfilePage({super.key, this.redirectUrl, this.redirectExtra, this.pageTitle});

  @override
  State<UpdateProfilePage> createState() => _UpdateProfilePageState();

  static void navigate(BuildContext context, {String? redirectUrl, String? pageTitle, Map<String, dynamic>? redirectExtra}) {
    final router = AppController.getInstance.router;
    router.navigateTo(context, routeName, extra: {REDIRECT_URL_KEY: redirectUrl, REDIRECT_EXTRA_KEY: redirectExtra, PAGE_TITLE_KEY: pageTitle});
  }

  static void handleRedirect(BuildContext context, String redirectUrl, Map<String, dynamic>? redirectExtra) {
    final router = AppController.getInstance.router;
    router.navigateTo(context, redirectUrl, extra: redirectExtra);
  }
}

class _UpdateProfilePageState extends State<UpdateProfilePage> {
  var viewmodel = UpdateProfileViewmodel.getInstance();
  late WidgetFactory widgetFactory;

  @override
  void initState() {
    super.initState();
    widgetFactory = AppController.getInstance.getWidgetFactory(context);
    viewmodel.initViewmodel(data: {UpdateProfilePage.REDIRECT_URL_KEY: widget.redirectUrl, UpdateProfilePage.REDIRECT_EXTRA_KEY: widget.redirectExtra});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.pageTitle ?? 'Update Profile')),
      body: Obx(
        () => PageContentLoader(
          isLoading: viewmodel.isLoading.value,
          showContent: true,
          onTryAgain: () => viewmodel.updateProfile(context),
          content: Stack(
            children: [
              Positioned.fill(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
                  child: Column(
                    children: [
                      widgetFactory.createTextField(
                          controller: viewmodel.firstNameController.value,
                          hintText: 'First Name',
                          validator: (p0) {
                            return viewmodel.validateFirstName();
                          },
                          onChanged: (p0) {
                            setState(() {
                              viewmodel.validateFirstName();
                            });
                          }),
                      const SizedBox(height: 16),
                      widgetFactory.createTextField(controller: viewmodel.emailController, hintText: 'Email (optional)'),
                      const SizedBox(height: 50),
                    ],
                  ),
                ),
              ),
              Positioned(
                bottom: 16,
                left: 16,
                right: 16,
                child: Obx(
                  () => widgetFactory.createButton(
                    context: context,
                    isLoading: viewmodel.isLoading.value,
                    content: const Text('Update profile'),
                    onPressed: viewmodel.firstNameController.value.text.isNotEmpty ? () => viewmodel.updateProfile(context) : null,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
