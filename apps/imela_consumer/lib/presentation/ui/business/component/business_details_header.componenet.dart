import 'package:flutter/material.dart';
import 'package:imela/presentation/resources/colors.dart';
import 'package:imela/presentation/ui/shared/app_image.dart';
import 'package:imela/presentation/utils/localization_utils.dart';
import 'package:imela_core/business/model/business.model.dart';
import 'package:imela_core/shared/gallery.model.dart';
import 'package:imela_ui_kit/widget_factory/widget.factory.dart';

class BusinessDetailsHeader extends StatelessWidget {
  final Business business;
  final double height;
  final double width;
  final PageController? controller;
  const BusinessDetailsHeader({super.key, required this.business, this.height = 100, required this.width, this.controller});

  @override
  Widget build(BuildContext context) {
    var appWidgetFactory = WidgetFactory(Theme.of(context).platform);
    return Stack(
      children: [
        Positioned.fill(
          child: appWidgetFactory.createPageView(
            context,
            itemCount: business.gallery?.getImages().length ?? 0,
            
            controller: controller ?? PageController(),
            width: width,
            height: height,
            itemBuilder: (context, index) {
              return AppImage(imageUrl: business.gallery?.getImages()[index]);
            },
          ),
        ),
        Positioned(
          child: Align(
              alignment: const AlignmentDirectional(0, 1),
              child: Container(
                height: 100,
                padding: const EdgeInsets.all(16),
                color: Colors.black38,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    appWidgetFactory.createText(context, '${business.getLocalizedBusinessName(AppLanguage.ENGLISH.name)}', style: Theme.of(context).textTheme.headlineMedium, color: ColorManager.white,),
                    const SizedBox(height: 4),
                    IntrinsicHeight(
                      child: Row(
                        children: [
                          appWidgetFactory.createIcon(materialIcon: Icons.star, color: ColorManager.tertiary),
                          const SizedBox(width: 2),
                          appWidgetFactory.createText(context, "4.5", style: Theme.of(context).textTheme.labelMedium, color: ColorManager.tertiary),
                          const VerticalDivider(color: ColorManager.white),
                          if(business.categories?.isNotEmpty ?? false) ...[
                            ...business.categories!.map((e) => appWidgetFactory.createText(context, e, style: Theme.of(context).textTheme.titleSmall, color: ColorManager.white)),
                          ]
                          
                        ],
                      ),
                    ),
                  ],
                ),
              )),
        )
      ],
    );
  }
}
