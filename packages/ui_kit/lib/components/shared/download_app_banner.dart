import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:imela_ui_kit/widget_factory/widget.factory.dart';

class DownloadAppBanner extends StatelessWidget {
  final String title;
  final List<String> description;
  final WidgetFactory widgetFactory;
  final Function()? onDownload;
  const DownloadAppBanner({
    super.key,
    required this.title,
    required this.description,
    required this.widgetFactory,
    this.onDownload,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisSize: MainAxisSize.min,
      children: [
        widgetFactory.createText(context, title, style: Theme.of(context).textTheme.titleMedium),
        const SizedBox(height: 16),
        ListView(
          shrinkWrap: true,
          children: description.map(
            (desc) {
              return Row(
                children: [
                  widgetFactory.createIcon(materialIcon: Icons.check_circle, color: Theme.of(context).colorScheme.primary, size: 26),
                  const SizedBox(width: 16),
                  Flexible(child: widgetFactory.createText(context, desc, style: Theme.of(context).textTheme.bodyMedium)),
                ],
              ).paddingSymmetric(vertical: 6);
            },
          ).toList(),
        ),
        const SizedBox(height: 16),
        widgetFactory.createButton(
          context: context,
          content: widgetFactory.createText(context, 'Download App', style: Theme.of(context).textTheme.bodyMedium),
          onPressed: onDownload,
        ),
      ],
    ).paddingAll(16);
  }
}
