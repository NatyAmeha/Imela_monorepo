// GENERATED CODE - DO NOT MODIFY BY HAND

// **************************************************************************
// InjectableConfigGenerator
// **************************************************************************

// ignore_for_file: type=lint
// coverage:ignore-file

// ignore_for_file: no_leading_underscores_for_library_prefixes
import 'package:ferry/ferry.dart' as _i4;
import 'package:get_it/get_it.dart' as _i1;
import 'package:injectable/injectable.dart' as _i2;
import 'package:melegna_customer/data/network/graphql_datasource.dart' as _i3;
import 'package:melegna_customer/domain/business/business.usecase.dart' as _i6;
import 'package:melegna_customer/domain/business/repo/business_repository.dart'
    as _i5;
import 'package:melegna_customer/presentation/ui/business/business.viewmodel.dart'
    as _i7;

extension GetItInjectableX on _i1.GetIt {
// initializes the registration of main-scope dependencies inside of GetIt
  _i1.GetIt init({
    String? environment,
    _i2.EnvironmentFilter? environmentFilter,
  }) {
    final gh = _i2.GetItHelper(
      this,
      environment,
      environmentFilter,
    );
    gh.factory<_i3.IGraphQLDataSource>(
        () => _i3.GraphqlDatasource(gh<_i4.Client>()));
    gh.factory<_i5.IBusinessrepository>(
      () => _i5.BusinessRepository(gh<_i3.IGraphQLDataSource>()),
      instanceName: 'BUSINESS_REPOSITORY_INJECTION',
    );
    gh.factory<_i6.BusinessUsecase>(() => _i6.BusinessUsecase(
        gh<_i5.IBusinessrepository>(
            instanceName: 'BUSINESS_REPOSITORY_INJECTION')));
    gh.factory<_i7.BusinessDetailsViewModel>(() => _i7.BusinessDetailsViewModel(
        businessUsecase: gh<_i6.BusinessUsecase>()));
    return this;
  }
}
