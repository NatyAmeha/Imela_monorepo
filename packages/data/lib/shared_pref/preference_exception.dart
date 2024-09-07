import 'package:imela_utils/exception/app_exception.dart';

class PreferenceException extends AppException{
  String errorMessage;
  String source;

  PreferenceException({required this.errorMessage, required this.source}) : super(message: errorMessage);

  @override
  AppException serialize() {
    return AppException(message: errorMessage, type: source);
  }

}