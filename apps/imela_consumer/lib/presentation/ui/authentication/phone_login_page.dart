import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:imela/injection.dart';
import 'package:imela/presentation/ui/app_controller.dart';
import 'package:imela/presentation/ui/authentication/auth.viewmodel.dart';
import 'package:imela/services/routing_service.dart';
import 'package:imela_ui_kit/helpers/button_style.dart';
import 'package:imela_ui_kit/helpers/widget_extesions.dart';
import 'package:intl_phone_field/intl_phone_field.dart';

class PhoneLoginPage extends StatelessWidget {
  static const routeName = '/phone_login';
  late AuthViewmodel? authViewmodel;

  PhoneLoginPage({super.key, this.authViewmodel}) {
    authViewmodel ??= Get.put(getIt<AuthViewmodel>());
  }

  static void navigate(BuildContext context, IRoutingService router) {
    router.navigateTo(context, routeName);
  }

  @override
  Widget build(BuildContext context) {
    final appWidgetFactory = AppController.getInstance.getWidgetFactory(context);
    return Scaffold(
      appBar: AppBar(),
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            appWidgetFactory.createText(context, 'Login with your phone', style: Theme.of(context).textTheme.displaySmall),
            const SizedBox(height: 4),
            appWidgetFactory.createText(context, 'Enter your phone number in order to get started with your profile creation.', style: Theme.of(context).textTheme.labelMedium),
            const SizedBox(height: 16),
            IntlPhoneField(
              decoration: InputDecoration(
                hintText: '910112233',
                hintStyle: Theme.of(context).textTheme.labelLarge?.copyWith(color: Colors.grey),
                border: const OutlineInputBorder(
                  borderSide: BorderSide(),
                ),
              ),
              initialCountryCode: 'ET',
              onChanged: (phone) {

                authViewmodel!.updatePhoneNumber(phone);
              },
              autofocus: true,
            ),
            const Spacer(),
            Obx(
              () => Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  appWidgetFactory.createButton(
                    context: context,
                    content: const Text('Resend code'),
                    style: AppButtonStyle.textButtonStyle(context),
                    onPressed: () {},
                  ),
                  Expanded(
                    child: appWidgetFactory.createButton(
                      context: context,
                      isLoading: authViewmodel!.isLoading.value,
                      content: const Text('Send code'),
                      onPressed: authViewmodel!.isPhoneNumberValid.value
                          ? () {
                              authViewmodel!.handlePhoneAuthentication(context);
                            }
                          : null,
                    ),
                  ),
                ],
              ),
            )
          ],
        ).withPaddingSymetric(horizontal: 16, vertical: 24),
      ),
    );
  }
}
