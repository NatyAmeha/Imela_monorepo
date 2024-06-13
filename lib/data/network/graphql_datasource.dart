import 'dart:convert';

import 'package:ferry/ferry.dart';
import 'package:injectable/injectable.dart';
import 'package:melegna_customer/data/network/datasource.interface.dart';
import 'package:melegna_customer/presentation/utils/exception/graphql_exception.dart';

abstract class IGraphQLDataSource extends IDataSource {
  Future<T?> query<T>(OperationRequest<dynamic, dynamic> request, {String? type,  bool isMainError = false});
  Future<dynamic> mutation(String mutation, {Map<String, dynamic> variables});
}

@Injectable(as: IGraphQLDataSource)
class GraphqlDatasource implements IGraphQLDataSource {
  final Client graphQlClient;
  const GraphqlDatasource(this.graphQlClient);
  @override
  Future delete(String url) {
    // TODO: implement delete
    throw UnimplementedError();
  }

  @override
  Future get(String url) {
    // TODO: implement get
    throw UnimplementedError();
  }

  @override
  Future mutation(String mutation, {Map<String, dynamic>? variables}) {
    // TODO: implement mutation
    throw UnimplementedError();
  }

  @override
  Future post(String url, data) {
    // TODO: implement post
    throw UnimplementedError();
  }

  @override
  Future put(String url, data) {
    // TODO: implement put

    throw UnimplementedError();
  }

  @override
  Future<T?> query<T>(OperationRequest<dynamic, dynamic> request, {String? type,  bool isMainError = false}) async {
    var response = await graphQlClient.request(request).first;
    if (response.hasErrors) {
      throw GraphqlException(errors: response.graphqlErrors, type: type, isMainError: isMainError);
    }
    return response.data as T?;
  }
}
