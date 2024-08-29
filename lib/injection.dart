import 'package:ferry/ferry.dart';
import 'package:get_it/get_it.dart';
import 'package:injectable/injectable.dart';
import 'package:imela/data/network/graphql_config.dart';
import 'package:imela/services/routing_service.dart';
import 'injection.config.dart';

final getIt = GetIt.instance;

@InjectableInit()
void configureDependencies() => getIt.init();

void setupGetIt() {
  configureDependencies();
  getIt.registerSingleton<bool>(false, instanceName: ClientInterceptor.BYPASS_TOKEN_VALIDATION);
  getIt.registerSingletonAsync<Client>(() async {
    return await GraphQLConfig.getFerryGraphQlClient();
  });

  getIt.registerSingleton(GoRouterService(), instanceName: GoRouterService.injectNameBeta);
}

 void updateDIValue<T extends Object>(String key, value) {
    // Unregister the old token
    if (getIt.isRegistered<T>(instanceName: key)) {
      getIt.unregister<T>(instanceName: key);
    }

    // Register the new token
    getIt.registerSingleton<T>(value, instanceName: key);
  }

