import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:imela_core/calendar/model/calendar.model.dart';
import 'package:imela_core/calendar/model/calendar_booking.model.dart';
import 'package:imela_core/shared/localized_field.model.dart';
import 'package:imela_pos/ui/calendar/components/calendar_edit_dialog.dart';
import 'package:imela_ui_kit/widget_factory/widget.factory.dart';
import 'package:intl/intl.dart';

class CalendarDetailsDialog extends StatefulWidget {
  final Calendar calendar;
  final String selectedLanguage;
  final WidgetFactory widgetFactory;
  final VoidCallback? onClose;
  final Function(Calendar)? onCalendarUpdated;

  const CalendarDetailsDialog({
    Key? key,
    required this.calendar,
    required this.selectedLanguage,
    required this.widgetFactory,
    this.onClose,
    this.onCalendarUpdated,
  }) : super(key: key);

  @override
  State<CalendarDetailsDialog> createState() => _CalendarDetailsDialogState();
}

class _CalendarDetailsDialogState extends State<CalendarDetailsDialog> {
  bool isEditMode = false;
  
  @override
  Widget build(BuildContext context) {
    if (isEditMode) {
      return CalendarEditDialog(
        calendar: widget.calendar,
        selectedLanguage: widget.selectedLanguage,
      );
    }
    
    final dateFormat = DateFormat('MMM dd, yyyy');
    final theme = Theme.of(context);
    
    return Container(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header with edit button
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  widget.calendar.name?.localize(widget.selectedLanguage) ?? 'Unnamed Calendar',
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold
                  ),
                ),
              ),
              IconButton(
                icon: const Icon(Icons.edit),
                onPressed: () {
                  setState(() {
                    isEditMode = true;
                  });
                },
              ),
            ],
          ),
          
          const SizedBox(height: 24),
          
          // Calendar Info
          _buildInfoSection(
            context,
            title: 'Basic Information',
            items: [
              if (widget.calendar.type != null)
                _buildInfoItem(context, 'Type', widget.calendar.type!),
              if (widget.calendar.product != null)
                _buildInfoItem(context, 'Product', widget.calendar.product!.name?.localize(widget.selectedLanguage) ?? 'Unknown'),
              if (widget.calendar.fromDate != null)
                _buildInfoItem(context, 'Start Date', dateFormat.format(widget.calendar.fromDate!)),
              if (widget.calendar.toDate != null)
                _buildInfoItem(context, 'End Date', dateFormat.format(widget.calendar.toDate!)),
              _buildInfoItem(context, 'Selection Type', _getSelectionTypeLabel(widget.calendar.dateSelectionType)),
            ],
          ),
          
          const SizedBox(height: 16),
          
          // Order Info
          if (widget.calendar.orderInfo != null && widget.calendar.orderInfo!.isNotEmpty)
            _buildInfoSection(
              context,
              title: 'Order Information',
              items: widget.calendar.orderInfo!.map((info) => 
                _buildInfoItem(
                  context, 
                  'Day ${_getDayName(info.dayOfWeek ?? 0)}', 
                  'Max Orders: ${info.maxOrderPerDay}'
                ),
              ).toList(),
            ),
            
          const SizedBox(height: 16),
          
          // Disabled Days
          if (widget.calendar.disabledDays != null && widget.calendar.disabledDays!.isNotEmpty)
            _buildInfoSection(
              context,
              title: 'Disabled Days',
              content: Wrap(
                spacing: 8,
                runSpacing: 8,
                children: widget.calendar.disabledDays!.map((day) =>
                  Chip(
                    label: Text(dateFormat.format(day)),
                    backgroundColor: theme.colorScheme.errorContainer,
                    labelStyle: TextStyle(color: theme.colorScheme.onErrorContainer),
                  ),
                ).toList(),
              ),
            ),
        ],
      ),
    );
  }
  
  Widget _buildInfoSection(BuildContext context, {
    required String title,
    List<Widget>? items,
    Widget? content,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 12),
        
        if (items != null) ...items,
        if (content != null) content,
      ],
    );
  }
  
  Widget _buildInfoItem(BuildContext context, String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              label,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ),
        ],
      ),
    );
  }
  
  String _getSelectionTypeLabel(String? selectionType) {
    if (selectionType == null) return 'Default';
    
    switch (selectionType) {
      case 'SINGLE_DATE':
        return 'Single Date';
      case 'MULTIPLE_DATE':
        return 'Multiple Dates';
      case 'DATE_RANGE':
        return 'Date Range';
      case 'MULTIPLE_DATE_RANGE':
        return 'Multiple Date Ranges';
      default:
        return selectionType;
    }
  }
  
  String _getDayName(int dayOfWeek) {
    const days = ['Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday', 'Sunday'];
    if (dayOfWeek >= 1 && dayOfWeek <= 7) {
      return days[dayOfWeek - 1];
    }
    return '$dayOfWeek';
  }
} 