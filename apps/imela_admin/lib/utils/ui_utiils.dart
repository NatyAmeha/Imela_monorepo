import 'package:flutter/widgets.dart';
import 'package:imela_admin/ui/business/components/user_busienss_not_found.dart';
import 'package:imela_ui_kit/components/page_loading_utils/error_widget.dart';
import 'package:imela_utils/exception/app_exception.dart';
import 'package:imela_utils/exception/exception_type.dart';

class UiUtiils {
  static Widget getErrorUIType({AppException? exception, Map<ExceptionTypeActionKey, Function?>? actionsWithKey}) {
    if (exception?.type == ExceptionType.USER_OWNED_BUSINESS_NOT_FOUND.name) {
      return UserBusinessNotFoundComponent(onCreateBusinessClicked: () {
        actionsWithKey?[ExceptionTypeActionKey.CREATE_NEW_BUSINESS]?.call();
      });
    } else {
      return AppErrorWidget(exception: exception, callback: (){
        actionsWithKey?[ExceptionTypeActionKey.TRY_AGAIN_ACTION_KEY]?.call();
      });
    }
  }
}
