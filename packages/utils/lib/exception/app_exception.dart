import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

class AppException implements Exception {
  String? message;
  String? code;
  String? type;
  bool isMainError;
  IconData? errorIcon;
  String? actionText;
  Function? onAction;

  dynamic exception;

  static const GraphQLErrorType = 'GraphQLError';
  static const DBErrorType = 'DBError';

  AppException({
    this.message,
    this.code,
    this.type,
    this.isMainError = false,
    this.exception,
    this.errorIcon = Icons.error_outline,
    this.actionText = 'Try again',
    this.onAction,
  });

  bool get isUnAuthorizedException {
    return code == '401' || code == 'UNAUTHENTICATED';
  }

  AppException serialize() {
    return AppException(message: message, code: code, type: type, isMainError: isMainError, exception: exception);
  }

  static AppException unexpectedError(Object exception) {
    return AppException(message: 'An unexpected error occured $exception', isMainError: false, exception: exception);
  }
}

abstract class IExceptiionHandler {
  AppException getException(Exception excetpion);
}
