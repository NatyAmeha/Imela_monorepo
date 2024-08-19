import 'dart:async';

import 'package:ferry/ferry.dart';
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
      const cacheDuration = Duration(minutes: 3); // Set your desired cache duration
      final store = ExpiringStore(box, cacheDuration);
      // final store = HiveStore(box);
      final cache = Cache(store: store);
      final link = HttpLink('http://192.168.211.134:3000/graphql');
      final finalHttpLInk =  getAuthToken().concat(link);
      final timeoutLink = TimeoutLink(const Duration(seconds: 30), finalHttpLInk);
      _ferryGraphQlClient = Client(link: timeoutLink, cache: cache);
      return _ferryGraphQlClient!;
    } catch (e) {
      print("graph exception ${e.toString()}");
      return Future.error('error initializing graphql client');
    }
  }
}

Link getAuthToken() {
  return Link.function((request, [forward]) {
    final headers = <String, String>{};
    const authToken = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOiI2NjFmODk0ZjVkYjAzOTJlNWRkZmY2NzYiLCJ1c2VybmFtZSI6Im5hdHlhbWVoYUBnbWFpbC5jb20iLCJlbWFpbCI6Im5hdHlhbWVoYUBnbWFpbC5jb20iLCJpYXQiOjE3MjQwNTgxMDQsImV4cCI6MTcyNDE0NDUwNH0.RXM4zkA7Ul1Ultialr4jDW8G_eexMEDeYwqCNxXm-Dc';
    if (authToken.isNotEmpty) {
      headers['Authorization'] = 'Bearer $authToken';
    }
    request = request.updateContextEntry<HttpLinkHeaders>(
      (existingHeaders) => HttpLinkHeaders(
        headers: {
          ...?existingHeaders?.headers,
          ...headers,
        },
      ),
    );
    return forward!(request);
  });
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
