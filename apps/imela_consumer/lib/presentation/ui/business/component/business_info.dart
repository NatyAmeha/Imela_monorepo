import 'package:flutter/material.dart';
import 'package:imela_core/branch/model/branch.model.dart';
import 'package:imela_core/business/model/business.model.dart';
import 'package:imela_core/shared/localized_field.model.dart';
import 'package:imela_ui_kit/helpers/widget_extesions.dart';
import 'package:imela_ui_kit/widget_factory/widget.factory.dart';

class BusinessInfoDialog extends StatelessWidget {
  final Business business;
  final List<Branch> branches;
  final WidgetFactory widgetFactory;
  final Function? onBranchSelected;
  final Function? onClose;
  const BusinessInfoDialog({super.key, required this.business, required this.widgetFactory, this.branches = const [], this.onBranchSelected, this.onClose});

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [ 
        Positioned.fill(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                widgetFactory.createText(context, business.name.localize('ENGLISH'), style: Theme.of(context).textTheme.displaySmall),
                const SizedBox(height: 8),
                widgetFactory.createText(context, business.description.localize('ENGLISH'), style: Theme.of(context).textTheme.labelLarge),
                widgetFactory.createListTile(title: const Text('email'), subtitle: Text('${business.email}'), leading: widgetFactory.createIcon(materialIcon: Icons.email)),
                widgetFactory.createListTile(title: const Text('Phone number'), subtitle: Text('${business.phoneNumber}'), leading: widgetFactory.createIcon(materialIcon: Icons.phone)),
                widgetFactory.createListTile(title: const Text('Address'), subtitle: Text('${business.mainAddress?.city}'), leading: widgetFactory.createIcon(materialIcon: Icons.location_on)),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    widgetFactory.createText(context, 'Branches', style: Theme.of(context).textTheme.headlineMedium),
                    ...branches.map(
                      (branch) => widgetFactory.createListTile(
                        title: Text(branch.name?.localize('ENGLISH') ?? ''),
                        subtitle: Text(branch.getAddressInfo).showIfTrue(branch.getAddressInfo.isNotEmpty),
                        leading: widgetFactory.createIcon(materialIcon: Icons.business),
                      ),
                    ),
                  ],
                ).showIfTrue(branches.isNotEmpty),
              ],
            ),
          ),
        ),
        Positioned(
          top: 16,
          right: 16,
          child: widgetFactory.createIcon(
            materialIcon: Icons.close,
            size: 30,
            onPressed: () {
              onClose?.call();
            },
          ),
        ),
      ],
    );
  }
}
