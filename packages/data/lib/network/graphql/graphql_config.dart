import 'dart:async';
import 'package:ferry/ferry.dart';
import 'package:get_it/get_it.dart';
import 'package:gql_exec/gql_exec.dart';
import 'package:gql_http_link/gql_http_link.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:imela_data/network/graphql/graphql_cache_config.dart';
import 'package:imela_data/shared_pref/shared_preference.constant.dart';
import 'package:shared_preferences/shared_preferences.dart';

final GetIt getItInstance = GetIt.instance;

class GraphQLConfig {
  static Client? _ferryGraphQlClient;
  static Future<Client> getFerryGraphQlClient() async {
    try {
      await Hive.initFlutter();
      if (_ferryGraphQlClient != null) {
        return Future.value(_ferryGraphQlClient);
      }
      // await Hive.initFlutter();
      final box = await Hive.openBox('graphql_cache_store');
      const cacheDuration = Duration(minutes: 3); // Set your desired cache duration
      final store = ExpiringStore(box, cacheDuration);
      // final store = HiveStore(box);
      final cache = Cache(store: store);
      final link = HttpLink('http://192.168.76.134:3000/graphql');
      final finalHttpLInk = link;
      final timeoutLink = ClientInterceptor(const Duration(seconds: 30), finalHttpLInk);
      _ferryGraphQlClient = Client(link: timeoutLink, cache: cache);
      return _ferryGraphQlClient!;
    } catch (e) {
      print("graph exception ${e.toString()}");
      return Future.error('error initializing graphql client');
    }
  }
}

class ClientInterceptor extends Link {
  final Duration timeout;
  final Link _link;

  static const BYPASS_TOKEN_VALIDATION = 'token';
  static const ACCESS_TOKEN = 'access_token';
  static const REFRESH_TOKEN = 'refresh_token';

  ClientInterceptor(this.timeout, this._link);

  @override
  Stream<Response> request(Request request, [NextLink? forward]) async* {
    final headers = <String, String>{};
    final bypasstoken = getItInstance<bool>(instanceName: BYPASS_TOKEN_VALIDATION);
    final pref = await SharedPreferences.getInstance();
    final token = pref.getString(SharedPreferenceConstant.ACCESS_TOKEN) ?? '';
    final refreshToken = pref.getString(SharedPreferenceConstant.REFRESH_TOKEN) ?? '';
    print('token: $token, refreshToken: $refreshToken');
    if (token.isNotEmpty) {
      headers['Authorization'] = 'Bearer $token';
    }
    headers[BYPASS_TOKEN_VALIDATION] = bypasstoken.toString();
    request = request.updateContextEntry<HttpLinkHeaders>(
      (existingHeaders) => HttpLinkHeaders(
        headers: {
          ...?existingHeaders?.headers,
          ...headers,
        },
      ),
    );
    final result = _link.request(request, forward);
    yield* result.timeout(timeout, onTimeout: (sink) {
      sink.addError(TimeoutException('Request timed out'));
      sink.close();
    });
  }
}
