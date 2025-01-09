import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:imela/l10n/l10n.dart';
import 'package:imela/presentation/ui/app_controller.dart';
import 'package:imela_core/branch/model/branch.model.dart';
import 'package:imela_core/business/model/business.model.dart';
import 'package:imela_core/shared/localized_field.model.dart';
import 'package:imela_ui_kit/components/image/markdown_text.dart';
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
    final appController = AppController.getInstance;
    return Stack(
      children: [
        Positioned.fill(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                widgetFactory.createText(context, business.name.localize(appController.getAppContext().l10n.selectedLanguage), style: Theme.of(context).textTheme.headlineMedium).paddingSymmetric(vertical: 10),
                const SizedBox(height: 8),
                if (business.description?.isNotEmpty == true) MarkdownText(data: business.description.localize(appController.getAppContext().l10n.selectedLanguage), maxHeight: 400),
                const Divider(height: 24),
                widgetFactory.createText(context, appController.getAppContext().l10n.addressAndContact, style: Theme.of(context).textTheme.headlineSmall),
                widgetFactory.createListTile(
                  title: Text(appController.getAppContext().l10n.email), 
                  subtitle: Text('${business.email}'), 
                  leading: widgetFactory.createIcon(materialIcon: Icons.email), 
                  onTap: () {}
                ),
                widgetFactory.createListTile(
                  title: Text(appController.getAppContext().l10n.phoneNumber), 
                  subtitle: Text('${business.phoneNumber}'), 
                  leading: widgetFactory.createIcon(materialIcon: Icons.phone), 
                  onTap: () {}
                ),
                widgetFactory.createListTile(
                  title: Text(appController.getAppContext().l10n.address), 
                  subtitle: Text('${business.mainAddress?.city}'), 
                  leading: widgetFactory.createIcon(materialIcon: Icons.location_on), 
                  onTap: () {}
                ),
                const Divider(height: 24),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    widgetFactory.createText(context, appController.getAppContext().l10n.branches, style: Theme.of(context).textTheme.headlineSmall),
                    ...branches.map(
                      (branch) => widgetFactory.createListTile(
                        title: Text(branch.name?.localize(appController.getAppContext().l10n.selectedLanguage) ?? ''),
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
