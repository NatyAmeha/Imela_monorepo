import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:melegna_customer/presentation/ui/factory/widget.factory.dart';
import 'package:melegna_customer/presentation/ui/shared/app_image.dart';

class BannerData {
  final String title;
  final String description;
  final String imageUrl;
  final Color? backgroundColor;

  BannerData({
    required this.title,
    required this.description,
    required this.imageUrl,
    this.backgroundColor,
  });
}

class FeaturePromoBannerList extends StatelessWidget {
  final List<BannerData> promoCardData;
  final double height;
  final double width;
  final Function? onTap;
  final WidgetFactory widgetFactory;
  final PageController controller;
  final double imageSize;
  const FeaturePromoBannerList({
    super.key,
    required this.promoCardData,
    required this.widgetFactory,
    required this.height,
    required this.controller,
    this.width = double.infinity,
    this.imageSize = 100,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return widgetFactory.createPageView(
      context,
      itemCount: promoCardData.length,
      
      itemBuilder: (context, index) {
        return widgetFactory.createCard(
          color: promoCardData[index].backgroundColor,
          padding: const EdgeInsets.all(16),
          margin: const EdgeInsets.all(16),
          child: Row(
            // crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    widgetFactory.createText(context, promoCardData[index].title, style: Theme.of(context).textTheme.titleMedium),
                    const SizedBox(height: 8),
                    widgetFactory.createText(context, promoCardData[index].description, style: Theme.of(context).textTheme.bodyMedium, maxLines: 5, overflow: TextOverflow.ellipsis),
                  ],
                ),
              ),
              const SizedBox(width: 16),
              AppImage(imageUrl: promoCardData[index].imageUrl, width: imageSize, height: imageSize+25, borderRadius: BorderRadius.circular(10)),
            ],
          ),
        );
      },
      controller: controller,
      width: width,
      height: height,
    );
  }
}
