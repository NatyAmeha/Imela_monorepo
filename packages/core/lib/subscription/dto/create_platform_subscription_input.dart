import 'package:dartx/dartx.dart';
import 'package:imela_core/subscription/model/platform_service.model.dart';

import 'package:imela_data/network/graphql/__generated__/schema.schema.gql.dart';

class CreatePlatformSubscriptionInput {
  String owner;
  List<SelectedPlatformServiceForSubscription> selectedPlatformServices;

  CreatePlatformSubscriptionInput({required this.owner, required this.selectedPlatformServices});

  GCreatePlatformSubscriptionInput toGraphQLInput() {
    return GCreatePlatformSubscriptionInput((b) => b
      ..owner = owner
      ..selectedPlatformServices.addAll(selectedPlatformServices.map((e) => e.toGraphQLInput())));
  }

  static CreatePlatformSubscriptionInput fromPlatformServices(String userId, List<PlatformService> services) {
    if (services.any((e) => e.selectedCustomization == null || e.selectedCustomization!.isEmpty)) {
      throw Exception('All services must have a selected customization');
    }
    return CreatePlatformSubscriptionInput(
      owner: userId,
      selectedPlatformServices: services
          .map(
            (e) => SelectedPlatformServiceForSubscription(
                serviceId: e.id!,
                serviceName: e.name!.first.value ?? '',
                selectedCustomizationInfo: e.selectedCustomization!.values.flatten().map(
                  (c) {
                    return CustomizationInfoInput(customizationId: c.id!, action: c.actionIdentifier!);
                  },
                ).toList(),
                selectedRenewalId: e.selectedSubscriptionRenewal!.id!),
          )
          .toList(),
    );
  }
}

class SelectedPlatformServiceForSubscription {
  String serviceId;
  String serviceName;
  List<CustomizationInfoInput> selectedCustomizationInfo;
  String selectedRenewalId;

  SelectedPlatformServiceForSubscription({required this.serviceId, required this.serviceName, required this.selectedCustomizationInfo, required this.selectedRenewalId});

  GSelectedPlatformServiceForSubscription toGraphQLInput() {
    return GSelectedPlatformServiceForSubscription((b) => b
      ..serviceId = serviceId
      ..serviceName = serviceName
      ..selectedCustomizationInfo.addAll(selectedCustomizationInfo.map((e) => e.toGraphQLInput()))
      ..selectedRenewalId = selectedRenewalId);
  }
}

class CustomizationInfoInput {
  String customizationId;
  String action;

  CustomizationInfoInput({required this.customizationId, required this.action});

  GCustomizationInfoInput toGraphQLInput() {
    return GCustomizationInfoInput((b) => b
      ..customizationId = customizationId
      ..action = action);
  }
}
