import 'package:flutter/widgets.dart';

extension WidgetExtesions on Widget {
  Widget showIfNotNull(Object? value) {
    return value != null ? this : const SizedBox();
  }

  Widget showIfTrue(bool? value) {
    const emptyPlacehoder = SizedBox();
    if (value == null) {
      return emptyPlacehoder;
    }
    return value ? this : emptyPlacehoder;
  }

  Widget withPaddingAll(double padding) {
    return Padding(
      padding: EdgeInsets.all(padding),
      child: this,
    );
  }

  Widget withPaddingSymetric({double horizontal = 0.0, double vertical = 0.0}) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: horizontal, vertical: vertical),
      child: this,
    );
  }
}
