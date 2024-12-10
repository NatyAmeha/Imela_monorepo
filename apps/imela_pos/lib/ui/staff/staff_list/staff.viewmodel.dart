import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:imela_core/staff/model/staff_model.dart';
import 'package:imela_core/staff/model/staff_response.dart';
import 'package:imela_core/staff/staff_usecase.dart';
import 'package:imela_data/network/graphql/graphql_datasource.dart';
import 'package:imela_pos/app/app_viewmodel.dart';
import 'package:imela_pos/injection.dart';
import 'package:imela_pos/ui/staff/create_staff/create_staff_page.dart';
import 'package:imela_ui_kit/components/modal/app_modal_sheet.dart';
import 'package:imela_utils/exception/app_exception.dart';
import 'package:imela_utils/helpers/base_viewmodel.dart';
import 'package:injectable/injectable.dart';

@injectable
class StaffViewmodel extends GetxController with BaseViewmodel {
  final StaffUsecase staffUsecase;

  StaffViewmodel({required this.staffUsecase});

  static StaffViewmodel getInstance() {
    return BaseViewmodel.isViewmodelRegistered(getIt<StaffViewmodel>());
  }

  // state variables
  var isLoading = false.obs;
  var exception = Rxn<AppException>();
  var staffs = <Staff>[].obs;
  var filteredStaffs = <Staff>[].obs;
  final RxString searchType = 'id'.obs;

  final TextEditingController searchController = TextEditingController();

  // getters
  AppViewmodel get appViewmodel => AppViewmodel.getInstance();
  String get selectedBranchId => appViewmodel.selectedBranchId;

  @override
  void initViewmodel({Map<String, dynamic>? data}) {
    super.initViewmodel(data: data);
    var context = data?['context'] as BuildContext;
    loadStaffs(context);
  }

  void loadStaffs(BuildContext context, {ApiDataFetchPolicy fetchPolicy = ApiDataFetchPolicy.cacheFirst}) async {
    try {
      isLoading.value = true;
      final result = await staffUsecase.getBranchStaff(branchId: selectedBranchId, fetchPolicy: fetchPolicy);

      if (!result.isStaffListFetchSuccess) {
        exception.value = AppException(message: 'Failed to fetch staffs');
        return;
      }
      if (result?.staffs?.isEmpty ?? true) {
        exception.value = AppException(message: 'No staff found', isMainError: true);
        return;
      }
      staffs.value = result!.staffs ?? [];
      filteredStaffs.value = staffs;
    } catch (e) {
      print('error $e');
      // Handle error
      exception.value = AppException(message: 'Failed to fetch staffs');
    } finally {
      isLoading.value = false;
    }
  }

  void addStaff(Staff? staff) {
    if (staff != null) {
      staffs.add(staff);
      filteredStaffs.add(staff);
      filteredStaffs.refresh();
    }
  }

  void onSearchTextChanged(String value) {
    if (value.isEmpty) {
      filteredStaffs.value = staffs;
    } else {
      filteredStaffs.value = staffs.where((staff) {
        return staff.name?.toLowerCase().contains(value.toLowerCase()) ?? false;
      }).toList();
    }
  }

  void navigateToCreateStaff(BuildContext context) {}

  void setSearchType(String? type) {
    if (type != null) {
      searchType.value = type;
      onSearchTextChanged(searchController.text);
    }
  }

  void selectStaff(BuildContext context, Staff staff) {
    // Implement staff selection logic
  }

  void showStaffCreateDialog(BuildContext context) {
    AppModalSheet.showModal(
      context,
      type: AppModalSheetType.DIALOG,
      pages: [
        ModalContent(
          title: Text('Create Staff'),
          content: SizedBox(
            height: MediaQuery.sizeOf(context).height * 0.75,
            child: CreateStaffPage(
              showAppBar: false,
              onStaffCreated: (staff) {
                if (staff != null) {
                  addStaff(staff);
                  AppModalSheet.closeModal();
                  AppViewmodel.getWidgetFactory(context).showFlashMessage(context, message: 'Staff created successfully');
                }
              },
            ),
          ),
        ),
      ],
    );
  }
}
