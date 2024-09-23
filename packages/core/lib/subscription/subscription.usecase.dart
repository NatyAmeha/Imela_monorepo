import 'package:imela_core/subscription/dto/create_platform_subscription_input.dart';
import 'package:imela_core/subscription/dto/platform_service.response.dart';
import 'package:imela_core/subscription/dto/subscription.response.dart';
import 'package:imela_core/subscription/model/platform_service.model.dart';
import 'package:imela_core/subscription/repo/platform_service.repository.dart';
import 'package:imela_data/network/graphql/graphql_datasource.dart';
import 'package:injectable/injectable.dart';

@injectable
class SubscriptioniUsecase {
  final IPlatformServiceRepository _platformServiceRepository;

  SubscriptioniUsecase(@Named(PlatformServiceRepository.injectName) this._platformServiceRepository);

  Future<PlatformServiceResponse> getPlatformServices() async {
    late PlatformServiceResponse response;
    response = await _platformServiceRepository.getPlatformServices(ApiDataFetchPolicy.networkOnly);
    return response;
  }

  Future<SubscriptionResponse?> subscribeBusinessToPlatformServices(String businessId, List<PlatformService> services) async {
    late SubscriptionResponse response;
    final input = CreatePlatformSubscriptionInput.fromPlatformServices(businessId, services);
    response = await _platformServiceRepository.subscribeToPlatformServices(businessId, input);
    return response;
  }
}
