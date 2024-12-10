import 'package:imela_utils/permission/permission_info.dart';
import 'package:injectable/injectable.dart';
import 'package:permission_handler/permission_handler.dart';

abstract class IPermissionHandler {
  Future<PermissionResponse> requestPermission(AppPermissionType permission);
  Future<PermissionResponse> checkPermissionStatus(AppPermissionType permission);
  Future<bool> openPermissionSettings();
  Future<bool> shouldShowRequestRationale(AppPermissionType permission);
}

@Injectable(as: IPermissionHandler)
@Named(AppPermissionHandler.InjectableName)
class AppPermissionHandler implements IPermissionHandler {
  static const InjectableName = 'AppPermissionHandler';
  @override
  Future<PermissionResponse> requestPermission(AppPermissionType permission) async {
    final mappedPermission = _getPermission(permission);
    if (mappedPermission == null) {
      return PermissionResponse(
        status: PermissionStatusType.unknown,
        message: 'Unknown permission type',
        isGranted: false,
      );
    }
    final status = await mappedPermission.request();
    return _createPermissionResponse(status);
  }

  @override
  Future<PermissionResponse> checkPermissionStatus(AppPermissionType permission) async {
    final mappedPermission = _getPermission(permission);
    if (mappedPermission == null) {
      return PermissionResponse(
        status: PermissionStatusType.unknown,
        message: 'Unknown permission type',
        isGranted: false,
      );
    }
    final status = await mappedPermission.status;
    return _createPermissionResponse(status);
  }

  @override
  Future<bool> openPermissionSettings() async {
    final result = await openAppSettings();
    return result;
  }

  @override
  Future<bool> shouldShowRequestRationale(AppPermissionType permission) async {
    final mappedPermission = _getPermission(permission);
    if (mappedPermission == null) return false;
    return await mappedPermission.shouldShowRequestRationale;
  }

  /// Maps the custom `AppPermissionType` to the `Permission` type from the `permission_handler` package
  Permission? _getPermission(AppPermissionType appPermissionType) {
    switch (appPermissionType) {
      case AppPermissionType.camera:
        return Permission.camera;
      case AppPermissionType.storage:
        return Permission.storage;
      case AppPermissionType.location:
        return Permission.location;
      case AppPermissionType.microphone:
        return Permission.microphone;
      case AppPermissionType.contacts:
        return Permission.contacts;
      case AppPermissionType.photos:
        return Permission.photos;
      default:
        return null; // Handle unsupported permissions
    }
  }

  /// Helper method to create a `PermissionResponse` from `PermissionStatus`
  PermissionResponse _createPermissionResponse(PermissionStatus status) {
    switch (status) {
      case PermissionStatus.granted:
        return PermissionResponse(
          status: PermissionStatusType.granted,
          message: 'Permission granted.',
          isGranted: true,
        );
      case PermissionStatus.denied:
        return PermissionResponse(
          status: PermissionStatusType.denied,
          message: 'Permission denied.',
          isGranted: false,
        );
      case PermissionStatus.permanentlyDenied:
        return PermissionResponse(
          status: PermissionStatusType.permanentlyDenied,
          message: 'Permission permanently denied.',
          isGranted: false,
        );
      case PermissionStatus.restricted:
        return PermissionResponse(
          status: PermissionStatusType.restricted,
          message: 'Permission restricted.',
          isGranted: false,
        );
      case PermissionStatus.limited:
        return PermissionResponse(status: PermissionStatusType.limited, message: 'Permission limited.', isGranted: false);
      default:
        return PermissionResponse(
          status: PermissionStatusType.unknown,
          message: 'Unknown permission status',
          isGranted: false,
        );
    }
  }
}
