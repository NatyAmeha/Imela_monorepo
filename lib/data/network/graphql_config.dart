import 'dart:async';

import 'package:ferry/ferry.dart';
import 'package:ferry_hive_store/ferry_hive_store.dart';
import 'package:get_it/get_it.dart';
import 'package:gql_exec/gql_exec.dart';
import 'package:gql_http_link/gql_http_link.dart';
import 'package:hive_flutter/hive_flutter.dart';

final GetIt getIt = GetIt.instance;

class GraphQLConfig {
  static Client? _ferryGraphQlClient;
  static Future<Client> getFerryGraphQlClient() async {
    try {
      if (_ferryGraphQlClient != null) {
        return Future.value(_ferryGraphQlClient);
      }
      await Hive.initFlutter();
      final box = await Hive.openBox('graphql');
      final store = HiveStore(box);
      final cache = Cache(store: store);
      final link = HttpLink('http://192.168.1.4:3000/graphql');
      final timeoutLink = TimeoutLink(
          const Duration(seconds: 10), // Set the timeout duration here
          link);
      _ferryGraphQlClient = Client(link: timeoutLink, cache: cache);
      return _ferryGraphQlClient!;
    } catch (e) {
      return Future.error('error initializing graphql client');
    }
  }
}

class TimeoutLink extends Link {
  final Duration timeout;
  final Link _link;

  TimeoutLink(this.timeout, this._link);

  @override
  Stream<Response> request(Request request, [NextLink? forward]) {
    final result = _link.request(request, forward);
    return result.timeout(timeout, onTimeout: (sink) {
      sink.addError(TimeoutException('Request timed out'));
      sink.close();
    });
  }
}
