import 'package:flutter/material.dart';
import 'package:imela_core/business/model/business.section.dart';
import 'package:imela_core/shared/localized_field.model.dart';
import 'package:imela_ui_kit/components/image/app_image.dart';
import 'package:imela_ui_kit/widget_factory/widget.factory.dart';

class BusinessSectionListItem extends StatelessWidget {
  final BusinessSection businessSection;
  final WidgetFactory widgetFactory;
  final String selectedLanguage;
  final double imageSize;
  final Function() onTap;
  const BusinessSectionListItem({
    super.key,
    required this.businessSection,
    required this.widgetFactory,
    required this.selectedLanguage,
    required this.onTap,
    this.imageSize = 25,
  });

  @override
  Widget build(BuildContext context) {
    return widgetFactory.createCard(
      onTap: () => onTap(),
      child: Column(
        children: [
          CircleAvatar(
            // backgroundColor: Colors.green[100],
            radius: imageSize,
            child: AppImage(
              imageUrl: businessSection.images?.firstOrNull,
              width: imageSize,
              height: imageSize,
              fit: BoxFit.cover,
              isSvg: true,
              isNetworkSvg: true,
            ),
          ),
          const SizedBox(height: 8),
          widgetFactory.createText(context, businessSection.name.localize(selectedLanguage), style: Theme.of(context).textTheme.bodyMedium, textAlign: TextAlign.center, maxLines: 2, overflow: TextOverflow.ellipsis),
        ],
      ),
    );
  }
}
