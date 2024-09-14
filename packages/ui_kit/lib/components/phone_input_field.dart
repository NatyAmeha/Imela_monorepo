import 'package:flutter/material.dart';
import 'package:intl_phone_field/intl_phone_field.dart';

class PhoneInputField extends StatelessWidget {
  final TextEditingController controller;
  final bool autoFocus;
  final Function(String) onChanged;
  const PhoneInputField({super.key, required this.controller, this.autoFocus = false, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return IntlPhoneField(
      decoration: InputDecoration(
        hintText: '910112233',
        hintStyle: Theme.of(context).textTheme.labelLarge?.copyWith(color: Colors.grey),
        border: const OutlineInputBorder(
          borderSide: BorderSide(),
        ),
      ),
      controller: controller,
      initialCountryCode: 'ET',
      onChanged: (phone) {
        onChanged?.call(phone.completeNumber);
      },
      autofocus: autoFocus,
    );
  }
}
