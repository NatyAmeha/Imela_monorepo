import 'package:easy_debounce/easy_debounce.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:imela/injection.dart';
import 'package:imela/presentation/ui/app_controller.dart';
import 'package:imela_core/settings/model/location.model.dart';
import 'package:imela_core/settings/setting_usecase.dart';
import 'package:imela_core/shared/utils/exception_handler.dart';
import 'package:imela_utils/exception/app_exception.dart';
import 'package:imela_utils/helpers/base_viewmodel.dart';
import 'package:imela_utils/location/location_info.dart';
import 'package:injectable/injectable.dart';

@injectable
class LocationViewmodel extends GetxController with BaseViewmodel {
  // final OrderUsecase orderUsecase;
  final IExceptiionHandler exceptiionHandler;
  final SettingUsecase settingUsecase;

  var searchInputController = TextEditingController();

  LocationViewmodel({
    required this.settingUsecase,
    @Named(AppExceptionHandler.injectName) required this.exceptiionHandler,
  });

  static LocationViewmodel getInstance() {
    return BaseViewmodel.isViewmodelRegistered(getIt<LocationViewmodel>());
  }

  // state variables
  var isLoading = false.obs;
  var exception = Rxn<AppException>();

  Rx<AppLatLng> currentLocation = AppLatLng(0, 0).obs;
  Rx<SearchResult> selectedLocation = SearchResult(location: AppLatLng(0, 0), name: '').obs;
  RxString currentAddress = ''.obs;
  RxList<SearchResult> searchResults = <SearchResult>[].obs;

  AppController get appController => AppController.getInstance;

  @override
  void initViewmodel({Map<String, dynamic>? data}) async {
    super.initViewmodel(data: data);
    await getCurrentLocation();
  }

  Future<void> getCurrentLocation() async {
    AppLatLng location = await settingUsecase.getCurrentLocation();
    currentLocation.value = location;
    selectedLocation.value = SearchResult(location: location, name: '');
    await getAddress(location);
  }

  Future<void> getAddress(AppLatLng latLng) async {
    String address = await settingUsecase.getAddress(latLng);
    currentAddress.value = address;
  }

  Future<void> searchPlaces(String? query) async {
    try {
      isLoading(true);
      EasyDebounce.debounce('searchPlaces', const Duration(milliseconds: 500), () async {
        if (query == null || query.isEmpty) {
          searchResults.clear();
          return;
        }
        List<SearchResult> results = await settingUsecase.searchPlaces(query);
        searchResults.assignAll(results);
        isLoading(false);
      });
    } catch (ex) {
      print("exception $ex");
      isLoading(false);
    } 
  }

  void onMapCreated(dynamic controller) {
    settingUsecase.setMapController(controller);
  }

  Future<void> selectLocation(BuildContext context, SearchResult result) async {
    selectedLocation.value = result;
  }

  Future<Location> confirmLocation(BuildContext context) async {
    final locationInfo = Location(name: selectedLocation.value.name, latLng: selectedLocation.value.location);
    return locationInfo;
  }

  void clearInput() {
    searchResults.clear();
    searchInputController.clear();
  }
}
