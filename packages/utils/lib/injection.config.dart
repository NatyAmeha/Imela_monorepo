// GENERATED CODE - DO NOT MODIFY BY HAND

// **************************************************************************
// InjectableConfigGenerator
// **************************************************************************

// ignore_for_file: type=lint
// coverage:ignore-file

// ignore_for_file: no_leading_underscores_for_library_prefixes
import 'package:get_it/get_it.dart' as _i174;
import 'package:imela_utils/location/location_service.dart' as _i582;
import 'package:imela_utils/logger/log_output.service.dart' as _i84;
import 'package:imela_utils/logger/logger.service.dart' as _i173;
import 'package:imela_utils/permission/permission_handler.dart' as _i835;
import 'package:imela_utils/qr_bar_code_service/qrcode_service.dart' as _i196;
import 'package:imela_utils/storage/storage_service.dart' as _i741;
import 'package:imela_utils/storage/storage_usecase.dart' as _i827;
import 'package:injectable/injectable.dart' as _i526;

extension GetItInjectableX on _i174.GetIt {
// initializes the registration of main-scope dependencies inside of GetIt
  _i174.GetIt init({
    String? environment,
    _i526.EnvironmentFilter? environmentFilter,
  }) {
    final gh = _i526.GetItHelper(
      this,
      environment,
      environmentFilter,
    );
    gh.factory<_i84.AppLogFormat>(() => _i84.AppLogFormat());
    gh.factory<_i582.ILocationService>(
      () => _i582.LocationService(),
      instanceName: 'LocationService',
    );
    gh.singleton<_i173.ILogService>(
      () => _i173.AppLogService(),
      instanceName: 'AppLogService',
    );
    gh.factory<_i741.IStorageService>(
      () => _i741.StorageService(),
      instanceName: 'StorageService',
    );
    gh.factory<_i196.IQRCodeService>(
      () => _i196.QRCodeService(),
      instanceName: 'QRCodeServiceImpl',
    );
    gh.factory<_i835.IPermissionHandler>(
      () => _i835.AppPermissionHandler(),
      instanceName: 'AppPermissionHandler',
    );
    gh.factory<_i84.ILogOutput>(
      () => _i84.FileLogOutput(),
      instanceName: 'FileLogOutput',
    );
    gh.factory<_i827.StorageUseCase>(() => _i827.StorageUseCase(
        gh<_i741.IStorageService>(instanceName: 'StorageService')));
    return this;
  }
}
