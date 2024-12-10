import 'package:flutter/material.dart';
import 'package:imela_ui_kit/components/phone_input_field.dart';
import 'package:imela_ui_kit/widget_factory/widget.factory.dart';
import 'package:imela_utils/helpers/screen_size_utils.dart';

class CreateCustomerForm extends StatefulWidget {
  final Function(BuildContext context, String firstName, String phoneNumber, String email) onCreateCustomer;
  final WidgetFactory widgetFactory;
  final double height;
  final bool isLoading;
  final bool showEmail;

  const CreateCustomerForm({
    super.key,
    required this.onCreateCustomer,
    required this.widgetFactory,
    this.height = 400,
    this.isLoading = false,
    this.showEmail = true,
  });

  @override
  State<CreateCustomerForm> createState() => _CreateCustomerFormState();
}

class _CreateCustomerFormState extends State<CreateCustomerForm> {
  final TextEditingController _firstNameController = TextEditingController();
  final TextEditingController _phoneNumberController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();

  bool get enableCreateButton => _firstNameController.text.isNotEmpty && _phoneNumberController.text.isNotEmpty;

  @override
  Widget build(BuildContext context) {
    return widget.widgetFactory.createCard(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          widget.widgetFactory.createText(context, 'Create Customer', style: Theme.of(context).textTheme.titleMedium),
          SizedBox(height: Responsive.isSmallScreen(context) ? 16 : 24),

          widget.widgetFactory.createTextField(
            controller: _firstNameController,
            hintText: 'First Name',
            onChanged: (value) {
              setState(() {});
            },
          ),
          const SizedBox(height: 24),
          PhoneInputField(
            controller: _phoneNumberController,
            onChanged: (value) {
              setState(() {});
            },
          ),
          if (widget.showEmail)
            widget.widgetFactory.createTextField(
              controller: _emailController,
              hintText: 'Email',
              keyboardType: TextInputType.emailAddress,
              onChanged: (value) {
                setState(() {});
              },
            ),
          // const Spacer(),
          const SizedBox(height: 32),
          widget.widgetFactory.createButton(
            context: context,
            content: const Text('Create Customer'),
            isLoading: widget.isLoading,
            onPressed: enableCreateButton
                ? () {
                    widget.onCreateCustomer(
                      context,
                      _firstNameController.text,
                      _phoneNumberController.text,
                      _emailController.text,
                    );
                  }
                : null,
          ),
          const SizedBox(height: 30),
        ],
      ),
    );
  }
}
