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
  getIt.registerSingleton(GoRouterService(), instanceName: GoRouterService.injectName);
  configureDependencies();
  await getIt.allReady();
}
