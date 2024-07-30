import 'package:flutter/widgets.dart';

extension WidgetExtesions on Widget {
  Widget showIf(Object? value) {
    return value != null ? this : const SizedBox();
  }
}
