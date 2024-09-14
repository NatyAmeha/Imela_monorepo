import 'package:flutter/material.dart';
import 'package:imela_admin/app/app_viewmodel.dart';
import 'package:imela_core/business/model/business.model.dart';
import 'package:imela_core/shared/localized_field.model.dart';
import 'package:imela_ui_kit/components/image/app_image.dart';
import 'package:imela_ui_kit/helpers/widget_extesions.dart';
import 'package:imela_utils/helpers/date_utils.dart';

class BusinessListItem extends StatelessWidget {
  final Business business;
  final double width;
  final double imageHeight;
  final double? height;
  final Function? onSelected;
  const BusinessListItem({
    super.key,
    required this.business,
    this.width = double.infinity,
    this.height,
    this.imageHeight = 100.0,
    this.onSelected,
  });

  String get selectedLanguage => AppViewmodel.getInstance().selectedLanguage;
  String get businessCreateDateString => 'Created ${business.createdAt?.toFormattedString() ?? ''}';

  @override
  Widget build(BuildContext context) {
    final widgetFactory = AppViewmodel.getWidgetFactory(context);
    return widgetFactory.createCard(
        width: width,
        height: height,
        border: Border.all(color: Theme.of(context).colorScheme.primary),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            AppImage(
                imageUrl: 'https://picsum.photos/200/300', // business.gallery?.getImage(),
                width: width,
                height: imageHeight,
                fit: BoxFit.cover),
            Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 16),
                widgetFactory.createText(context, business.name.localize(selectedLanguage), style: Theme.of(context).textTheme.titleMedium),
                const SizedBox(height: 4),
                widgetFactory.createText(context, businessCreateDateString, style: Theme.of(context).textTheme.labelMedium),
                const SizedBox(height: 16),
                widgetFactory.createButton(
                  context: context,
                  content: const Text('Go to Business'),
                  onPressed: () {
                    onSelected?.call();
                  },
                ),
              ],
            ).withPaddingSymetric(horizontal: 16)
          ],
        ));
  }
}
