import 'package:flutter/material.dart';
import 'package:imela_core/customer/model/customer.model.dart';
import 'package:imela_core/membership/model/group.model.dart';
import 'package:imela_ui_kit/helpers/widget_extesions.dart';
import 'package:imela_ui_kit/widget_factory/widget.factory.dart';

class MemberListItem extends StatelessWidget {
  final Customer customer;
  final GroupMember memberInfo;

  final Function? onTap;
  final WidgetFactory widgetFactory;

  const MemberListItem({
    super.key,
    required this.customer,
    required this.memberInfo,
    required this.widgetFactory,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return widgetFactory.createCard(
      border: Border.all(color: Theme.of(context).colorScheme.primaryContainer, width: 1),
      borderRadius: BorderRadius.circular(8),
      child: Stack(
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  widgetFactory.createIcon(
                    materialIcon: Icons.person,
                    size: 40,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        widgetFactory.createText(
                          context,
                          customer.name,
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                        const SizedBox(height: 4),
                        widgetFactory.createText(
                          context,
                          customer.phoneNumber ?? 'No phone number',
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  widgetFactory.createIcon(materialIcon: Icons.email, size: 16),
                  const SizedBox(width: 4),
                  widgetFactory.createText(
                    context,
                    customer.email ?? 'No email',
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ],
              ),
              const SizedBox(height: 4),
              Row(
                children: [
                  widgetFactory.createIcon(materialIcon: Icons.location_on, size: 16),
                  const SizedBox(width: 4),
                  widgetFactory.createText(
                    context,
                    customer.email ?? 'No email',
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ],
              ),
            ],
          ).withPaddingSymetric(vertical: 12, horizontal: 16),
          Positioned(
            right: 8,
            top: 8,
            child: Chip(label: Text(memberInfo.memberStatus ?? ''), backgroundColor: Theme.of(context).colorScheme.primary),
          ),
        ],
      ),
      onTap: () {
        onTap?.call();
      },
    );
  }
}
