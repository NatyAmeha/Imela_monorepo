import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:imela/injection.dart';
import 'package:imela/presentation/ui/authentication/auth.viewmodel.dart';
import 'package:imela/presentation/ui/factory/widget.factory.dart';
import 'package:imela/presentation/ui/shared/pin_input.dart';
import 'package:imela/presentation/utils/button_style.dart';
import 'package:imela/presentation/utils/widget_extesions.dart';
import 'package:imela/services/routing_service.dart';

class PhoneVerifyPage extends StatelessWidget {
  static const routeName = '/phone_verify';
  late AuthViewmodel? authViewmodel;

  PhoneVerifyPage({super.key, this.authViewmodel}) {
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
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          appWidgetFactory.createText(context, "Verify Phone", style: Theme.of(context).textTheme.displaySmall),
          const SizedBox(height: 4),
          appWidgetFactory.createText(context, "Enter the 6 digit code we sent to the number below: ", style: Theme.of(context).textTheme.labelMedium),
          const SizedBox(height: 16),
          PinInput(
            length: 6,
            // controller: authViewmodel!.verifyPinController,
            onCompleted: (value) {},
          ),
          const Spacer(),
          appWidgetFactory.createButton(
            context: context,
            content: const Text('Verify code'),
            onPressed: () {},
          ), 
        ],
      ).withPaddingSymetric(horizontal: 16, vertical: 24),
    );
  }
}
