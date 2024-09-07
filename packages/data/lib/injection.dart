import 'package:ferry/ferry.dart';
import 'package:get_it/get_it.dart';
import 'package:imela_data/injection.config.dart';
import 'package:imela_data/network/graphql/graphql_config.dart';
import 'package:injectable/injectable.dart';

final getIt = GetIt.instance;

@InjectableInit()
void configureDependencies() => getIt.init();

Future<void> configureDataPackageInjection() async {
  getIt.registerSingleton<bool>(false, instanceName: ClientInterceptor.BYPASS_TOKEN_VALIDATION);
  getIt.registerSingletonAsync<Client>(() async {
    return await GraphQLConfig.getFerryGraphQlClient();
  });
  configureDependencies();
  
}

 void updateDIValue<T extends Object>(String key, T value) {
    // Unregister the old token
    if (getIt.isRegistered<T>(instanceName: key)) {
      getIt.unregister<T>(instanceName: key);
    }

    // Register the new token
    getIt.registerSingleton<T>(value, instanceName: key);
  }
