import 'package:flutter/material.dart';
import 'package:imela_ui_kit/widget_factory/widget.factory.dart';

class ListHeader extends StatelessWidget {
  final String title;
  final WidgetFactory widgetFactory;
  final String? subtitle;
  final Widget? action;
  final EdgeInsetsGeometry? padding;
  const ListHeader({
    super.key,
    required this.widgetFactory,
    required this.title,
    this.subtitle,
    this.action,
    this.padding,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: padding ?? EdgeInsets.zero,
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                widgetFactory.createText(context, title, style: Theme.of(context).textTheme.titleMedium),
                if (subtitle != null) widgetFactory.createText(context, subtitle!, style: Theme.of(context).textTheme.bodySmall),
              ],
            ),
          ),
          if (action != null) action!,
        ],
      ),
    );
  }
}
