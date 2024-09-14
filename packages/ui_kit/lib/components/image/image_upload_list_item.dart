import 'package:flutter/material.dart';
import 'package:imela_ui_kit/components/image/app_image.dart';
import 'package:imela_ui_kit/helpers/file_upload.model.dart';
import 'package:imela_ui_kit/widget_factory/widget.factory.dart';

class ImageUploadListItem extends StatelessWidget {
  final FileUpload fileUpload;
  final Function(bool? value) onFeaturedChange;
  final WidgetFactory widgetFactory;
  final Function? onDelete;
  const ImageUploadListItem({super.key, required this.fileUpload, required this.widgetFactory, required this.onFeaturedChange, this.onDelete});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: (context, constraint) {
      return Stack(
        children: [
          Positioned.fill(
            child: Column(
              children: [
                AppImage(imageUrl: fileUpload.url, file: fileUpload.file, width: 50, height: 50),
                CheckboxListTile(
                    title: widgetFactory.createText(context, 'Is Featured', style: Theme.of(context).textTheme.bodySmall),
                    value: fileUpload.isFeatured,
                    contentPadding: EdgeInsets.zero,
                    dense: true,
                    onChanged: (value) {
                      onFeaturedChange(value);
                    }),
              ],
            ),
          ), 
          Positioned(
            top: 0,
            right: 0,
            child: IconButton(
              icon: Icon(Icons.delete),
              onPressed: () {
                onDelete?.call();
              },
            ),
          ),
        ],
      );
    });
  }
}
