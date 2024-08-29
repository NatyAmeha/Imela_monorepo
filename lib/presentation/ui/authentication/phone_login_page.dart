import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:imela/data/network/graphql_config.dart';
import 'package:imela/presentation/ui/authentication/auth.viewmodel.dart';
import 'package:imela/presentation/ui/factory/widget.factory.dart';
import 'package:imela/presentation/utils/button_style.dart';
import 'package:imela/presentation/utils/widget_extesions.dart';
import 'package:imela/services/routing_service.dart';

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
    final appWidgetFactory = WidgetFactory(Theme.of(context).platform);
    return Scaffold(
      appBar: AppBar(),
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            appWidgetFactory.createText(context, "Login with your phone", style: Theme.of(context).textTheme.displaySmall),
            const SizedBox(height: 4),
            appWidgetFactory.createText(context, "Enter your phone number in order to get started with your profile creation.", style: Theme.of(context).textTheme.labelMedium),
            const SizedBox(height: 16),
            appWidgetFactory.createTextField(
              controller: authViewmodel!.phoneController,
              hintText: 'Phone number',
              onChanged: (value) {},
            ),
            const Spacer(),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                appWidgetFactory.createButton(
                  context: context,
                  content: const Text('Resend code'),
                  style: AppButtonStyle.textButtonStyle(context),
                  onPressed: () {},
                ),
                Expanded(
                  child: appWidgetFactory.createButton(context: context, content: const Text('Send code'), onPressed: () {
                    authViewmodel!.navigateToPhoneVerifyPage(context);
                  }),
                ),
              ],
            )
          ],
        ).withPaddingSymetric(horizontal: 16, vertical: 24),
      ),
    );
  }
}
