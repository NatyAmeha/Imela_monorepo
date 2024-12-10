import 'package:flutter/material.dart';
import 'package:imela_core/order/model/order.model.dart';
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
    Color color = isSelected ? Theme.of(context).colorScheme.primary : Theme.of(context).colorScheme.primaryContainer;
    return widgetFactory.createCard(
      border: Border.all(color: color),
      onTap: () {
        onTap.call();
      },
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          _buildOrderInfo(context),
          const Spacer(),
          _buildOrderStatus(context),
          const SizedBox(width: 16),
          if (actions.isNotEmpty)
            widgetFactory.createPopupMenu(
              context: context,
              items: actions,
              onSelected: (value) {
                onActionClick(value);
              },
              child: const Icon(Icons.more_vert),
            ),
        ],
      ).withPaddingAll(16),
    );
  }

  Widget _buildOrderInfo(BuildContext context) {
    return Expanded(
      flex: 3,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          widgetFactory.createText(
            context,
            'Order #${order.orderNumber ?? 'N/A'}',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
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
        ],
      ),
    );
  }

  Widget _buildOrderStatus(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: _getStatusColor(),
        borderRadius: BorderRadius.circular(20),
      ),
      child: widgetFactory.createText(
        context,
        statusMsg,
        style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
      ),
    );
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
