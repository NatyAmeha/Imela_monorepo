import 'package:get_it/get_it.dart';
import 'package:imela_core/injection.dart';
import 'package:imela_pos/app/routing_service.dart';
import 'package:imela_pos/injection.config.dart';
import 'package:injectable/injectable.dart';

final getIt = GetIt.instance;

@InjectableInit()
void configureDependencies() => getIt.init();

Future<void> setupGetIt() async {
  await configureCorePackageDIInjection();
  getIt.registerSingleton(GoRouterService(), instanceName: GoRouterService.injectName);
  configureDependencies();
  await getIt.allReady();
}
