import 'package:flutter/material.dart';
import 'package:imela_core/business/model/payment_method.model.dart';
import 'package:imela_core/shared/localized_field.model.dart';
import 'package:imela_pos/app/app_viewmodel.dart';
import 'package:imela_ui_kit/helpers/widget_extesions.dart';
import 'package:imela_utils/helpers/screen_size_utils.dart';

class PaymentMethodListItem extends StatefulWidget {
  final PaymentMethod paymentMethod;
  final String selectedLanguage;
  final String remainingAmountString;
  final bool showRemainingAmount;
  final Function()? onSelected;
  final Function(String value) onAmountChanged;
  final Function() onDelete;
  final bool isSelected;
  final TextEditingController controller;
  const PaymentMethodListItem({
    super.key,
    required this.paymentMethod,
    required this.selectedLanguage,
    required this.remainingAmountString,
    this.showRemainingAmount = true,
    required this.isSelected,
    required this.onDelete,
    required this.controller,
    this.onSelected,
    required this.onAmountChanged,
  });

  @override
  State<PaymentMethodListItem> createState() => _PaymentMethodListItemState();
}

class _PaymentMethodListItemState extends State<PaymentMethodListItem> {
  var focusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    if (widget.isSelected) {
      focusNode.requestFocus();
    }
    focusNode.addListener(() {
      if (focusNode.hasFocus) {
        widget.onSelected?.call();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    Color borderColor = widget.isSelected ? Theme.of(context).colorScheme.primary : Theme.of(context).colorScheme.primaryContainer;
    final widgetFactory = AppViewmodel.getWidgetFactory(context);
    if (widget.isSelected) {
      focusNode.requestFocus();
      if (widget.controller.text.isEmpty || widget.controller.text == '0.0') {
        widget.controller.text = widget.remainingAmountString;
      }
    }
    return widgetFactory.createCard(
      borderRadius: BorderRadius.circular(8),
      border: Border.all(color: borderColor),
      padding: const EdgeInsets.symmetric(vertical: 8),
      onTap: () {
        widget.onSelected?.call();
      },
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              Flexible(child: Align(alignment: Alignment.centerLeft, child: widgetFactory.createText(context, widget.paymentMethod.name.localize(widget.selectedLanguage), style: Theme.of(context).textTheme.bodyLarge).withPaddingSymetric(horizontal: 16))),
              Padding(
                padding: EdgeInsets.only(right: Responsive.getWidth(context, small: 0, medium: 75, large: 200)),
                child: Flexible(
                  child: widgetFactory.createCard(
                    width: Responsive.getWidth(context, small: 150, medium: 175, large: 200),
                    borderRadius: BorderRadius.circular(32),
                    border: Border.all(color: Theme.of(context).colorScheme.primaryContainer),
                    child: TextField(
                      controller: widget.controller,
                      focusNode: focusNode,
                      style: Theme.of(context).textTheme.bodyLarge,
                      keyboardType: TextInputType.number,
                      textAlign: TextAlign.center,
                      showCursor: true,
                      decoration: InputDecoration(
                        prefix: Text('ETB', style: Theme.of(context).textTheme.bodyLarge).withPaddingSymetric(horizontal: 8),
                        hintStyle: Theme.of(context).textTheme.bodyLarge,
                        hintText: '0.0',
                        isDense: true,
                        contentPadding: const EdgeInsets.symmetric(horizontal: 4, vertical: 8),
                        border: InputBorder.none,
                      ),
                      onChanged: (value) {
                        widget.onAmountChanged(value);
                      },
                    ),
                  ),
                ),
              ),

              widget.controller.text.isNotEmpty
                  ? widgetFactory.createIcon(
                      materialIcon: Icons.delete,
                      size: 24,
                      onPressed: () {
                        widget.onDelete();
                      },
                    )
                  : const SizedBox(width: 45)
            ],
          ),
          // if (paymentMethod.options?.isNotEmpty == true)
          //   AppListView(
          //     padding: const EdgeInsets.symmetric(horizontal: 24),
          //     shrinkWrap: true,
          //     items: paymentMethod.options,
          //     itemBuilder: (context, option, index) {
          //       return widgetFactory.createCheckboxListTile(context, title: option.name.localize(selectedLanguage), value: false, onChanged: (value) {});
          //     },
          //   )
        ],
      ),
    );
  }
}
