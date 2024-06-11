import 'package:ferry/ferry.dart';
import 'package:get/get.dart';
import 'package:get_it/get_it.dart';
import 'package:injectable/injectable.dart';
import 'package:melegna_customer/data/network/graphql_config.dart';
import 'package:melegna_customer/domain/business/business.usecase.dart';
import 'package:melegna_customer/presentation/ui/business/business.viewmodel.dart';
import 'injection.config.dart';

final getIt = GetIt.instance;

@InjectableInit()
void configureDependencies() => getIt.init();

void setupGetIt() {
  configureDependencies();
  getIt.registerSingletonAsync<Client>(() async {
    return await GraphQLConfig.getFerryGraphQlClient();
  });
}

