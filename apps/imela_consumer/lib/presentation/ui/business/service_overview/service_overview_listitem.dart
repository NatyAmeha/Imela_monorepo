import 'package:flutter/material.dart';
import 'package:imela/presentation/utils/widget_extesions.dart';
import 'package:imela_core/business/model/service_overview.model.dart';
import 'package:imela_core/shared/localized_field.model.dart';
import 'package:imela_ui_kit/components/image/image_collection.dart';
import 'package:imela_ui_kit/helpers/button_style.dart';
import 'package:imela_ui_kit/widget_factory/widget.factory.dart';

class ServiceOverviewListItem extends StatelessWidget {
  final ServiceOverview serviceOverview;
  final WidgetFactory widgetFactory;
  final String selectedLanguage;
  final Color? color;
  final bool showFullContent;
  final Function? onTap;
  final Function()? onCallToActionPressed;
  final Function(int index)? onGalleryTap;
  final double width;
  final double galleryHeight;
  final double colorWidth;

  const ServiceOverviewListItem({
    super.key,
    required this.serviceOverview,
    required this.widgetFactory,
    required this.selectedLanguage,
    this.color,
    this.onTap,
    this.onCallToActionPressed,
    this.width = double.infinity,
    this.galleryHeight = 100,
    this.showFullContent = false,
    this.colorWidth = 5,
    this.onGalleryTap,
  });

  List<String> get images => serviceOverview.gallery?.getImages() ?? [];
  @override
  Widget build(BuildContext context) {
    return widgetFactory.createCard(
      onTap: () {
        onTap?.call();
      },
      border: Border.all(color: Theme.of(context).colorScheme.primaryContainer),
      width: width,
      child: IntrinsicHeight(
        child: Row(
          children: [
            Container(color: color, width: colorWidth),
            const SizedBox(width: 10),
            Expanded(
                child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                widgetFactory.createText(context, serviceOverview.title.localize(selectedLanguage), style: Theme.of(context).textTheme.labelMedium?.copyWith(fontWeight: FontWeight.bold, fontSize: showFullContent ? 16 : 14)),
                SizedBox(height: showFullContent ? 8 : 2),
                Flexible(
                  child: widgetFactory.createText(
                    context,
                    serviceOverview.description.localize(selectedLanguage),
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(fontSize: showFullContent ? 14 : 12),
                    maxLines: showFullContent ? null : 2,
                    overflow: showFullContent ? null : TextOverflow.ellipsis,
                  ),
                ),
                if (showFullContent) ...[
                  const SizedBox(height: 8),
                  if (images.isNotEmpty)
                    ImageCollection(
                      imageUrls: images,
                      height: 180,
                      onImagePressed: (index) {
                        onGalleryTap?.call(index);
                      },
                    ),
                  const SizedBox(height: 8),
                  if (serviceOverview.callToAction != null)
                    widgetFactory.createButton(
                      context: context,
                      style: AppButtonStyle.outlinedButtonStyle(context, padding: EdgeInsets.symmetric(horizontal: 16), borderRadius: 32),
                      content: Text(serviceOverview.callToAction.localize(selectedLanguage)),
                      onPressed: () {
                        onCallToActionPressed?.call();
                      },
                    ),
                ]
              ],
            ).withPaddingSymetric(vertical: showFullContent ? 12 : 2))
          ],
        ),
      ),
    );
  }
}
