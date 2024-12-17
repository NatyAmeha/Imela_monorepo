import 'package:flutter/material.dart';
import 'package:imela/presentation/resources/colors.dart';
import 'package:imela/presentation/ui/bundle/bundle_detail/bundle_detail.viewmodel.dart';
import 'package:imela/presentation/ui/shared/countdown_timer.component.dart';
import 'package:imela_core/bundle/model/product_bundle.model.dart';
import 'package:imela_ui_kit/helpers/widget_extesions.dart';
import 'package:imela_ui_kit/widget_factory/widget.factory.dart';

class BundleSummary extends StatelessWidget {
  final double width;
  final WidgetFactory widgetFactory;
  final ProductBundle bundle;

  final BundleDetailViewmodel viewmodel;
  const BundleSummary({
    super.key,
    required this.widgetFactory,
    required this.bundle,
    required this.viewmodel,
    this.width = double.infinity,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (viewmodel.getDiscountValue.isNotEmpty == true)
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(flex: 1, child: widgetFactory.createText(context, 'Discount', style: Theme.of(context).textTheme.titleSmall, textAlign: TextAlign.start)),
              Expanded(
                flex: 2,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    widgetFactory.createText(context, viewmodel.getDiscountValue, style: Theme.of(context).textTheme.titleMedium, textAlign: TextAlign.end),
                  ],
                ),
              )
            ],
          ).withPaddingSymetric(vertical: 6),
        Row(
          children: [
            widgetFactory.createText(context, 'Total products', style: Theme.of(context).textTheme.titleSmall, textAlign: TextAlign.start),
            Expanded(
              child: widgetFactory.createText(context, viewmodel.totalProductcount, style: Theme.of(context).textTheme.bodyLarge, textAlign: TextAlign.end),
            )
          ],
        ),
        const SizedBox(height: 10),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            widgetFactory.createText(context, 'Time remaining', style: Theme.of(context).textTheme.titleSmall, textAlign: TextAlign.start),
            CountdownTimer(duration: viewmodel.remainingTime, backgroundColor: ColorManager.error),
          ],
        ),
      ],
    );
  }
}
