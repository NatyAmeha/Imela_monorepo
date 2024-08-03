import 'package:flutter/widgets.dart';

extension WidgetExtesions on Widget {
  Widget showIfNotNull(Object? value) {
    return value != null ? this : const SizedBox();
  }

  Widget showIfTrue(bool? value){
    const emptyPlacehoder = SizedBox();
    if(value == null){
      return emptyPlacehoder;
    }
    return value ? this : emptyPlacehoder; 

  }
}
