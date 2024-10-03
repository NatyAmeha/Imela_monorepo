import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:imela_utils/helpers/base_viewmodel.dart';

class TextInputViewmodel extends GetxController with BaseViewmodel {
  final controller = TextEditingController();

  var options = <String, String>{}.obs;
  var selectedKey = ''.obs;
  List<String> get keys => options.keys.toList();
  String get selectedKeyValue => options[selectedKey.value] ?? '';

  static TextInputViewmodel getInstance({String? key}) {
    return BaseViewmodel.isViewmodelRegistered(TextInputViewmodel(), tag: key);
  }

  void setOptions(Map<String, String> values, String? selected) {
    options.value = values;
    selectedKey.value = selected ?? values.keys.first;
    controller.text = selectedKeyValue;
    print('selected key: ${controller.text}');
  }

  void updateSelectedKey(String? key) {
    if (key == null) return;
    selectedKey.value = key;
    controller.text = selectedKeyValue;
  }

  void updateSelectedKeyValue(String value) {
    options[selectedKey.value] = value;
  }

  Map<String, Widget> getOptionsUI(BuildContext context) => keys.asMap().map((index, key) => MapEntry(key, Text(key, style: Theme.of(context).textTheme.bodyMedium,)));

  @override
  void initViewmodel({Map<String, dynamic>? data}) {
    // TODO: implement initViewmodel
    super.initViewmodel(data: data);
  }
}
