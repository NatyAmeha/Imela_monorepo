import 'package:get_it/get_it.dart';
import 'package:imela_utils/injection.config.dart';
import 'package:injectable/injectable.dart';

final getIt = GetIt.instance;

@InjectableInit()
void configureDependencies() => getIt.init();

Future<void> configureUtilsPackageInjection() async {
  configureDependencies();
}
