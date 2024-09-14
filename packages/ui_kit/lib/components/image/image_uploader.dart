import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:imela_ui_kit/components/image/image_upload.viewmodel.dart';
import 'package:imela_ui_kit/components/image/image_upload_list_item.dart';
import 'package:imela_ui_kit/components/list/gridview.component.dart';
import 'package:imela_ui_kit/helpers/file_upload.model.dart';
import 'package:imela_ui_kit/widget_factory/widget.factory.dart';

class ImageUploader extends StatefulWidget {
  final List<FileUpload> images;
  final WidgetFactory widgetFactory;
  final bool showFeaturedOption;
  final double width;
  final double? height;

  const ImageUploader({
    super.key,
    this.images = const [],
    required this.widgetFactory,
    this.width = double.infinity,
    this.height,
    this.showFeaturedOption = false,
  });

  @override
  State<ImageUploader> createState() => _ImageUploaderState();
}

class _ImageUploaderState extends State<ImageUploader> {
  var imageViewmodel = Get.put(ImageUploadViewmodel());

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    Future.delayed(Duration.zero,(){
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
                content: Text('Upload Image'),
                onPressed: () {
                  imageViewmodel.PickImage();
                }),
            const Divider(height: 50),
            AppGridView(
              shrinkWrap: true,
              controller: imageViewmodel.imageListController,
              crossAxisCount: 3,
              height: widget.height,
              itemBuilder: (context, fileData, index) {
                return ImageUploadListItem(
                  widgetFactory: widget.widgetFactory,
                  fileUpload: fileData,
                  onFeaturedChange: (value) {
                    imageViewmodel.updateIsFeaturedStatus(index, value ?? false);
                  },
                  onDelete: () {
                    imageViewmodel.removeImages([index]);
                  },
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
