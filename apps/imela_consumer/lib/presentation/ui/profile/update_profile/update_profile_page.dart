import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:imela/presentation/ui/app_controller.dart';
import 'package:imela/presentation/ui/profile/update_profile/update_profile.viewmodel.dart';
import 'package:imela/presentation/ui/shared/page_loading_utils/page_content_loader.dart';
import 'package:imela_ui_kit/widget_factory/widget.factory.dart';

class UpdateProfilePage extends StatefulWidget {
  static const routeName = '/update-profile';
  static const REDIRECT_URL_KEY = 'redirectUrl';
  static const REDIRECT_EXTRA_KEY = 'redirectExtra';
  final String redirectUrl;
  final Map<String, dynamic>? redirectExtra;

  const UpdateProfilePage({super.key, required this.redirectUrl, this.redirectExtra});

  @override
  State<UpdateProfilePage> createState() => _UpdateProfilePageState();

  static void navigate(BuildContext context, {required String redirectUrl, Map<String, dynamic>? redirectExtra}) {
    final router = AppController.getInstance.router;
    router.navigateTo(context, routeName, extra: {REDIRECT_URL_KEY: redirectUrl, REDIRECT_EXTRA_KEY: redirectExtra});
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
      appBar: AppBar(title: const Text('Update Profile')),
      body: Obx(
        () => PageContentLoader(
          isDataLoading: viewmodel.isLoading.value,
          showContent: true,
          onTryAgain: () => viewmodel.updateProfile(context),
          content: Stack(
            children: [
              Positioned.fill(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Column(
                    children: [
                      widgetFactory.createTextField(
                        controller: viewmodel.firstNameController,
                        hintText: 'First Name',
                        validator: (p0) {
                          return viewmodel.validateFirstName();
                        },
                      ),
                      widgetFactory.createTextField(controller: viewmodel.lastNameController, hintText: 'Last Name'),
                      widgetFactory.createTextField(controller: viewmodel.emailController, hintText: 'Email'),
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
                    onPressed: () => viewmodel.updateProfile(context),
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
