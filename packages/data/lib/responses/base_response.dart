
import 'package:imela_data/network/graphql/graphql_datasource.dart';

abstract class BaseResponse {
  const BaseResponse._();
  bool isSuccsess({ApiDataFetchPolicy? fetchPolicy});

}
