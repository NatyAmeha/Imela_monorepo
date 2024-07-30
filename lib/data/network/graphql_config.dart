import 'dart:async';

import 'package:ferry/ferry.dart';
import 'package:ferry_hive_store/ferry_hive_store.dart';
import 'package:get_it/get_it.dart';
import 'package:gql_exec/gql_exec.dart';
import 'package:gql_http_link/gql_http_link.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:melegna_customer/data/network/graphql_cache_config.dart';

final GetIt getIt = GetIt.instance;

class GraphQLConfig {
  static Client? _ferryGraphQlClient;
  static Future<Client> getFerryGraphQlClient() async {
    try {
      if (_ferryGraphQlClient != null) {
        return Future.value(_ferryGraphQlClient);
      }
      await Hive.initFlutter();
      final box = await Hive.openBox('graphql_cache_store');
      const cacheDuration = Duration(minutes: 1); // Set your desired cache duration
      final store = ExpiringStore(box, cacheDuration);
      // final store = HiveStore(box);
      final cache = Cache(store: store);
      final link = HttpLink('http://192.168.211.134:3000/graphql');
      final timeoutLink = TimeoutLink(const Duration(seconds: 30), link);
      _ferryGraphQlClient = Client(link: timeoutLink, cache: cache);
      return _ferryGraphQlClient!;
    } catch (e) {
      print("graph exception ${e.toString()}");
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
