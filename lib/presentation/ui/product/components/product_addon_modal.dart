import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:melegna_customer/domain/product/model/product_addon.model.dart';
import 'package:melegna_customer/presentation/ui/factory/widget.factory.dart';
import 'package:melegna_customer/presentation/ui/product/components/product_addon_list_item.dart';
import 'package:melegna_customer/presentation/ui/product/product_details/product_details.viewmodel.dart';

class ProductAddonModal extends StatelessWidget {
  final WidgetFactory widgetFactory;
  final double width;
  final double height;
  final List<ProductAddon> addons;
  final ScrollController? scrollController;
  final Function? onContinue;
  final ProductDetailsViewmodel productDetailsViewmodel;

  const ProductAddonModal({
    super.key,
    required this.widgetFactory,
    required this.addons,
    this.width = double.infinity,
    this.height = 500,
    this.scrollController,
    this.onContinue,
    required this.productDetailsViewmodel,
  });

  @override
  Widget build(BuildContext context) {
    return widgetFactory.createCard(
      width: width,
      // height: height,
      padding: const EdgeInsets.all(16),
      child: Stack(
        children: [
          Positioned.fill(
            child: SingleChildScrollView(
              controller: scrollController,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  widgetFactory.createText(context, 'Configure your order', style: Theme.of(context).textTheme.headlineMedium),
                  const SizedBox(height: 16),
                  ListView.separated(
                    primary: false,
                    shrinkWrap: true,
                    itemCount: addons.length,
                    itemBuilder: (context, index) {
                      final selectedAddon = addons[index];
                      return Obx(
                        () => ProductAddonListItem(
                          addon: addons[index],
                          selectedDateRange: productDetailsViewmodel.getSelectedDateRange(selectedAddon.id!),
                          selectedSingleOption: productDetailsViewmodel.getSelectedSingleOptionOfAddon(selectedAddon.id!),
                          widgetFactory: widgetFactory,
                          selectedNumberValue: productDetailsViewmodel.getSelectedAddonQty(selectedAddon.id!),
                          onSelectDateClicked: () {
                            productDetailsViewmodel.handleAddonDateSelection(context, addons[index], widgetFactory);
                          },
                          onNumberInputChanged: (newValue) {
                            productDetailsViewmodel.handleProductAddonQtyChange(context, addons[index], value: newValue, widgetFactory: widgetFactory);
                          },
                          onSingleOptionSelection: (newValue) {
                            productDetailsViewmodel.handleProductAddonsingleSelection(context, addons[index], value: newValue, widgetFactory: widgetFactory);
                          },
                        ),
                      );
                    },
                    separatorBuilder: (context, index) => const Divider(height: 24),
                  ),
                ],
              ),
            ),
          ),
          Positioned(
            right: 0,
            left: 0,
            bottom: 16,
            child: Obx(
              () => widgetFactory.createButton(
                context: context,
                content: const Text('Continue'),
                onPressed: productDetailsViewmodel.canEnableAddonContinueBtn
                    ? () {
                        onContinue?.call();
                      }
                    : null,
              ),
            ),
          )
        ],
      ),
    );
  }
}
