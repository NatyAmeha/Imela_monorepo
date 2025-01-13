import 'package:flutter/material.dart';
import 'package:imela/l10n/l10n.dart';
import 'package:imela/presentation/resources/colors.dart';
import 'package:imela/presentation/ui/shared/app_image.dart';
import 'package:imela/presentation/ui/shared/countdown_timer.component.dart';
import 'package:imela/presentation/ui/shared/list/listview.component.dart';
import 'package:imela_core/bundle/model/product_bundle.model.dart';
import 'package:imela_core/shared/localized_field.model.dart';
import 'package:imela_ui_kit/components/badge/badge_list.dart';
import 'package:imela_ui_kit/helpers/widget_extesions.dart';
import 'package:imela_ui_kit/widget_factory/widget.factory.dart';

class BundleListItem extends StatelessWidget {
  final ProductBundle bundleData;
  final WidgetFactory widgetFactory;
  final double? height;
  final double width;
  final Function? onTap;
  final Duration? remainingTime;
  const BundleListItem({
    super.key,
    required this.bundleData,
    required this.widgetFactory,
    this.height,
    this.width = double.infinity,
    this.onTap,
    this.remainingTime,
  });

  bool get canShowTimer => remainingTime != null && remainingTime!.inDays > 0;

  @override
  Widget build(BuildContext context) {
    final productImages = bundleData.getBundleProductImages().take(5);
    return widgetFactory.createCard(
      onTap: () {
        onTap?.call();
      },
      width: width,
      height: height,
      border: Border.all(color: Theme.of(context).colorScheme.primaryContainer),
      borderRadius: BorderRadius.circular(8),
      child: Stack(
        children: [
          Positioned.fill(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Column(
                    mainAxisSize: MainAxisSize.max,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      SizedBox(height: canShowTimer ? 16 : 4),
                      widgetFactory.createText(context, bundleData.name.localize('ENGLISH'), style: Theme.of(context).textTheme.titleMedium),
                      widgetFactory
                          .createText(
                            context,
                            bundleData.description.localize('ENGLISH'),
                            maxLines: 2,
                            padding: const EdgeInsets.symmetric(vertical: 4),
                            style: Theme.of(context).textTheme.labelSmall,
                          )
                          .showIfNotNull(bundleData.description),
                      const SizedBox(height: 4),
                      widgetFactory.createCard(
                        color: Theme.of(context).colorScheme.primaryContainer,
                        borderRadius: BorderRadius.circular(8),
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                        child: Row(
                          mainAxisSize: MainAxisSize.max,
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Expanded(
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  widgetFactory.createText(context, context.l10n.discount, padding: const EdgeInsetsDirectional.fromSTEB(0, 8, 0, 0), style: Theme.of(context).textTheme.labelSmall),
                                  widgetFactory.createText(context, '${bundleData.discount?.value} ${context.l10n.off}', style: Theme.of(context).textTheme.bodyMedium, enableResize: true),
                                ],
                              ),
                            ),
                            const SizedBox(height: 30, child: VerticalDivider(thickness: 1)),
                            Expanded(
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  widgetFactory.createText(context, context.l10n.products, padding: const EdgeInsetsDirectional.fromSTEB(0, 8, 0, 0), style: Theme.of(context).textTheme.bodySmall),
                                  widgetFactory.createText(context, context.l10n.bundleProducts(bundleData.getBundleProducts()), style: Theme.of(context).textTheme.bodyMedium, enableResize: true, maxLines: 1),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                Stack(
                  children: [
                    Padding(
                      padding: const EdgeInsetsDirectional.fromSTEB(0, 12, 0, 0),
                      child: AppListView(
                        shrinkWrap: true,
                        height: 50,
                        scrollDirection: Axis.horizontal,
                        primary: false,
                        contentPadding: const EdgeInsets.symmetric(horizontal: 4),
                        items: productImages.toList(),
                        itemBuilder: (context, imageUrl, index) {
                          return AppImage(imageUrl: imageUrl, width: 50, height: 50, fit: BoxFit.cover, borderRadius: BorderRadius.circular(8));
                        },
                      ).showIfNotNull(productImages.isNotEmpty),
                    ),
                  ],
                ),
              ],
            ).withPaddingAll(8),
          ),
          if (canShowTimer)
            Positioned(
              top: 0,
              left: 0,
              child: BadgeList(
                height: 25,
                widgets: [
                  CountdownTimer(
                    duration: remainingTime ?? Duration.zero,
                    textStyle: Theme.of(context).textTheme.bodySmall?.copyWith(color: Colors.white),
                    borderRadius: 0,
                    backgroundColor: Colors.transparent,
                  ),
                ],
                colors: const [ColorManager.tertiary],
                widgetFactory: widgetFactory,
                alignment: WrapAlignment.start,
              ),
            ),
        ],
      ),
    );
  }
}
