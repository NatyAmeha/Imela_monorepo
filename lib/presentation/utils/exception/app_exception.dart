import 'package:injectable/injectable.dart';
import 'package:melegna_customer/presentation/utils/exception/graphql_exception.dart';

class AppException implements Exception {
  String? message;
  String? code;
  String? type;
  bool? isMainError;
  dynamic exception;

  static const GraphQLErrorType = 'GraphQLError';
  static const DBErrorType = 'DBError';

  AppException({this.message, this.code, this.type, this.isMainError, this.exception});

  AppException serialize() {
    return AppException(message: message, code: code, type: type, isMainError: isMainError, exception: exception);
  }
}

abstract class IExceptiionHandler {
  AppException getException(Exception excetpion); 
}

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
