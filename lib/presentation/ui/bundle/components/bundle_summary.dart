import 'package:flutter/material.dart';
import 'package:melegna_customer/domain/bundle/model/product_bundle.model.dart';
import 'package:melegna_customer/presentation/resources/colors.dart';
import 'package:melegna_customer/presentation/ui/bundle/bundle_detail/bundle_detail.viewmodel.dart';
import 'package:melegna_customer/presentation/ui/factory/widget.factory.dart';
import 'package:melegna_customer/presentation/ui/shared/countdown_timer.component.dart';
import 'package:melegna_customer/presentation/utils/widget_extesions.dart';

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
    return widgetFactory.createCard(
      padding: const EdgeInsets.all(8),
      color: ColorManager.alternate,
      width: width,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Padding(
            padding: const EdgeInsets.all(4),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(flex: 1, child: widgetFactory.createText(context, 'Discount', style: Theme.of(context).textTheme.titleSmall, textAlign: TextAlign.start)),
                Expanded(
                  flex: 2,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      widgetFactory.createText(context, viewmodel.getDiscountValue!, style: Theme.of(context).textTheme.titleMedium, textAlign: TextAlign.end),
                      widgetFactory.createText(context, viewmodel.discountCondition!, style: Theme.of(context).textTheme.labelSmall, textAlign: TextAlign.end).showIfTrue(viewmodel.discountCondition?.isNotEmpty == true),
                    ],
                  ),
                )
              ],
            ).showIfTrue(viewmodel.getDiscountValue.isNotEmpty == true),
          ),
          Padding(
            padding: const EdgeInsets.all(4),
            child: Row(
              children: [
                widgetFactory.createText(context, 'Total products', style: Theme.of(context).textTheme.titleSmall, textAlign: TextAlign.start),
                Expanded(
                  child: widgetFactory.createText(context, viewmodel.totalProductcount, style: Theme.of(context).textTheme.titleMedium, textAlign: TextAlign.end),
                )
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(4),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                widgetFactory.createText(context, 'Time remaining', style: Theme.of(context).textTheme.titleSmall, textAlign: TextAlign.start),
                CountdownTimer(duration: viewmodel.getRemainingTime(), backgroundColor: ColorManager.error),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
