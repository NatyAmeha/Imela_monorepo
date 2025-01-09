import 'package:flutter/material.dart';
import 'package:imela/l10n/l10n.dart';
import 'package:imela/presentation/resources/colors.dart';
import 'package:imela/presentation/ui/app_controller.dart';
import 'package:imela_core/membership/model/membership.model.dart';
import 'package:imela_core/shared/localized_field.model.dart';
import 'package:imela_ui_kit/components/list/listview.component.dart';
import 'package:imela_ui_kit/helpers/button_style.dart';
import 'package:imela_ui_kit/helpers/widget_extesions.dart';

class MembershipListItem extends StatelessWidget {
  final Membership membershipInfo;
  final double width;
  final Color bgColor;
  final double? height;
  final String selectedLanguage;
  final Function? onTap;
  const MembershipListItem({
    super.key,
    required this.membershipInfo,
    this.width = double.infinity,
    this.bgColor = ColorManager.primary,
    this.height,
    this.selectedLanguage = 'ENGLISH',
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    var widgetFactory = AppController.getInstance.getWidgetFactory(context);
    return widgetFactory.createCard(
      border: Border.all(color: Theme.of(context).primaryColor),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          widgetFactory.createCard(
            color: bgColor,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(8)),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                widgetFactory.createText(context, membershipInfo.name.localize(selectedLanguage), color: Colors.white, style: Theme.of(context).textTheme.titleMedium),
                const SizedBox(height: 4),
                widgetFactory.createText(context, membershipInfo.description.localize(selectedLanguage), color: Colors.white, style: Theme.of(context).textTheme.bodyMedium),
              ],
            ),
          ),
          const SizedBox(height: 16),
          widgetFactory.createText(context, '${AppController.getInstance.getAppContext().l10n.benefits} ', style: Theme.of(context).textTheme.titleSmall).withPaddingSymetric(horizontal: 16),
          AppListView(
            shrinkWrap: true,
            items: membershipInfo.benefits,
            itemBuilder: (context, item, index) {
              return widgetFactory.createListTile(
                leading: widgetFactory.createIcon(materialIcon: Icons.check_circle, color: Colors.green),
                title: Text(item.name.localize(selectedLanguage), style: Theme.of(context).textTheme.bodyMedium),
              );
            },
          ),
          const SizedBox(height: 16),
          widgetFactory
              .createButton(
                context: context,
                content: const Text('View Details'),
                style: AppButtonStyle.outlinedButtonStyle(context, borderRadius: 24),
                onPressed: () => onTap?.call(),
              )
              .withPaddingAll(16)
        ],
      ),
    );
  }
}
