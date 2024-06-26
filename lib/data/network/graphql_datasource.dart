import 'dart:convert';

import 'package:ferry/ferry.dart';
import 'package:injectable/injectable.dart';
import 'package:melegna_customer/presentation/utils/exception/app_exception.dart';
import 'package:melegna_customer/presentation/utils/exception/graphql_exception.dart';
import 'package:melegna_customer/services/logger/log.model.dart';
import 'package:melegna_customer/services/logger/logger.service.dart';

enum ApiDataFetchPolicy { cacheFirst, cacheAndNetwork, networkOnly, cacheOnly, noCache }

abstract class IGraphQLDataSource {
  Future<T?> query<T>(OperationRequest<dynamic, dynamic> request, {String? type,  bool isMainError = false});
  Future<dynamic> mutation(String mutation, {Map<String, dynamic> variables});
  FetchPolicy getFetchPolicy(ApiDataFetchPolicy policy);
}

@Injectable(as: IGraphQLDataSource) 
@Named(GraphqlDatasource.injectName)
class GraphqlDatasource implements IGraphQLDataSource {
  static const injectName = 'GRAPHQL_DATASOURCE_INJECTION';
  final Client graphQlClient;
  final ILogService _loggerService;
  const GraphqlDatasource(this.graphQlClient, @Named(AppLogService.injectName) this._loggerService);


  @override
  FetchPolicy getFetchPolicy(ApiDataFetchPolicy policy) {
    switch (policy) {
      case ApiDataFetchPolicy.cacheFirst:
        return FetchPolicy.CacheFirst;
      case ApiDataFetchPolicy.cacheAndNetwork:
        return FetchPolicy.CacheAndNetwork;
      case ApiDataFetchPolicy.networkOnly:
        return FetchPolicy.NetworkOnly;
      case ApiDataFetchPolicy.cacheOnly:
        return FetchPolicy.CacheOnly;
      case ApiDataFetchPolicy.noCache:
        return FetchPolicy.NoCache;
      default:
        return FetchPolicy.CacheFirst;
    }
  }
  
  @override
  Future mutation(String mutation, {Map<String, dynamic>? variables}) {
    // TODO: implement mutation
    throw UnimplementedError();
  }

  @override
  Future<T?> query<T>(OperationRequest<dynamic, dynamic> request, {String? type,  bool isMainError = false}) async {
    try {
      var response = await graphQlClient.request(request).first;
      if (response.hasErrors) {
        print("graphql errors ${response.graphqlErrors.toString()}");
        _loggerService.log(LogData(source: "Class name", message: 'Graphql error: ${response.graphqlErrors.toString()}', logLevel: LogLevel.ERROR));
        throw GraphqlException(errors: response.graphqlErrors, type: type, isMainError: isMainError);
      }
      _loggerService.log(LogData(source: "Class Name", message: 'Graphql response: ${jsonEncode(response.data)}', logLevel: LogLevel.INFO));
      return response.data as T?;
    } catch (e) {
      print("graphql exception $e");
      // _loggerService.log(LogData(source: "Class name", message: 'Graphql error: ${jsonEncode(response.graphqlErrors)}', logLevel: LogLevel.ERROR));
      throw AppException(exception: e , type: type, isMainError: isMainError);
    }
  }
}
