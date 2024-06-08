import 'package:ferry/ferry.dart';
import 'package:melegna_customer/data/network/datasource.interface.dart';
import 'package:melegna_customer/graphql/queries/__generated__/business.req.gql.dart';

abstract class IGraphQLDataSource extends IDataSource {
  Future<T?> query<T>(OperationRequest<dynamic, dynamic> request);
  Future<dynamic> mutation(String mutation, {Map<String, dynamic> variables});
}

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
  Future<T?> query<T>(OperationRequest<dynamic, dynamic> request) async {
    try {
      var response = await graphQlClient.request(request).first;
      if (response.hasErrors) {
        throw Exception(response.graphqlErrors?.toString());
      }
      final item = response.data as T?;
      return item;
    } catch (e) {
      return Future.error("error occured $e");
    }
  }
}
