import 'package:flutter/material.dart';
import 'package:imela_core/staff/model/staff_model.dart';
import 'package:imela_ui_kit/widget_factory/widget.factory.dart';

class StaffListTile extends StatelessWidget {
  final Staff staff;
  final VoidCallback onSelected;
  final WidgetFactory widgetFactory;
  final Function(String) onActionClick;

  const StaffListTile({
    Key? key,
    required this.staff,
    required this.onSelected,
    required this.widgetFactory,
    required this.onActionClick,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: widgetFactory.createText(context, staff.name ?? ''),
      subtitle: widgetFactory.createText(context, staff.phoneNumber ?? ''),
      onTap: onSelected,
      trailing: IconButton(
        icon: const Icon(Icons.more_vert),
        onPressed: () => onActionClick('action'),
      ),
    );
  }
}
