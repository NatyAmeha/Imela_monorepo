

import 'package:flutter/material.dart';
import 'package:imela/presentation/resources/colors.dart';
import 'package:imela_ui_kit/widget_factory/widget.factory.dart';

class BannerItemComponent extends StatelessWidget {
  final double width;
  final double? height;
  final EdgeInsets? padding;
  final Color backgroundColor;
  final String title;
  final String? subtitle;
  final IconData? icon;
  const BannerItemComponent({super.key, required this.title, this.subtitle, required this.width, this.height, required this.backgroundColor, this.padding, this.icon});

  @override
  Widget build(BuildContext context) {
    var appWidgetFactory = WidgetFactory(Theme.of(context).platform);

    return appWidgetFactory.createCard(
      color: backgroundColor,
      width: width,
      height: height,
      padding: padding ?? const EdgeInsets.all(16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(mainAxisSize: MainAxisSize.max, children: [
                  if (icon != null)
                    Padding(
                      padding: const EdgeInsets.all(4),
                      child: Icon(icon!, color: Colors.white, size: 24),
                    ),
                  appWidgetFactory.createText(context, title, style: Theme.of(context).textTheme.titleMedium, color: ColorManager.info),
                ]),
                if (subtitle != null) appWidgetFactory.createText(context, subtitle!, style: Theme.of(context).textTheme.titleSmall, color: ColorManager.info),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
