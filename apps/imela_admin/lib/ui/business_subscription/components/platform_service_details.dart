import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:imela_admin/app/app_viewmodel.dart';
import 'package:imela_admin/ui/business_subscription/components/platform_servcie_customization_selector.dart';
import 'package:imela_admin/ui/business_subscription/components/subscription_renewal_list_item.dart';
import 'package:imela_admin/ui/business_subscription/platform_service.viewmodel.dart';
import 'package:imela_core/shared/localized_field.model.dart';
import 'package:imela_core/subscription/model/platform_service.model.dart';
import 'package:imela_ui_kit/components/list/listview.component.dart';
import 'package:imela_ui_kit/helpers/widget_extesions.dart';

class PlatformServiceDetails extends StatefulWidget {
  final PlatformService platformService;
  const PlatformServiceDetails({super.key, required this.platformService});

  @override
  State<PlatformServiceDetails> createState() => _PlatformServiceDetailsState();
}

class _PlatformServiceDetailsState extends State<PlatformServiceDetails> {
  PlatformServiceViewmodel get platformServiceViewmodel => PlatformServiceViewmodel.getInstance();

  @override
  void initState() {
    super.initState();
    Future.delayed(Duration.zero, () {
      platformServiceViewmodel.updateSelectedPricingOption(widget.platformService.selectedSubscriptionRenewal);
      platformServiceViewmodel.updateSelectedCustomizations(widget.platformService.selectedCustomization);
    });
  }

  @override
  Widget build(BuildContext context) {
    final widgetFactory = AppViewmodel.getWidgetFactory(context);
    return Stack(
      children: [
        SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              widgetFactory.createCard(
                width: double.infinity,
                color: Theme.of(context).colorScheme.primaryContainer,
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    widgetFactory.createText(context, widget.platformService.name.localize('English'), style: Theme.of(context).textTheme.titleLarge),
                    const SizedBox(height: 8),
                    widgetFactory.createText(context, widget.platformService.getBasePriceString("ETB"), style: Theme.of(context).textTheme.titleSmall, color: Theme.of(context).colorScheme.tertiary),
                    const SizedBox(height: 16),
                    widgetFactory.createText(context, widget.platformService.description.localize('English'), style: Theme.of(context).textTheme.bodyMedium),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              widgetFactory.createText(context, 'Features', style: Theme.of(context).textTheme.titleMedium),
              const SizedBox(height: 16),
              AppListView(
                shrinkWrap: true,
                items: widget.platformService.features!,
                itemBuilder: (context, feature, index) {
                  return Row(
                    children: [
                      widgetFactory.createIcon(materialIcon: Icons.check_circle, size: 20, color: Theme.of(context).colorScheme.primary),
                      const SizedBox(width: 16),
                      Expanded(child: widgetFactory.createText(context, '${feature.value}', style: Theme.of(context).textTheme.labelMedium)),
                    ],
                  ).withPaddingSymetric(vertical: 4);
                },
              ),
              const SizedBox(height: 32),
              widgetFactory.createText(context, 'Pricing', style: Theme.of(context).textTheme.titleMedium),
              if (widget.platformService.subscriptionRenewalInfo?.isNotEmpty == true) ...[
                const SizedBox(height: 8),
                AppListView(
                  height: 200,
                  shrinkWrap: true,
                  scrollDirection: Axis.horizontal,
                  items: widget.platformService.subscriptionRenewalInfo!,
                  separator: const SizedBox(width: 16),
                  itemBuilder: (context, item, index) {
                    return Obx(
                      () => SubscriptionRenewalListItem(
                        selectedPricingOptionId: platformServiceViewmodel.selectedPricingOptionId,
                        subscriptionRenewal: item,
                        basePrice: widget.platformService.basePrice!,
                        width: 220,
                        onSelected: () {
                          platformServiceViewmodel.updateSelectedPricingOption(item);
                        },
                      ),
                    );
                  },
                ),
              ],
              const SizedBox(height: 32),
              widgetFactory.createText(context, 'Customizations', style: Theme.of(context).textTheme.titleMedium),
              const SizedBox(height: 4),
              if (widget.platformService.customizationCategories?.isNotEmpty == true) ...[
                PlatformServcieCustomizationSelector(
                  customizationCategories: widget.platformService.customizationCategories!,
                  applyDefaultCustomization: !platformServiceViewmodel.isSelectedServiceInEditMode.value,
                  onCustomizationSelected: (selectedCustomizations) {
                    platformServiceViewmodel.addToSelectedCustomization(selectedCustomizations);
                  },
                ),
              ],
              const SizedBox(height: 32),
              Obx(
                () => Row(
                  children: [
                    Expanded(child: widgetFactory.createText(context, platformServiceViewmodel.getTotalPriceForSelectedService, style: Theme.of(context).textTheme.titleLarge)),
                    Expanded(
                      child: widgetFactory.createButton(
                        context: context,
                        content: Text(platformServiceViewmodel.saveOrEditButtonString),
                        onPressed: platformServiceViewmodel.canEnableContinueBtn
                            ? () {
                                platformServiceViewmodel.handleEditOrAddClick(context, widget.platformService);
                              }
                            : null,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
