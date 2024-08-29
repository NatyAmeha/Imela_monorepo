import 'package:flutter/material.dart';
import 'package:imela/presentation/ui/factory/widget.factory.dart';

class DateTimeModifier extends StatelessWidget {
  final WidgetFactory widgetFactory;
  final bool? selectTime;

  const DateTimeModifier({super.key, required this.widgetFactory,  this.selectTime = true});

  @override
  Widget build(BuildContext context) {
    return const Placeholder();
  }
}