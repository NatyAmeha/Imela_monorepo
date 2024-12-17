import 'package:flutter/material.dart';
import 'package:imela_core/order/model/order.model.dart';
import 'package:imela_ui_kit/components/badge/badge_list.dart';
import 'package:imela_ui_kit/helpers/pop_up_menu_data.dart';
import 'package:imela_ui_kit/helpers/widget_extesions.dart';
import 'package:imela_ui_kit/widget_factory/widget.factory.dart';
import 'package:intl/intl.dart';

class OrderListItem extends StatelessWidget {
  final Order order;
  final String statusMsg;
  final Function onTap;
  final List<PopupMenuItemData<String>> actions;
  final Function(String selectedValue) onActionClick;
  final WidgetFactory widgetFactory;
  final bool isSelected;

  const OrderListItem({
    Key? key,
    required this.order,
    required this.statusMsg,
    required this.onTap,
    required this.onActionClick,
    required this.widgetFactory,
    this.isSelected = false,
    this.actions = const [],
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    Color color = isSelected ? Theme.of(context).colorScheme.primary : Colors.transparent;
    return widgetFactory.createCard(
        border: Border.all(color: color),
        color: color,
        onTap: () {
          onTap.call();
        },
        padding: const EdgeInsets.all(8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                widgetFactory.createText(
                  context,
                  'Order #${order.code ?? 'N/A'}',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(width: 8),
                BadgeList(
                  colors: [_getStatusColor()],
                  widgetFactory: widgetFactory,
                  values: [statusMsg],
                ),
              ],
            ),
            widgetFactory.createText(
              context,
              'Date: ${_formatDate(order.createdAt)}',
              style: Theme.of(context).textTheme.bodySmall,
            ),
            const SizedBox(height: 4),
            widgetFactory.createText(
              context,
              'Total: ${order.totalAmountString('USD', 'en')}',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w500),
            ),
            const SizedBox(height: 8),
          ],
        ));
  }

  Color _getStatusColor() {
    switch (order.status?.toLowerCase()) {
      case 'pending':
        return Colors.orange;
      case 'processing':
        return Colors.blue;
      case 'completed':
        return Colors.green;
      case 'cancelled':
        return Colors.red;
      case 'refunded':
        return Colors.purple;
      case 'failed':
        return Colors.red.shade800;
      default:
        return Colors.grey;
    }
  }

  String _formatDate(DateTime? date) {
    if (date == null) return 'N/A';
    return DateFormat('MMM dd, yyyy HH:mm').format(date);
  }
}
