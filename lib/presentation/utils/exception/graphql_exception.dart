import 'package:gql_exec/gql_exec.dart';
import 'package:melegna_customer/presentation/utils/exception/app_exception.dart';

class GraphqlException extends AppException {
  final List<GraphQLError>? errors;
  GraphqlException({this.errors, super.message, super.code, super.type, super.isMainError});

  @override
  AppException serialize() {
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
    return GraphqlException(message: message, code: code, type: type, isMainError: isMainError, errors: errors);
  }
}
