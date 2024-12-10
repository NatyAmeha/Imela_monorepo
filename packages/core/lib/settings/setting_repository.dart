import 'package:imela_core/settings/model/location.model.dart';
import 'package:imela_core/settings/setting_info.dart';
import 'package:imela_core/shared/repository.intereface.dart';
import 'package:imela_data/database/db_datasource.dart';

import 'package:imela_data/shared_pref/preference_datastore.dart';
import 'package:injectable/injectable.dart';

abstract class ISettingRepository extends IRepository {
  Future<bool> initDB(String dbName);
  Future<bool> setSettingToPrefernece(SettingInfo settingInfo);
  Future<SettingInfo?> getSettingFromPreference(String key);

  Future<bool> saveLocationToDB(String dbName, Location locationInfo);
  Future<List<Location>> getLocationsFromDB(String dbName);
  Future<Location?> getLocationByIdFromDB(String dbName, int id);
}

@Injectable(as: ISettingRepository)
@Named(SettingRepository.injectName)
class SettingRepository implements ISettingRepository {
  static const injectName = 'SettingRepository';

  final ISharedPreferenceDataStore sharedPreferenceDataStore;
  final IDBDataSource dbDataSource;

  SettingRepository({
    @Named(SharedPreferenceDataStore.injectName) required this.sharedPreferenceDataStore,
    @Named(POSDBDataSource.injectName) required this.dbDataSource,
  });

  @override
  Future<bool> initDB(String dbName) async {
    try {
      final dbInstance = await dbDataSource.getDBInstance(dbName);
      return true;
    } catch (e) {
      return false;
    }
  }

  @override
  Future<bool> setSettingToPrefernece(SettingInfo settingInfo) async {
    return await sharedPreferenceDataStore.create(settingInfo.key, settingInfo.value);
  }

  @override
  Future<SettingInfo?> getSettingFromPreference(String key) async {
    return await sharedPreferenceDataStore.get<SettingInfo>(key);
  }

  @override
  Future<bool> saveLocationToDB(String dbName, Location locationInfo) async {
    // final dbInstance = await dbDataSource.getDBInstance(dbName);
    // final existingLocation = await dbDataSource.isDataExist(dbName, dbInstance.locationEntitys, (query) => query.nameEqualTo(locationInfo.name));
    // if (existingLocation) {
    //   return false;
    // }
    // final locationEntity = locationInfo.toLocationEntity();
    // final saveResult = await dbDataSource.save(dbName, dbInstance.locationEntitys, locationEntity);
    // return saveResult > 0;
    return true;
  }

  @override
  Future<List<Location>> getLocationsFromDB(String dbName) async {
    return [];
    // var dIn = await dbDataSource.getDBInstance(dbName);
    // final result = await dbDataSource.getAllData(dbName, dIn.locationEntitys);
    // return result.map((e) => Location.fromLocationEntity(e)).toList();
  }

  @override
  Future<Location?> getLocationByIdFromDB(String dbName, int id) async {
    return null;
    // final dbInstance = await dbDataSource.getDBInstance(dbName);
    // final result = await dbDataSource.getDataById(dbInstance.locationEntitys, id);
    // return result != null ? Location.fromLocationEntity(result) : null;
  }
}
