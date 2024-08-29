import 'dart:convert';

import 'package:ferry/ferry.dart';
import 'package:flutter/foundation.dart';
import 'package:gql_exec/gql_exec.dart';
import 'package:injectable/injectable.dart';
import 'package:imela/presentation/utils/exception/app_exception.dart';
import 'package:imela/presentation/utils/exception/graphql_exception.dart';
import 'package:imela/services/logger/log.model.dart';
import 'package:imela/services/logger/logger.service.dart';

enum ApiDataFetchPolicy { cacheFirst, cacheAndNetwork, networkOnly, cacheOnly, noCache }

abstract class IGraphQLDataSource {
  Future<T?> request<T>(OperationRequest<dynamic, dynamic> request, {String? type, bool isMainError = false});
  Stream<T?> requestStream<T>(OperationRequest<dynamic, dynamic> request, {String? type, bool isMainError = false});
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
  Stream<T?> requestStream<T>(OperationRequest<dynamic, dynamic> request, {String? type, bool isMainError = false}) {
    try {
      return graphQlClient.request(request).map((event) {
        if (event.hasErrors) {
          if (kDebugMode) {
            print('graphql errors  ${event.graphqlErrors?.map((e) => e.extensions?["code"])} ${event.graphqlErrors.toString()} ${event.linkException.toString()}');
          }
          _loggerService.log(LogData(source: "Class name", message: 'Graphql error: ${event.graphqlErrors.toString()}', logLevel: LogLevel.ERROR));
          throw GraphqlException(errors: event.graphqlErrors, type: type, isMainError: isMainError);
        }
        _loggerService.log(LogData(source: "Class Name", message: 'Graphql response: ${jsonEncode(event.data)}', logLevel: LogLevel.INFO));
        return event.data;
      });
    } catch (e) {
      if (e is GraphqlException) {
        rethrow;
      }
      throw AppException(exception: e, type: type, isMainError: isMainError);
    }
  }

  @override
  Future<T?> request<T>(OperationRequest<dynamic, dynamic> request, {String? type, bool isMainError = false}) async {
    try {
      var response = await graphQlClient.request(request).first;
      if (response.hasErrors) {
        if (kDebugMode) {
          print('graphql errors ${response.graphqlErrors.toString()} ${response.linkException.toString()}');
        }
        _loggerService.log(LogData(source: "Class name", message: 'Graphql error: ${response.graphqlErrors.toString()}', logLevel: LogLevel.ERROR));
        throw GraphqlException(errors: response.graphqlErrors, type: type, isMainError: isMainError);
      }
      _loggerService.log(LogData(source: "Class Name", message: 'Graphql response: ${jsonEncode(response.data)}', logLevel: LogLevel.INFO));
      return response.data as T?;
    } catch (e) {
      if (e is GraphqlException) {
        rethrow;
      }
      // _loggerService.log(LogData(source: "Class name", message: 'Graphql error: ${jsonEncode(response.graphqlErrors)}', logLevel: LogLevel.ERROR));
      throw AppException(exception: e, type: type, isMainError: isMainError);
    }
  }
}
