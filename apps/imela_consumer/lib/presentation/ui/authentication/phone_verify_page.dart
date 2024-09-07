import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:imela/injection.dart';
import 'package:imela/presentation/ui/app_controller.dart';
import 'package:imela/presentation/ui/authentication/auth.viewmodel.dart';
import 'package:imela/presentation/ui/shared/pin_input.dart';
import 'package:imela_ui_kit/helpers/button_style.dart';
import 'package:imela_ui_kit/helpers/widget_extesions.dart';
import 'package:imela_ui_kit/widget_factory/widget.factory.dart';

class PhoneVerifyPage extends StatefulWidget {
  static const routeName = '/phone_verify';
  late AuthViewmodel? authViewmodel;

  PhoneVerifyPage({super.key, this.authViewmodel}) {
    authViewmodel ??= Get.put(getIt<AuthViewmodel>());
  }

  static void navigate(BuildContext context) {
    AppController.getInstance.router.navigateTo(context, routeName);
  }

  @override
  State<PhoneVerifyPage> createState() => _PhoneVerifyPageState();
}

class _PhoneVerifyPageState extends State<PhoneVerifyPage> {
  var inputLength = 6;
  bool get enableResendCode => !widget.authViewmodel!.isSmsCodeSent.value;

  @override
  void initState() {
    super.initState();
    widget.authViewmodel!.startResendCodeTimer();
  }

  @override
  Widget build(BuildContext context) {
    final appWidgetFactory = WidgetFactory(Theme.of(context).platform);
    return Scaffold(
      appBar: AppBar(),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          appWidgetFactory.createText(context, 'Verify Phone', style: Theme.of(context).textTheme.displaySmall),
          const SizedBox(height: 4),
          appWidgetFactory.createText(context, 'Enter the 6 digit code we sent to the number below: ', style: Theme.of(context).textTheme.labelMedium),
          const SizedBox(height: 16),
          PinInput(
            length: inputLength,
            onCompleted: (value) {
              print('Completed: $value');
              widget.authViewmodel!.updateVerifyButtonState(value);
            },
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
                  onPressed: !widget.authViewmodel!.isSmsCodeSent.value ? () {} : null,
                ),
                appWidgetFactory.createButton(
                  context: context,
                  content: const Text('Verify code'),
                  isLoading: widget.authViewmodel!.isLoading.value,
                  onPressed: widget.authViewmodel!.enableVerifyButton.value
                      ? () {
                          widget.authViewmodel!.verifySmsAndAuthenticate(context);
                        }
                      : null,
                ),
              ],
            ),
          ),
        ],
      ).withPaddingSymetric(horizontal: 16, vertical: 24),
    );
  }
}
