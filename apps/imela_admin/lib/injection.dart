import 'package:get_it/get_it.dart';
import 'package:imela_admin/app/routing_service.dart';
import 'package:imela_admin/injection.config.dart';
import 'package:imela_core/injection.dart';
import 'package:injectable/injectable.dart';

final getIt = GetIt.instance;

@InjectableInit()
void configureDependencies() => getIt.init();

Future<void> setupGetIt() async {
  await configureCorePackageDIInjection();
  getIt.registerSingleton(GoRouterService(), instanceName: 'newinstance');
  configureDependencies();
  await getIt.allReady();
}

//  void updateDIValue<T extends Object>(String key, value) {
//     // Unregister the old token
//     if (getIt.isRegistered<T>(instanceName: key)) {
//       getIt.unregister<T>(instanceName: key);
//     }

//     // Register the new token
//     getIt.registerSingleton<T>(value, instanceName: key);
//   }
