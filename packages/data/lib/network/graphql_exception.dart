import 'package:gql_exec/gql_exec.dart';
import 'package:imela_utils/exception/app_exception.dart';

class GraphqlException extends AppException {
  final List<GraphQLError>? errors;
  GraphqlException({this.errors, super.message, super.code, super.type, super.isMainError});

  @override
  AppException serialize() {
    final checkUnAuthorized = errors?.any((element) => element.extensions?['code'] == '401' || element.extensions?['code'] == 'UNAUTHENTICATED' || element.extensions?['code'] == 401) ?? false;
    
    if(checkUnAuthorized){
      return AppException(message: 'UnAuthorized', code: '401', type: 'UnAuthorized', isMainError: isMainError);
    }
    message = errors?.map((e) {
      final buffer = StringBuffer();
      buffer.writeln('Message: ${e.message}');
      if (e.extensions != null) {
        buffer.writeln('Extensions: ${e.extensions}');
      }
      if (e.locations != null) {
        buffer.writeln('Locations: ${e.locations}');
      }
      if (e.path != null) {
        buffer.writeln('Path: ${e.path}');
      }
      return buffer.toString();
    }).join('\n');
    return AppException(message: message, code: code, type: type, isMainError: isMainError);
  }
}
