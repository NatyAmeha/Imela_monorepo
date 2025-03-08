import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:imela_core/calendar/model/calendar.model.dart';
import 'package:imela_core/shared/localized_field.model.dart';
import 'package:imela_pos/app/app_viewmodel.dart';
import 'package:imela_pos/injection.dart';
import 'package:imela_pos/ui/calendar/calendar_list.viewmodel.dart';
import 'package:imela_pos/ui/calendar/components/calendar_details_dialog.dart';
import 'package:imela_ui_kit/components/modal/app_modal_sheet.dart';
import 'package:imela_ui_kit/components/page_loading_utils/page_content_loader.dart';
import 'package:imela_ui_kit/widget_factory/widget.factory.dart';
import 'package:imela_utils/helpers/screen_size_utils.dart';
import 'package:intl/intl.dart';

class CalendarListPage extends StatefulWidget {
  static const routeName = '/calendar-list';

  const CalendarListPage({Key? key}) : super(key: key);

  @override
  State<CalendarListPage> createState() => _CalendarListPageState();

  static void navigate(BuildContext context) {
    final router = AppViewmodel.getInstance().appRouter;
    router.navigateTo(context, routeName);
  }
}

class _CalendarListPageState extends State<CalendarListPage> {
  late CalendarListViewModel viewmodel;
  late WidgetFactory widgetFactory;

  @override
  void initState() {
    super.initState();
    widgetFactory = AppViewmodel.getWidgetFactory(context);
    viewmodel = getIt<CalendarListViewModel>();
    viewmodel.initViewmodel();
  }

  @override
  Widget build(BuildContext context) {
    final isLargeScreen = Responsive.isLargeScreen(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Calendar Management'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: viewmodel.refresh,
          ),
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () {
              // Navigate to add calendar page
            },
          ),
        ],
      ),
      body: Obx(
        () => PageContentLoader(
          isLoading: viewmodel.isLoading.value,
          exception: viewmodel.exception.value,
          hasError: viewmodel.exception.value?.isMainError ?? false,
          onTryAgain: viewmodel.refresh,
          content: Row(
            children: [
              // Calendars List (Left Side)
              Expanded(
                flex: isLargeScreen ? 3 : 5,
                child: Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: _buildSearchBar(),
                    ),
                    Expanded(
                      child: _buildCalendarList(),
                    ),
                  ],
                ),
              ),

              // Details Panel (Right Side) - Only shown on large screens
              if (isLargeScreen)
                Expanded(
                  flex: 2,
                  child: Obx(() {
                    if (viewmodel.selectedCalendar.value == null) {
                      return const Center(
                        child: Text('Select a calendar to view details'),
                      );
                    }

                    return widgetFactory.createCard(
                      border: Border(
                        left: BorderSide(color: Theme.of(context).dividerColor),
                      ),
                      child: CalendarDetailsDialog(
                        calendar: viewmodel.selectedCalendar.value!,
                        selectedLanguage: viewmodel.selectedLanguage,
                        widgetFactory: widgetFactory,
                        onClose: viewmodel.clearSelection,
                        // onEdit: () {
                        //   viewmodel.selectCalendar(context, viewmodel.selectedCalendar.value!);
                        //   // Navigate to edit calendar
                        // },
                      ),
                    );
                  }),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSearchBar() {
    return TextField(
      controller: viewmodel.searchController,
      decoration: InputDecoration(
        hintText: 'Search calendars...',
        prefixIcon: const Icon(Icons.search),
        suffixIcon: Obx(() => viewmodel.searchQuery.value.isNotEmpty
            ? IconButton(
                icon: const Icon(Icons.clear),
                onPressed: viewmodel.clearSearch,
              )
            : const SizedBox.shrink()),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide.none,
        ),
        filled: true,
        fillColor: Theme.of(context).colorScheme.surfaceVariant.withOpacity(0.3),
        contentPadding: const EdgeInsets.symmetric(vertical: 0),
      ),
      onChanged: viewmodel.updateSearchQuery,
    );
  }

  Widget _buildCalendarList() {
    final grouped = viewmodel.groupedCalendars;

    if (grouped.isEmpty) {
      return const Center(
        child: Text('No calendars found'),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      itemCount: grouped.length,
      itemBuilder: (context, index) {
        final type = grouped.keys.elementAt(index);
        final calendars = grouped[type]!;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 8),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  viewmodel.getCalendarTypeLabel(type),
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                ),
              ),
            ),
            ListView.builder(
              physics: const NeverScrollableScrollPhysics(),
              shrinkWrap: true,
              itemCount: calendars.length,
              itemBuilder: (context, i) => _buildCalendarItem(calendars[i]),
            ),
          ],
        );
      },
    );
  }

  Widget _buildCalendarItem(Calendar calendar) {
    final dateFormat = DateFormat('MMM dd, yyyy');

    return Obx(
      () {
        final isSelected = viewmodel.selectedCalendar.value?.id == calendar.id;
        return widgetFactory.createCard(
          elevation: isSelected ? 3 : 1,
          margin: const EdgeInsets.only(bottom: 12, left: 4, right: 4),
          color: isSelected ? Theme.of(context).colorScheme.primaryContainer : Theme.of(context).cardColor,
          borderRadius: BorderRadius.circular(8),
          border: isSelected ? Border.all(color: Theme.of(context).colorScheme.primary, width: 2) : Border.all(color: Colors.transparent, width: 0),
          child: InkWell(
            onTap: () {
              viewmodel.selectCalendar(context, calendar);
            },
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Title and Icons
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          calendar.name?.localize(viewmodel.selectedLanguage) ?? 'Unnamed Calendar',
                          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                        ),
                      ),
                      if (calendar.product != null)
                        Tooltip(
                          message: 'Product: ${calendar.product!.name?.localize(viewmodel.selectedLanguage) ?? 'Unknown'}',
                          child: const Padding(
                            padding: EdgeInsets.all(4.0),
                            child: Icon(Icons.shopping_bag_outlined, size: 18),
                          ),
                        ),
                      Tooltip(
                        message: 'Selection: ${calendar.dateSelectionType ?? "Single"}',
                        child: Padding(
                          padding: const EdgeInsets.all(4.0),
                          child: Icon(_getSelectionTypeIcon(calendar.dateSelectionType), size: 18),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 12),

                  // Date Range
                  Row(
                    children: [
                      const Icon(Icons.calendar_today, size: 16),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          _getDateRangeText(calendar, dateFormat),
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                      ),
                    ],
                  ),

                  // Order Info summary if available
                  if (calendar.orderInfo != null && calendar.orderInfo!.isNotEmpty) ...[
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        const Icon(Icons.event_available, size: 16),
                        const SizedBox(width: 8),
                        Text(
                          '${calendar.orderInfo!.length} Scheduling Rule${calendar.orderInfo!.length > 1 ? 's' : ''}',
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                      ],
                    ),
                  ],
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  String _getDateRangeText(Calendar calendar, DateFormat formatter) {
    if (calendar.fromDate != null && calendar.toDate != null) {
      return '${formatter.format(calendar.fromDate!)} - ${formatter.format(calendar.toDate!)}';
    } else if (calendar.fromDate != null) {
      return 'From ${formatter.format(calendar.fromDate!)}';
    } else if (calendar.toDate != null) {
      return 'Until ${formatter.format(calendar.toDate!)}';
    }
    return 'No date range set';
  }

  IconData _getSelectionTypeIcon(String? selectionType) {
    switch (selectionType) {
      case 'SINGLE_DATE':
        return Icons.calendar_today;
      case 'MULTIPLE_DATE':
        return Icons.calendar_view_day;
      case 'DATE_RANGE':
        return Icons.date_range;
      case 'MULTIPLE_DATE_RANGE':
        return Icons.view_week;
      default:
        return Icons.calendar_today;
    }
  }
}
