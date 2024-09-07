import 'package:flutter/foundation.dart';
import 'package:imela_data/shared_pref/preference_exception.dart';
import 'package:imela_utils/exception/app_exception.dart';
import 'package:injectable/injectable.dart';
import 'package:shared_preferences/shared_preferences.dart';

abstract class ISharedPreferenceDataStore {
  Future<R> create<R, S>(String path, S body, {Map<String, dynamic>? queryParameters});
  Future<R?> get<R>(String path);
  Future<List<R>> getAll<R>(String path, {Map<String, dynamic>? queryParameters});
  Future<bool> delete(String path);
  Future<bool> removeAllDataFromPreference();
}

@Injectable(as: ISharedPreferenceDataStore)
@Named(SharedPreferenceDataStore.injectName)
class SharedPreferenceDataStore implements ISharedPreferenceDataStore {
  static const injectName = 'SharedPreferenceDataStore';
  @override
  Future<R> create<R, S>(String path, S body, {Map<String, dynamic>? queryParameters}) async {
    try {
      final sharedPref = await SharedPreferences.getInstance();
      switch (S) {
        case const (String):
          final result = await sharedPref.setString(path, body as String);
          return result as R;

        case const (int):
          final result = await sharedPref.setInt(path, body as int);
          return result as R;
        case const (double):
          final result = await sharedPref.setDouble(path, body as double);
          return result as R;

        case const (bool):
          final result = await sharedPref.setBool(path, body as bool);
          return result as R;
        case const (List<String>):
          final result = await sharedPref.setStringList(path, body as List<String>);
          return result as R;
        default:
          return Future.error(AppException(message: 'Trying to save unsupported type to preference'));
      }
    } catch (e) {
      if (kDebugMode) {
        print('exception ${e.toString()}');
      }
      throw PreferenceException(errorMessage: ' Unable to add to preference $path -  ${S.toString()}', source: '');
    }
  }

  @override
  Future<List<R>> getAll<R>(String path, {Map<String, dynamic>? queryParameters}) async {
    try {
      final sharedPref = await SharedPreferences.getInstance();
      switch (R) {
        case const (String):
          final result = sharedPref.getStringList(path);
          if (result == null || result.isEmpty == true) {
            return [];
          } else {
            return result as List<R>;
          }
        default:
          return [];
      }
    } catch (ex) {
      print('exception ${ex.toString()}');
      throw PreferenceException(errorMessage: ' Unable to get data from preference $path', source: '');
    }
  }

  @override
  Future<R?> get<R>(String path) async {
    try {
      final sharedPref = await SharedPreferences.getInstance();
      switch (R) {
        case const (String):
          if (sharedPref.containsKey(path)) {
            final result = sharedPref.getString(path);
            return result as R?;
          } else {
            return null;
          }

        case const (int):
          if (sharedPref.containsKey(path)) {
            final result = sharedPref.getInt(path);
            return result as R?;
          } else {
            return null;
          }

        case const (bool):
          if (sharedPref.containsKey(path)) {
            final result = sharedPref.getBool(path);
            return result as R?;
          } else {
            return null;
          }

        case const (List<String>):
          if (sharedPref.containsKey(path)) {
            final result = sharedPref.getStringList(path);
            return result as R?;
          } else {
            return null;
          }

        default:
          return null;
      }
    } catch (e) {
      print('exception ${e.toString()}');
      throw PreferenceException(errorMessage: ' Unable to get single data from preference $path}', source: '');
    }
  }

  @override
  Future<bool> delete(String path) async {
    try {
      final sharedPref = await SharedPreferences.getInstance();
      final result = await sharedPref.remove(path);
      return result;
    } catch (ex) {
      throw PreferenceException(errorMessage: ' Unable to delete preference $path', source: '');
    }
  }

  @override
  Future<bool> removeAllDataFromPreference() async {
    try {
      final sharedPref = await SharedPreferences.getInstance();
      final result = await sharedPref.clear();
      return result;
    } catch (ex) {
      throw PreferenceException(errorMessage: 'Unable to remove all preference data', source: '');
    }
  }
}
