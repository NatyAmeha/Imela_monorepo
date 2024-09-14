import 'package:flutter/material.dart';
import 'package:imela_admin/app/app_viewmodel.dart';
import 'package:imela_admin/ui/business_subscription/platform_service.viewmodel.dart';
import 'package:imela_core/shared/localized_field.model.dart';
import 'package:imela_core/subscription/model/platform_service.model.dart';
import 'package:imela_ui_kit/components/list/listview.component.dart';
import 'package:imela_ui_kit/helpers/widget_extesions.dart';

class SelectedPlatformServiceListItem extends StatelessWidget {
  final PlatformService platformService;
  final Function? onEdit;
  final Function? onDelete;
  final bool showActionButton;
  const SelectedPlatformServiceListItem({
    super.key,
    required this.platformService,
    this.onEdit,
    this.onDelete,
    this.showActionButton = true,
  });

  String get selectedLanguage => AppViewmodel.getInstance().selectedLanguage;
  String get selectedCurrency => AppViewmodel.getInstance().selectedCurrency;
  PlatformServiceViewmodel get platformServiceViewmodel => PlatformServiceViewmodel.getInstance();
  String get selectedPricingOption => platformService.selectedSubscriptionRenewal!.name.localize(selectedLanguage);

  @override
  Widget build(BuildContext context) {
    final selectedServices = platformService.getSelectedCustomizationNameList(selectedLanguage);
    final widgetFactory = AppViewmodel.getWidgetFactory(context);
    return widgetFactory.createCard(
        child: widgetFactory.createCard(
        color: Theme.of(context).colorScheme.secondaryContainer,
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            widgetFactory.createText(context, platformService.name.localize(selectedLanguage), style: Theme.of(context).textTheme.titleMedium),
            widgetFactory.createText(context, selectedPricingOption, style: Theme.of(context).textTheme.bodyMedium),
            const SizedBox(height: 16),
            AppListView(
              shrinkWrap: true,
              items: selectedServices,
              itemBuilder: (context, customization, index) {
                return Row(
                  children: [
                    widgetFactory.createIcon(materialIcon: Icons.check_circle, color: Theme.of(context).colorScheme.primary),
                    const SizedBox(width: 10),
                    widgetFactory.createText(context, customization, style: Theme.of(context).textTheme.bodyMedium),
                  ],
                ).withPaddingSymetric(vertical: 4);
              },
            ),
            if (showActionButton)
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: widgetFactory.createText(context, platformService.totalCustomizationPriceString(selectedCurrency), style: Theme.of(context).textTheme.titleLarge),
                  ),
                  widgetFactory.createIcon(
                      materialIcon: Icons.edit,
                      color: Theme.of(context).colorScheme.primary,
                      onPressed: () {
                        onEdit?.call();
                      }),
                  const SizedBox(width: 16),
                  widgetFactory.createIcon(
                      materialIcon: Icons.delete,
                      color: Theme.of(context).colorScheme.primary,
                      onPressed: () {
                        onDelete?.call();
                      }),
                ],
              )
          ],
        ),
      ),
    );
  }
}
