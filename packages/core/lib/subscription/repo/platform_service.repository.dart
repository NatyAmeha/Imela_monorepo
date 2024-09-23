import 'package:imela_core/subscription/dto/create_platform_subscription_input.dart';
import 'package:imela_core/subscription/dto/platform_service.response.dart';
import 'package:imela_core/subscription/dto/subscription.response.dart';
import 'package:imela_data/network/graphql/graphql_datasource.dart';
import 'package:imela_data/network/graphql/subscription/__generated__/get_platform_services.data.gql.dart';
import 'package:imela_data/network/graphql/subscription/__generated__/get_platform_services.req.gql.dart';
import 'package:imela_data/network/graphql/subscription/__generated__/subscribe_to_platform_service.data.gql.dart';
import 'package:imela_data/network/graphql/subscription/__generated__/subscribe_to_platform_service.req.gql.dart';
import 'package:imela_data/network/graphql_exception.dart';
import 'package:injectable/injectable.dart';

abstract class IPlatformServiceRepository {
  Future<PlatformServiceResponse> getPlatformServices(ApiDataFetchPolicy apiDataFetchPolicy);
  Future<SubscriptionResponse> subscribeToPlatformServices(String businessId, CreatePlatformSubscriptionInput input);
}

@Injectable(as: IPlatformServiceRepository)
@Named(PlatformServiceRepository.injectName)
class PlatformServiceRepository implements IPlatformServiceRepository {
  static const injectName = 'PlatformServiceRepository';
  final IGraphQLDataSource _graphQLDataSource;

  PlatformServiceRepository(@Named(GraphqlDatasource.injectName) this._graphQLDataSource);
  @override
  Future<PlatformServiceResponse> getPlatformServices(ApiDataFetchPolicy apiDataFetchPolicy) async {
    final req = GGetPlatformServicesReq((b) => b..fetchPolicy = _graphQLDataSource.getFetchPolicy(apiDataFetchPolicy));
    final result = await _graphQLDataSource.request<GGetPlatformServicesData>(req, type: 'GET_PLATFORM_SERVICES', isMainError: true);
    if (result?.getPlatformServices == null) {
      throw GraphqlException(message: 'Unable to get platform services');
    }
    return PlatformServiceResponse.fromJson(result!.getPlatformServices.toJson());

  }

  @override
  Future<SubscriptionResponse> subscribeToPlatformServices(String businessId, CreatePlatformSubscriptionInput input) async {
    final req = GSubscribeToPlatformServicesReq((b) => b
    ..vars.businessId = businessId
    ..vars.serviceInput.update((i) => i
     ..owner = input.owner
     ..selectedPlatformServices.addAll(input.selectedPlatformServices.map((e) => e.toGraphQLInput()))
     )
    );
    final result = await _graphQLDataSource.request<GSubscribeToPlatformServicesData>(req, type: 'SUBSCRIBE_TO_PLATFORM_SERVICES', isMainError: true);
    if (result?.subscribeBusinessToPlatformServices == null) {
      throw GraphqlException(message: 'Unable to subscribe to platform services');
    }
    return SubscriptionResponse.fromJson(result!.subscribeBusinessToPlatformServices.toJson());
  }
}
