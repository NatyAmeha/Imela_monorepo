import 'package:collection/collection.dart';
import 'package:get/get.dart';
import 'package:imela_admin/injection.dart';
import 'package:imela_core/subscription/model/customization.model.dart';
import 'package:imela_utils/helpers/base_viewmodel.dart';
import 'package:injectable/injectable.dart';

@injectable
class CustomizationViewmodel extends GetxController with BaseViewmodel {
  var customizationCategories = <CustomizationCategory>[].obs;
  var selectedCustomization = <String, List<String>>{}.obs;

  static CustomizationViewmodel getInstance({String? key}) {
    return BaseViewmodel.isViewmodelRegistered(getIt<CustomizationViewmodel>(), tag: key);
  }

  @override
  void initViewmodel({Map<String, dynamic>? data}) {
    super.initViewmodel(data: data);
    customizationCategories.value = data!['customizationCategories'];

    applyDefaultCustomization();
  }

  void applyDefaultCustomization() {
    selectedCustomization.clear();
    for (var category in customizationCategories) {
      final defaultCustomization = category.customizations!.where((element) => element.defaultValue).firstOrNull ?? category.customizations!.first;
      if (category.selectionType == CustomizationSelectionType.SINGLE_SELECTION.name) {
        updateSingleSelectioncustomization(category.id!, defaultCustomization.id!);
      }
      else {
        updateMultiSelectioncustomization(category.id!, defaultCustomization.id!);
      }
    }
  }

  List<String> getSelectedCustomizationForCategory(String categoryId) {
    return selectedCustomization[categoryId] ?? [];
  }



  void updateSingleSelectioncustomization(String categoryId, String customizationId) {
    final key = selectedCustomization.keys.firstWhereOrNull((key) => key == categoryId);
    if (key != null) {
      selectedCustomization[key] = [customizationId];
    } else {
      selectedCustomization.addAll({
        categoryId: [customizationId]
      });
    }
  }

  void updateMultiSelectioncustomization(String categoryId, String customizationId) {
    final key = selectedCustomization.keys.firstWhereOrNull((key) => key == categoryId);
    if (key != null) {
      if (selectedCustomization[key]!.contains(customizationId)) {
        selectedCustomization[key]!.remove(customizationId);
      } else {
        selectedCustomization[key]!.add(customizationId);
      }
    } else {
      selectedCustomization.addAll({
        categoryId: [customizationId]
      }); 
    }
    selectedCustomization.refresh();
  }
}
