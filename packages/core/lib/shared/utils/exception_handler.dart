import 'package:imela_data/network/graphql_exception.dart';
import 'package:imela_utils/exception/app_exception.dart';
import 'package:injectable/injectable.dart';

@Named(AppExceptionHandler.injectName)
@Injectable(as: IExceptiionHandler)
class AppExceptionHandler implements IExceptiionHandler {
  static const injectName = 'APP_EXCEPTION_HANDLER_INJECTION';
  AppExceptionHandler();

  @override
  AppException getException(Exception excetpion) {
    if (excetpion is GraphqlException) {
      return excetpion.serialize();
    }
    return AppException(message: excetpion.toString());
  }
}
