import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:imela_core/calendar/model/calendar.model.dart';
import 'package:imela_core/calendar/usecase/calendar.usecase.dart';
import 'package:imela_core/product/model/product.model.dart';
import 'package:imela_core/shared/localized_field.model.dart';
import 'package:imela_core/shared/utils/exception_handler.dart';
import 'package:imela_pos/app/app_viewmodel.dart';
import 'package:imela_pos/injection.dart';
import 'package:imela_pos/ui/calendar/components/calendar_details_dialog.dart';
import 'package:imela_ui_kit/components/modal/app_modal_sheet.dart';
import 'package:imela_utils/exception/app_exception.dart';
import 'package:imela_utils/helpers/base_viewmodel.dart';
import 'package:imela_utils/helpers/screen_size_utils.dart';
import 'package:injectable/injectable.dart';

@injectable
class CalendarListViewModel extends GetxController with BaseViewmodel {
  final CalendarUsecase _calendarUsecase;
  final IExceptiionHandler _exceptionHandler;

  CalendarListViewModel({
    required CalendarUsecase calendarUsecase,
    @Named(AppExceptionHandler.injectName) required IExceptiionHandler exceptionHandler,
  })  : _calendarUsecase = calendarUsecase,
        _exceptionHandler = exceptionHandler;

  static CalendarListViewModel getInstance() {
    return BaseViewmodel.isViewmodelRegistered(getIt<CalendarListViewModel>());
  }

  // State variables
  var isLoading = false.obs;
  var exception = Rxn<AppException>();
  var calendars = <Calendar>[].obs;
  var selectedCalendar = Rxn<Calendar>();

  // Search variable
  var searchQuery = ''.obs;
  var searchController = TextEditingController();

  // Getters
  AppViewmodel get appViewmodel => AppViewmodel.getInstance();
  String get selectedLanguage => appViewmodel.selectedLanguage;

  // Get calendars grouped by type
  Map<String, List<Calendar>> get groupedCalendars {
    if (calendars.isEmpty) {
      return {};
    }

    final filtered = _applySearchFilter(calendars);

    // Group calendars by type
    final grouped = <String, List<Calendar>>{};
    for (var calendar in filtered) {
      final type = calendar.type ?? 'Uncategorized';
      if (!grouped.containsKey(type)) {
        grouped[type] = [];
      }
      grouped[type]!.add(calendar);
    }

    return grouped;
  }

  // Apply search filter
  List<Calendar> _applySearchFilter(List<Calendar> list) {
    if (searchQuery.value.isEmpty) {
      return list;
    }

    final query = searchQuery.value.toLowerCase();
    return list.where((calendar) {
      final name = calendar.name?.localize(selectedLanguage).toLowerCase() ?? '';
      final product = calendar.product?.name?.localize(selectedLanguage).toLowerCase() ?? '';
      return name.contains(query) || product.contains(query);
    }).toList();
  }

  // Get human-readable calendar type label
  String getCalendarTypeLabel(String type) {
    switch (type) {
      case 'PRODUCT':
        return 'Product Calendar';
      case 'DELIVERY':
        return 'Delivery Calendar';
      case 'SERVICE':
        return 'Service Calendar';
      default:
        return type.capitalized();
    }
  }

  @override
  void initViewmodel({Map<String, dynamic>? data}) {
    super.initViewmodel(data: data);
    loadCalendars();
  }

  Future<void> loadCalendars() async {
    try {
      isLoading.value = true;
      exception.value = null;

      final response = await _calendarUsecase.getBusinessCalendars(appViewmodel.selectedBusinessId, branchId: appViewmodel.selectedBranchId);

      if (response?.success == true) {
        calendars.value = response!.calendars ?? [];
      } else {
        exception.value = AppException(
          message: response?.message ?? 'Failed to load calendars',
          isMainError: true,
        );
      }
    } catch (e) {
      exception.value = _exceptionHandler.getException(e as Exception);
    } finally {
      isLoading.value = false;
    }
  }

  void selectCalendar(BuildContext context, Calendar calendar) {
    exception.value = null;
    final widgetFactory = AppViewmodel.getWidgetFactory(context);
    selectedCalendar.value = calendar;
    // Only show bottom sheet on small screens
    if (!Responsive.isLargeScreen(context)) {
      AppModalSheet.showModal(
        context,
        type: AppModalSheetType.BOTTOMSHEET,
        pages: [
          ModalContent(
            title: Text(calendar.name?.localize(selectedLanguage) ?? 'Calendar Details'),
            content: CalendarDetailsDialog(
              calendar: calendar,
              selectedLanguage: selectedLanguage,
              widgetFactory: widgetFactory,
              onClose: () {
                // Navigate to edit calendar
                AppModalSheet.closeModal();
              },
            ),
          ),
        ],
      );
    }
  }

  void clearSelection() {
    selectedCalendar.value = null;
  }

  void updateSearchQuery(String query) {
    searchQuery.value = query;
  }

  void clearSearch() {
    searchController.clear();
    searchQuery.value = '';
  }

  void refresh() {
    loadCalendars();
  }

  @override
  void onClose() {
    searchController.dispose();
    super.onClose();
  }
}

extension StringExtension on String {
  String capitalized() {
    return "${this[0].toUpperCase()}${substring(1).toLowerCase()}";
  }
}
