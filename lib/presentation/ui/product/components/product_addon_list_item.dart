import 'package:dartx/dartx.dart';
import 'package:flutter/material.dart';
import 'package:melegna_customer/domain/product/model/product_addon.model.dart';
import 'package:melegna_customer/domain/shared/localized_field.model.dart';
import 'package:melegna_customer/presentation/resources/colors.dart';
import 'package:melegna_customer/presentation/ui/factory/widget.factory.dart';
import 'package:melegna_customer/presentation/ui/shared/qty_modifier.component.dart';
import 'package:melegna_customer/presentation/utils/date_utils.dart';
import 'package:melegna_customer/presentation/utils/localization_utils.dart';
import 'package:melegna_customer/presentation/utils/widget_extesions.dart';

class ProductAddonListItem extends StatelessWidget {
  final ProductAddon addon;
  final WidgetFactory widgetFactory;
  final AppLanguage locale;
  final DateTimeRange? selectedDateRange;
  final String? selectedSingleOption;
  final double? selectedNumberValue;
  final String? selectedMultipleOptions;
  final Function(String newValue)? onSingleOptionSelection;
  final Function(double newValue)? onNumberInputChanged;

  final Function? onSelectDateClicked;
  const ProductAddonListItem({
    super.key,
    required this.addon,
    this.locale = AppLanguage.ENGLISH,
    required this.widgetFactory,
    this.onSelectDateClicked,
    this.selectedDateRange,
    this.selectedSingleOption,
    this.selectedNumberValue,
    this.selectedMultipleOptions,
    this.onSingleOptionSelection,
    this.onNumberInputChanged,
  });

  double get qty => selectedNumberValue ?? addon.minAmount;

  bool get isAddQtyDisabled => qty >= addon.maxAmount;

  bool get isDeductQtyDisabled => qty <= addon.minAmount;

  Map<String, Widget> get addonOptions => addon.getAddonOptions() ?? {};

  bool get canShowMultiSelection => addon.isMultiSelectionInput && addonOptions.isNotEmpty == true;

  bool get canshowDateTimeInput => addon.isDateTimeInput || addon.isDateInput;

  String get selectedSingleOptionValue => selectedSingleOption ?? addonOptions.keys.first;

  String get selectDateText => selectedDateRange?.toFormattedString() != null ? 'Edit' : 'Select Date';

  @override
  Widget build(BuildContext context) {
    return widgetFactory.createCard(
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                widgetFactory.createText(context, addon.name.localize(), style: Theme.of(context).textTheme.bodyLarge),
                widgetFactory.createText(context, '40 Birr', style: Theme.of(context).textTheme.titleMedium),
              ],
            ),
          ),
          Expanded(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                const SizedBox(height: 8),
                QuantityModifierComponent(
                    width: 150,
                    currentQty: qty,
                    widgetFactory: widgetFactory,
                    addQtyDisabled: isAddQtyDisabled,
                    deductQtyDisabled: isDeductQtyDisabled,
                    onQtyChange: (value) {
                      updateQuantity(value);
                    }).showIfTrue(addon.isNumberInput),
                widgetFactory
                    .createDropDown(
                        context: context,
                        value: selectedSingleOptionValue,
                        options: addonOptions,
                        onChanged: (value) {
                          handleSingleSelection(value);
                        })
                    .showIfTrue(canShowMultiSelection),
                Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    widgetFactory.createText(context, selectedDateRange.toFormattedString(), style: Theme.of(context).textTheme.titleSmall).showIfTrue(selectedDateRange != null),
                    const SizedBox(height: 4),
                    InkWell(
                        onTap: () {
                          onSelectDateClicked?.call();
                        },
                        child: widgetFactory.createText(context, selectDateText, style: Theme.of(context).textTheme.titleSmall, color: ColorManager.blue, textDecoration: TextDecoration.underline).showIfTrue(addon.isDateTimeInput)),
                  ],
                ).showIfTrue(canshowDateTimeInput),
              ],
            ),
          )
        ],
      ),
    );
  }

  void handleSingleSelection(String? value) {
    if (value != null) {
      onSingleOptionSelection?.call(value);
    }
  }

  void updateQuantity(double newQty) {
    if (newQty.inRange(DoubleRange(addon.minAmount, addon.maxAmount))) {
      onNumberInputChanged?.call(newQty);
    }
  }
}
