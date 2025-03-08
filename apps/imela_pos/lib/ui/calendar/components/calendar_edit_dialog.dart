import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:imela_core/calendar/model/calendar.model.dart';
import 'package:imela_core/calendar/model/calendar_booking.model.dart';
import 'package:imela_core/shared/localized_field.model.dart';
import 'package:imela_pos/app/app_viewmodel.dart';
import 'package:imela_pos/injection.dart';
import 'package:imela_pos/ui/calendar/calendar_edit.viewmodel.dart';
import 'package:imela_ui_kit/components/page_loading_utils/page_content_loader.dart';
import 'package:imela_ui_kit/widget_factory/widget.factory.dart';
import 'package:intl/intl.dart';

class CalendarEditDialog extends StatefulWidget {
  final Calendar calendar;
  final String selectedLanguage;
  final Function(Calendar)? onCalendarUpdated;

  const CalendarEditDialog({
    Key? key,
    required this.calendar,
    required this.selectedLanguage,
    this.onCalendarUpdated,
  }) : super(key: key);

  @override
  State<CalendarEditDialog> createState() => _CalendarEditDialogState();
}

class _CalendarEditDialogState extends State<CalendarEditDialog> {
  late CalendarEditViewModel viewmodel;
  late WidgetFactory widgetFactory;
  final dateFormat = DateFormat('MMM dd, yyyy');

  @override
  void initState() {
    super.initState();
    widgetFactory = AppViewmodel.getWidgetFactory(context);
    viewmodel = getIt<CalendarEditViewModel>();
    viewmodel.initViewmodel(data: {
      'calendar': widget.calendar,
      'context': context,
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      child: Obx(
        () => PageContentLoader(
          isLoading: viewmodel.isLoading.value,
          exception: viewmodel.exception.value,
          hasError: viewmodel.exception.value?.isMainError ?? false,
          onTryAgain: () {
            if (widget.calendar.id != null) {
              viewmodel.loadCalendarSchedules(context, widget.calendar.id!);
            }
          },
          content: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header with Save and Cancel buttons
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        widget.calendar.name?.localize(widget.selectedLanguage) ?? 'Edit Calendar',
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold
                        ),
                      ),
                    ),
                    Row(
                      children: [
                        // Discard button
                        OutlinedButton(
                          onPressed: () => viewmodel.discardChanges(context),
                          child: const Text('Cancel'),
                        ),
                        const SizedBox(width: 8),
                        // Save button
                        Obx(() => widgetFactory.createButton(
                          context: context,
                          content: const Text('Save Changes'),
                          isLoading: viewmodel.isSaving.value,
                          onPressed: () => viewmodel.saveCalendar(context),
                        )),
                      ],
                    ),
                  ],
                ),
                
                const SizedBox(height: 24),
                
                // Calendar date range
                _buildDateRangeSection(),
                
                const SizedBox(height: 24),
                
                // Disabled dates section
                _buildDisabledDatesSection(),
                
                const SizedBox(height: 24),
                
                // Order info section
                _buildOrderInfoSection(),
              ],
            ),
          ),
        ),
      ),
    );
  }
  
  Widget _buildDateRangeSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Date Range',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            IconButton(
              icon: const Icon(Icons.edit),
              onPressed: () => viewmodel.updateDateRange(context),
              tooltip: 'Edit Date Range',
            ),
          ],
        ),
        const SizedBox(height: 8),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surfaceVariant.withOpacity(0.3),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('From'),
                  const SizedBox(height: 4),
                  Obx(() => Text(
                    viewmodel.fromDate.value != null 
                        ? dateFormat.format(viewmodel.fromDate.value!)
                        : 'Not set',
                    style: Theme.of(context).textTheme.titleMedium,
                  )),
                ],
              ),
              const Icon(Icons.arrow_forward),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  const Text('To'),
                  const SizedBox(height: 4),
                  Obx(() => Text(
                    viewmodel.toDate.value != null 
                        ? dateFormat.format(viewmodel.toDate.value!)
                        : 'Not set',
                    style: Theme.of(context).textTheme.titleMedium,
                  )),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }
  
  Widget _buildDisabledDatesSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Disabled Dates',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            IconButton(
              icon: const Icon(Icons.add),
              onPressed: () => viewmodel.addDisabledDates(context),
              tooltip: 'Add Disabled Dates',
            ),
          ],
        ),
        const SizedBox(height: 8),
        Obx(() {
          if (viewmodel.disabledDates.isEmpty) {
            return Card(
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                child: const Text('No disabled dates'),
              ),
            );
          }
          
          return Wrap(
            spacing: 8,
            runSpacing: 8,
            children: viewmodel.disabledDates.map((date) => 
              Chip(
                label: Text(dateFormat.format(date)),
                deleteIcon: const Icon(Icons.close, size: 18),
                onDeleted: () => viewmodel.removeDisabledDate(date),
              ),
            ).toList(),
          );
        }),
      ],
    );
  }
  
  Widget _buildOrderInfoSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Scheduling Rules',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            Obx(() => IconButton(
              icon: const Icon(Icons.add),
              onPressed: viewmodel.availableDaysForOrderInfo.isEmpty 
                  ? null 
                  : () => viewmodel.addOrderInfo(context),
              tooltip: 'Add Day Rule',
            )),
          ],
        ),
        const SizedBox(height: 8),
        Obx(() {
          if (viewmodel.orderInfoList.isEmpty) {
            return Card(
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                child: const Text('No scheduling rules defined'),
              ),
            );
          }
          
          return ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: viewmodel.orderInfoList.length,
            itemBuilder: (context, index) {
              final orderInfo = viewmodel.orderInfoList[index];
              return Card(
                margin: const EdgeInsets.only(bottom: 8),
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              viewmodel.getDayName(orderInfo.dayOfWeek ?? 1),
                              style: Theme.of(context).textTheme.titleMedium,
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Max orders per day: ${orderInfo.maxOrderPerDay}',
                              style: Theme.of(context).textTheme.bodyMedium,
                            ),
                            Text(
                              'Max orders per hour: ${orderInfo.maxOrderPerHour}',
                              style: Theme.of(context).textTheme.bodyMedium,
                            ),
                          ],
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.edit),
                        onPressed: () => viewmodel.editOrderInfo(context, orderInfo),
                        tooltip: 'Edit Rule',
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete),
                        onPressed: () => viewmodel.removeOrderInfo(orderInfo),
                        tooltip: 'Remove Rule',
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        }),
      ],
    );
  }
} 