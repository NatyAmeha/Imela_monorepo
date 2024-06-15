import 'package:flutter/material.dart';
import 'package:melegna_customer/domain/business/model/business.model.dart';
import 'package:melegna_customer/presentation/resources/colors.dart';
import 'package:melegna_customer/presentation/ui/factory/widget.factory.dart';
import 'package:melegna_customer/presentation/ui/shared/app_image.dart';

class BusinessDetailsHeader extends StatelessWidget {
  final Business business;
  final double height;
  final double width;
  final PageController? controller;
  const BusinessDetailsHeader({super.key, required this.business, this.height = 100, required this.width, this.controller});

  @override
  Widget build(BuildContext context) {
    var image = "https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcT2zK7l5I39tA2d0DqcZYxzuFdufj1bDtp6xg&s";
    var appWidgetFactory = WidgetFactory(Theme.of(context).platform);
    return Stack(
      children: [
        Positioned.fill(
          child: appWidgetFactory.createPageView(
            context,
            itemCount: 3,
            
            controller: controller ?? PageController(),
            width: width,
            height: height,
            itemBuilder: (context, index) {
              return AppImage(imageUrl: image);
            },
          ),
        ),
        Positioned(
          child: Align(
              alignment: const AlignmentDirectional(0, 1),
              child: Container(
                height: 100,
                padding: EdgeInsets.all(16),
                color: Colors.black38,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    appWidgetFactory.createText(context, "Business Name", style: Theme.of(context).textTheme.headlineMedium, color: ColorManager.white),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        appWidgetFactory.createIcon(materialIcon: Icons.star, color: ColorManager.tertiary),
                        const SizedBox(width: 2),
                        appWidgetFactory.createText(context, "4.5", style: Theme.of(context).textTheme.labelMedium, color: ColorManager.tertiary),
                      ],
                    )
                  ],
                ),
              )),
        )
      ],
    );
  }
}
