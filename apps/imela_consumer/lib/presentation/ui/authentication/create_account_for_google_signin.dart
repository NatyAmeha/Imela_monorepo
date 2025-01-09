import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:imela/presentation/ui/app_controller.dart';
import 'package:imela/presentation/ui/authentication/auth.viewmodel.dart';
import 'package:imela_core/user/model/user.model.dart';
import 'package:imela_ui_kit/components/image/app_image.dart';
import 'package:imela_ui_kit/components/page_loading_utils/page_content_loader.dart';
import 'package:imela_ui_kit/components/phone_input_field.dart';
import 'package:imela_ui_kit/widget_factory/widget.factory.dart';
import 'dart:convert';

class CreateAccountForGoogleSignin extends StatefulWidget {
  static const routeName = '/create-account-google';
  static const GOOGLE_USER_KEY = 'googleUser';

  final User googleUser;

  const CreateAccountForGoogleSignin({super.key, required this.googleUser});

  @override
  State<CreateAccountForGoogleSignin> createState() => _CreateAccountForGoogleSigninState();

  static void navigate(BuildContext context, User googleUser) {
    final router = AppController.getInstance.router;
    final googleUserString = jsonEncode(googleUser.toJson());
    router.navigateTo(context, routeName, extra: {GOOGLE_USER_KEY: Uri.encodeComponent(googleUserString)});
  }
}

class _CreateAccountForGoogleSigninState extends State<CreateAccountForGoogleSignin> {
  late WidgetFactory widgetFactory;
  var authViewmodel = AuthViewmodel.getInstance();

  @override
  void initState() {
    super.initState();
    widgetFactory = AppController.getInstance.getWidgetFactory(context);
    authViewmodel.initializeTextFields(widget.googleUser);
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvoked: (didPop) {
        authViewmodel.showWarningAlertDialog(context);
      },
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Create Account'),
          automaticallyImplyLeading: false,
          actions: [
            IconButton(
              onPressed: () {
                authViewmodel.showWarningAlertDialog(context);
              },
              icon: const Icon(Icons.close),
            ),
          ],
        ),
        body: Obx(
          () => PageContentLoader(
            isLoading: authViewmodel.isLoading.value,
            showContent: true,
            content: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const SizedBox(height: 24),
                  CircleAvatar(
                    radius: 50,
                    child: AppImage(imageUrl: widget.googleUser.profileImageUrl, width: 100, height: 100, fit: BoxFit.cover, borderRadius: BorderRadius.circular(50)),
                  ),
                  const SizedBox(height: 24),
                  widgetFactory.createTextField(
                    controller: authViewmodel.firstNameController,
                    hintText: 'Your Name',
                    onChanged: (value) {
                      authViewmodel.checkInputValidity();
                    },
                  ),
                  const SizedBox(height: 32),
                  PhoneInputField(
                    controller: authViewmodel.phoneNumberController,
                    onChanged: (value) {
                      authViewmodel.phoneNumber.value = value;
                      authViewmodel.checkInputValidity();
                    },
                  ),
                  widgetFactory.createTextField(
                      controller: authViewmodel.emailController,
                      hintText: 'Email (optional)',
                      onChanged: (value) {
                        authViewmodel.checkInputValidity();
                      }),
                  const SizedBox(height: 60),
                  Obx(
                    () => widgetFactory.createButton(
                      context: context,
                      content: const Text('Create Account'),
                      isLoading: authViewmodel.isLoading.value,
                      onPressed: !authViewmodel.isLoading.value && authViewmodel.isInputValid.value
                          ? () {
                              authViewmodel.registerUser(context);
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
    );
  }
}
