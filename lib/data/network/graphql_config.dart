import 'package:ferry/ferry.dart';
import 'package:ferry_hive_store/ferry_hive_store.dart';
import 'package:get_it/get_it.dart';
import 'package:gql_http_link/gql_http_link.dart';
import 'package:hive_flutter/hive_flutter.dart';

final GetIt getIt = GetIt.instance;

class GraphQLConfig {
  static Client? _ferryGraphQlClient;
  static Future<Client> getFerryGraphQlClient() async {
    try {
      if(_ferryGraphQlClient != null){
        return Future.value(_ferryGraphQlClient);
      } 
      await Hive.initFlutter();
      final box = await Hive.openBox('graphql');
      final store = HiveStore(box);
      final cache = Cache(store: store);
      final link = HttpLink('http://localhost:3003/graphql');
      _ferryGraphQlClient = Client(link: link, cache: cache);
      return _ferryGraphQlClient!;
    } catch (e) {
      return Future.error('error initializing graphql client');
    }
  }
}
