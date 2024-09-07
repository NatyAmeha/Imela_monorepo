import 'package:get_it/get_it.dart';
import 'package:imela_core/injection.config.dart';
import 'package:imela_data/injection.dart';
import 'package:injectable/injectable.dart';

final getIt = GetIt.instance;

@InjectableInit()
void configureDependencies() => getIt.init();

Future<void> configureCorePackageDIInjection() async {
  await configureDataPackageInjection();
  configureDependencies();
}
