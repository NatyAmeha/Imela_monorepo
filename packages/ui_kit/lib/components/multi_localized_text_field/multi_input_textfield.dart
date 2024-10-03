import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:imela_ui_kit/components/multi_localized_text_field/input_field.viewmodel.dart';
import 'package:imela_ui_kit/widget_factory/widget.factory.dart';

class MultiInputTextfield extends StatefulWidget {
  final WidgetFactory widgetFactory;
  final Map<String, String> values;
  final String selectedKey;
  final String? hintText;
  final double? width;
  final TextInputViewmodel viewmodel;
  final Function(Map<String, String>)? onfinish;

  const MultiInputTextfield({
    super.key,
    required this.widgetFactory,
    required this.viewmodel,
    required this.values,
    required this.selectedKey,
    this.width = double.infinity,
    this.hintText,
    this.onfinish,
  });

  @override
  State<MultiInputTextfield> createState() => _MultiInputTextfieldState();
}

class _MultiInputTextfieldState extends State<MultiInputTextfield> {
  @override
  void initState() {
    super.initState();
    Future.delayed(Duration.zero, () {
      widget.viewmodel.setOptions(widget.values, widget.selectedKey);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Obx(
      () => Focus(
        onFocusChange: (value) {
          widget.onfinish?.call(widget.viewmodel.options);
        },
        child: SizedBox(
          width: widget.width,
          child: widget.widgetFactory.createTextField(
            controller: widget.viewmodel.controller,
            decoration: InputDecoration(
                suffix: widget.widgetFactory.createDropDown(
                  context: context,
                  value: widget.viewmodel.selectedKey.value,
                  options: widget.viewmodel.getOptionsUI(context),
                  onChanged: (value) {
                    widget.viewmodel.updateSelectedKey(value);
                  },
                ),
                border: OutlineInputBorder()),
            hintText: widget.hintText ?? '   ',
            onChanged: (vlaue) {
              widget.viewmodel.updateSelectedKeyValue(vlaue);
            },
            suffixIcon: widget.widgetFactory.createDropDown(
              context: context,
              value: widget.viewmodel.selectedKey.value,
              options: widget.viewmodel.getOptionsUI(context),
              onChanged: (value) {
                widget.viewmodel.updateSelectedKey(value);
              },
            ),
          ),
        ),
      ),
    );
  }
}
