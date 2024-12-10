import 'package:collection/collection.dart';
import 'package:flutter/cupertino.dart';
import 'package:imela_core/settings/model/location.model.dart';
import 'package:imela_core/settings/setting_info.dart';
import 'package:imela_core/settings/setting_repository.dart';
import 'package:imela_utils/helpers/localization_utils.dart';
import 'package:imela_utils/location/location_info.dart';
import 'package:imela_utils/location/location_service.dart';
import 'package:imela_utils/permission/permission_handler.dart';
import 'package:imela_utils/permission/permission_info.dart';
import 'package:injectable/injectable.dart';

@injectable
class SettingUsecase {
  final ISettingRepository settingRepository;
  final ILocationService locationService;
  final IPermissionHandler permissionHandler;

  SettingUsecase({
    @Named(SettingRepository.injectName) required this.settingRepository,
    @Named(LocationService.injectName) required this.locationService,
    @Named(AppPermissionHandler.InjectableName) required this.permissionHandler,
  });

  

  Future<bool> saveSelectedLanguage(String language) async {
    final settingInfo = SettingInfo(key: SettingKey.SELECTED_LANGUAGE, value: language);
    return await settingRepository.setSettingToPrefernece(settingInfo);
  }

  Future<String> getSelectedLanguage() async {
    final settingInfo = await settingRepository.getSettingFromPreference(SettingKey.SELECTED_LANGUAGE);
    final value = settingInfo?.value;
    return AppLanguage.values.firstWhereOrNull((element) => element.name == value)?.name ?? AppLanguage.ENGLISH.name;
  }

  Future<PermissionStatusType> handlePermissionRequest(AppPermissionType permission, {Function? permissionDescription}) async {
    final permissionStatus = await permissionHandler.checkPermissionStatus(permission);
    if (permissionStatus.status == PermissionStatusType.granted) {
      return permissionStatus.status;
    } else if (permissionStatus.status == PermissionStatusType.permanentlyDenied) {
      await permissionHandler.openPermissionSettings();
      return permissionStatus.status;
    }

    final permissionResponse = await permissionHandler.requestPermission(permission);
    if (permissionResponse.status == PermissionStatusType.granted) {
      return permissionResponse.status;
    }
    if (permissionResponse.status == PermissionStatusType.denied) {
      permissionDescription?.call();
      return permissionResponse.status;
    } else {
      // Handle permission denial
      print('Permission denied: ${permissionResponse.message}');
      return permissionResponse.status;
    }
  }

  Future<AppLatLng> getCurrentLocation() async {
    final permissionStatus = await handlePermissionRequest(AppPermissionType.location);
    if (permissionStatus == PermissionStatusType.granted) {
      return locationService.getCurrentLocation();
    }
    return AppLatLng(0, 0);
  }

  Future<String> getAddress(AppLatLng latLng) {
    return locationService.getAddressFromLatLng(latLng);
  }

  Future<List<SearchResult>> searchPlaces(String query) {
    return locationService.searchPlaces(query);
  }

  void setMapController(dynamic controller) {
    locationService.setMapController(controller);
  }

  Future<List<Location>> getUserSavedLocations(String dbName) async {
    return await settingRepository.getLocationsFromDB(dbName);
  }

  Future<Location?> getLocationByIdFromDB(String dbName, int id) async {
    return await settingRepository.getLocationByIdFromDB(dbName, id);
  }

  Future<bool> saveUserLocation(Location location, String dbName) async {
    return await settingRepository.saveLocationToDB(dbName, location);
  }
}
