import 'package:flutter/material.dart';
import 'package:imela_ui_kit/components/image/image_upload.viewmodel.dart';
import 'package:imela_ui_kit/components/image/image_upload_list_item.dart';
import 'package:imela_ui_kit/components/list/gridview.component.dart';
import 'package:imela_ui_kit/helpers/button_style.dart';
import 'package:imela_ui_kit/helpers/file_upload.model.dart';
import 'package:imela_ui_kit/widget_factory/widget.factory.dart';
import 'package:imela_utils/helpers/screen_size_utils.dart';

class ImageUploader extends StatefulWidget {
  final List<FileUpload> images;
  final WidgetFactory widgetFactory;
  final bool showFeaturedOption;
  final double width;
  final double? height;
  final Function(FileUpload?)? onImageUpload;
  final Function(int index)? onImageRemoved;

  const ImageUploader({
    super.key,
    this.images = const [],
    required this.widgetFactory,
    this.width = double.infinity,
    this.height,
    this.showFeaturedOption = false,
    this.onImageUpload,
    this.onImageRemoved,
  });

  @override
  State<ImageUploader> createState() => _ImageUploaderState();
}

class _ImageUploaderState extends State<ImageUploader> {
  var imageViewmodel = ImageUploadViewmodel.getInstance();

  @override
  void initState() {
    super.initState();
    Future.delayed(Duration.zero, () {
      imageViewmodel.setUploadedImages(widget.images);
    });
  }

  @override
  Widget build(BuildContext context) {
    return widget.widgetFactory.createCard(
      padding: const EdgeInsets.all(16),
      width: widget.width,
      height: widget.height,
      border: Border.all(color: Theme.of(context).colorScheme.primary),
      child: SingleChildScrollView(
        primary: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            widget.widgetFactory.createButton(
              context: context,
              content: const Text('Upload Image'),
              style: AppButtonStyle.textButtonStyle(context),
              onPressed: () async {
                uploadImage();
              },
            ),
            Divider(height: Responsive.isSmallScreen(context) ? 16 : 50),
            AppGridView(
              shrinkWrap: true,
              controller: imageViewmodel.imageListController,
              primary: false,
              crossAxisCount: Responsive.getGridCount(context, itemWidth: Responsive.isSmallScreen(context) ? 85 : 120),
              height: 500,
              itemBuilder: (context, fileData, index) {
                return ImageUploadListItem(
                  widgetFactory: widget.widgetFactory,
                  fileUpload: fileData,
                  onFeaturedChange: widget.showFeaturedOption
                      ? (value) {
                          imageViewmodel.updateIsFeaturedStatus(index, value ?? false);
                        }
                      : null,
                  onDelete: () {
                    imageViewmodel.removeImages([index]);
                    widget.onImageRemoved?.call(index);
                  },
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  void uploadImage() async {
    final uploadedFile = await imageViewmodel.PickImage();
    widget.onImageUpload?.call(uploadedFile);
  }
}
