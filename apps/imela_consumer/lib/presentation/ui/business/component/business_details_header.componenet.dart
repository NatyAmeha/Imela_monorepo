import 'package:flutter/material.dart';
import 'package:imela/presentation/resources/colors.dart';
import 'package:imela/presentation/ui/shared/app_image.dart';
import 'package:imela_core/business/model/business.model.dart';
import 'package:imela_ui_kit/widget_factory/widget.factory.dart';
import 'package:imela_utils/helpers/localization_utils.dart';

class BusinessDetailsHeader extends StatelessWidget {
  final Business business;
  final double height;
  final double width;
  final PageController? controller;
  final String selectedLanguage;
  final Function() onLanguageSelected;
  final Function(int? index)? onTap;
  const BusinessDetailsHeader({
    super.key,
    required this.business,
    this.height = 100,
    required this.width,
    this.controller,
    required this.selectedLanguage,
    required this.onLanguageSelected,
    this.onTap,
  });

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
            autoScroll: true,
            autoScrollDuration: const Duration(seconds: 5),
            itemBuilder: (context, index) {
              return InkWell(
                onTap: () {
                  onTap?.call(index);
                },
                child: AppImage(imageUrl: business.gallery?.getImages()[index]),
              );
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
                    appWidgetFactory.createText(
                      context,
                      '${business.getLocalizedBusinessName(AppLanguage.ENGLISH.name)}',
                      style: Theme.of(context).textTheme.headlineMedium,
                      color: ColorManager.white,
                    ),
                    const SizedBox(height: 4),
                    IntrinsicHeight(
                      child: Row(
                        children: [
                          if (business.categories?.isNotEmpty ?? false) ...[
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

  Widget _buildLanguageSelector(BuildContext context, WidgetFactory widgetFactory) {
    return widgetFactory.createCard(
        onTap: () => onLanguageSelected(),
        borderRadius: BorderRadius.circular(4),
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        border: Border.all(color: Theme.of(context).colorScheme.primary),
        child: Row(
          children: [
            widgetFactory.createIcon(materialIcon: Icons.language, color: ColorManager.white),
            const SizedBox(width: 8),
            widgetFactory.createText(context, selectedLanguage, style: Theme.of(context).textTheme.bodyMedium, color: ColorManager.white),
            const SizedBox(width: 8),
            widgetFactory.createIcon(materialIcon: Icons.arrow_drop_down, color: ColorManager.white),
          ],
        ));
  }
}
