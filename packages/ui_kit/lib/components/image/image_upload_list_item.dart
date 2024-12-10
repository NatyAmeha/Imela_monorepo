import 'package:flutter/material.dart';
import 'package:imela_ui_kit/components/image/app_image.dart';
import 'package:imela_ui_kit/helpers/file_upload.model.dart';
import 'package:imela_ui_kit/widget_factory/widget.factory.dart';

class ImageUploadListItem extends StatelessWidget {
  final FileUpload fileUpload;
  
  final Function(bool? value)? onFeaturedChange;
  final WidgetFactory widgetFactory;
  final Function? onDelete;
  const ImageUploadListItem({super.key, required this.fileUpload, required this.widgetFactory, this.onFeaturedChange, this.onDelete});

  @override
  Widget build(BuildContext context) {
    final widgetFactory = WidgetFactory(Theme.of(context).platform);
    return LayoutBuilder(builder: (context, constraint) {
      return Stack(
        children: [
          Positioned.fill(
            child: widgetFactory.createCard(
              border: Border.all(color: Colors.grey),
              child: Column(
                children: [
                  AppImage(imageUrl: fileUpload.url, file: fileUpload.file, width: 50, height: 50),
                  if (onFeaturedChange != null)
                    CheckboxListTile(
                      title: widgetFactory.createText(context, 'Is Featured', style: Theme.of(context).textTheme.bodySmall),
                      value: fileUpload.isFeatured,
                      contentPadding: EdgeInsets.zero,
                      dense: true,
                      onChanged: (value) {
                        onFeaturedChange?.call(value);
                      },
                    ),
                ],
              ),
            ),
          ),
          Positioned(
            top: 0,
            right: 0,
            child: InkWell(
              onTap: () {
                onDelete?.call();
              },
              child: const Icon(Icons.delete),
            ),
          ),
        ],
      );
    });
  }
}
