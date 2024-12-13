import 'package:flutter/material.dart';
import 'package:imela/presentation/resources/colors.dart';
import 'package:imela/presentation/utils/date_utils.dart';
import 'package:imela_core/membership/model/membership.model.dart';
import 'package:imela_core/shared/localized_field.model.dart';
import 'package:imela_core/subscription/model/subscription.model.dart';
import 'package:imela_ui_kit/helpers/button_style.dart';
import 'package:imela_ui_kit/widget_factory/widget.factory.dart';

class UserMembershipCard extends StatelessWidget {
  final Membership membership;
  final Subscription? subscription;
  final WidgetFactory widgetFactory;
  final String selectedLanguage;
  final Color? backgroundColor;
  final Widget? qrCode;
  final Function() onViewDetailsPressed;
  final Function? onQrCodePressed;
  const UserMembershipCard({
    super.key,
    required this.membership,
    this.subscription,
    required this.widgetFactory,
    required this.selectedLanguage,
    required this.onViewDetailsPressed,
    this.backgroundColor,
    this.qrCode,
    this.onQrCodePressed,
  });

  @override
  Widget build(BuildContext context) {
    return widgetFactory.createCard(
      color: backgroundColor ?? Theme.of(context).colorScheme.primary,
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    widgetFactory.createText(context, membership.name.localize(selectedLanguage), style: Theme.of(context).textTheme.titleMedium, color: ColorManager.white),
                    widgetFactory.createText(context, "${membership.ownerName}", style: Theme.of(context).textTheme.titleSmall, color: ColorManager.white),
                    if (subscription != null)
                      widgetFactory.createText(
                        context,
                        subscription!.subscriptionStatusString(selectedLanguage),
                        style: Theme.of(context).textTheme.titleSmall,
                        color: ColorManager.white,
                      ),
                  ],
                ),
              ),
              if (qrCode != null)
                widgetFactory.createCard(
                  width: 50,
                  height: 50,
                  color: Theme.of(context).colorScheme.tertiaryContainer,
                  child: qrCode!,
                  onTap: () {
                    onQrCodePressed?.call();
                  },
                )
            ],
          ),
          const SizedBox(height: 8),
          if (subscription != null) ...[
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                widgetFactory.createText(context, 'Start Date', style: Theme.of(context).textTheme.titleSmall),
                widgetFactory.createText(context, subscription!.startDate.toFormattedString(), style: Theme.of(context).textTheme.titleSmall),
              ],
            ),
            const SizedBox(height: 4),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                widgetFactory.createText(context, 'End Date', style: Theme.of(context).textTheme.titleSmall),
                widgetFactory.createText(context, subscription!.endDate.toFormattedString(), style: Theme.of(context).textTheme.titleSmall),
              ],
            ),
            const SizedBox(height: 8),
          ],
          const SizedBox(height: 16),
          widgetFactory.createButton(
            context: context,
            content: widgetFactory.createText(context, 'View Details', color: Colors.white, style: Theme.of(context).textTheme.titleSmall),
            style: AppButtonStyle.outlinedButtonStyle(context, borderRadius: 32),
            onPressed: () {
              onViewDetailsPressed();
            },
          )
        ],
      ),
    );
  }
}
