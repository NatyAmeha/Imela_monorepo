import 'package:flutter/material.dart';
import 'package:pin_code_fields/pin_code_fields.dart';

class PinInput extends StatelessWidget {
  final int length;
  final TextEditingController? controller;
  final Function? onCompleted;
  final bool obscureText;
  final double inputWidth;
  final double inputHeight;
  const PinInput({super.key, this.length = 6, this.controller, this.onCompleted, this.obscureText = false, this.inputHeight = 50, this.inputWidth = 50});

  @override
  Widget build(BuildContext context) {
    return PinCodeTextField(
      appContext: context,
      focusNode: FocusNode(),
      pastedTextStyle: TextStyle(color: Colors.green.shade600, fontWeight: FontWeight.bold),
      length: length,
      obscureText: obscureText,
      obscuringCharacter: '*',
      blinkWhenObscuring: true,
      animationType: AnimationType.fade,
      pinTheme: PinTheme(
        shape: PinCodeFieldShape.box,
        borderRadius: BorderRadius.circular(5),
        fieldHeight: inputHeight,
        fieldWidth: inputWidth,
        activeFillColor: Colors.white,
      ),
      cursorColor: Colors.black,
      animationDuration: const Duration(milliseconds: 300),
      controller: controller,
      keyboardType: TextInputType.number,
      onCompleted: (v) {
        onCompleted?.call();
      },
      // onTap: () {
      //   print("Pressed");
      // },
      onChanged: (value) {},
      beforeTextPaste: (text) {
        return true;
      },
    );
  }
}
