import 'package:imela/data/network/graphql_datasource.dart';

abstract class BaseResponse {
  const BaseResponse._();
  bool isSuccsess({ApiDataFetchPolicy? fetchPolicy});

}
