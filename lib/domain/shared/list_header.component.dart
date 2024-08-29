import 'package:flutter/material.dart';
import 'package:imela/presentation/ui/factory/widget.factory.dart';

class AppListHeader extends StatelessWidget {
  final String title;
  final String? subtitle;
  final Widget? trailing;
  final Widget? leading;
  final double? height;
  final double? width;
  final EdgeInsetsGeometry? padding;
  final Function? onActionClicked;
  const AppListHeader({super.key, required this.title, this.subtitle, this.trailing, this.leading, this.height, this.width, this.padding,  this.onActionClicked});

  @override
  Widget build(BuildContext context) {
    var widgetFactory = WidgetFactory(Theme.of(context).platform);
    return Container(
      height: height,
      width: width,
      padding: padding,
      child: Row(
        children: [
          if (leading != null) ...[
            leading!,
          ],
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                widgetFactory.createText(context, title, style: Theme.of(context).textTheme.titleMedium),
                if (subtitle != null) ...[
                  widgetFactory.createText(context, subtitle!, style: Theme.of(context).textTheme.bodyMedium),
                ],
              ],
            ),
          ),
          if (trailing != null) ...[
            const SizedBox(width:16),
            InkWell(
              onTap: () {
                onActionClicked?.call();
              },
              child: trailing!,
            ),
          ],
        ],
      ),
    );
  }
}
