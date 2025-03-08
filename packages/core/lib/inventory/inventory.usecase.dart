import 'package:imela_core/inventory/model/inventory_response.dart';
import 'package:imela_core/inventory/repo/inventory.repository.dart';
import 'package:imela_data/network/graphql/graphql_datasource.dart';
import 'package:injectable/injectable.dart';

@injectable
class InventoryUsecase {
  final IInventoryRepository _inventoryRepository;

  const InventoryUsecase(
    @Named(InventoryRepository.injectName) this._inventoryRepository,
  );

  Future<InventoryResponse?> getProductInventory({
    required String businessId,
    required String inventoryLocationId,
    List<String>? productListIds,
    ApiDataFetchPolicy fetchPolicy = ApiDataFetchPolicy.cacheFirst,
  }) async {
    return await _inventoryRepository.getProductInventory(
      businessId: businessId,
      inventoryLocationId: inventoryLocationId,
      productListIds: productListIds,
      fetchPolicy: fetchPolicy,
    );
  }

  Future<InventoryResponse?> getInventoryLocations({
    required String businessId,
    String? branchId,
    ApiDataFetchPolicy fetchPolicy = ApiDataFetchPolicy.cacheFirst,
  }) async {
    return await _inventoryRepository.getInventoryLocations(
      businessId: businessId,
      branchId: branchId,
      fetchPolicy: fetchPolicy,
    );
  }

  Future<InventoryResponse?> updateProductInventory({
    required String businessId,
    required String productId,
    required String inventoryId,
    required double qty,
    required bool isAvailable,
    String? unit,
  }) async {
    return await _inventoryRepository.updateProductInventory(
      businessId: businessId,
      productId: productId,
      inventoryId: inventoryId,
      qty: qty,
      isAvailable: isAvailable,
      unit: unit,
    );
  }

  Future<InventoryResponse?> createInventory({
    required String businessId,
    required String productId,
    required String inventoryLocationId,
    required double qty,
    required bool isAvailable,
    String? unit,
  }) async {
    return await _inventoryRepository.createInventory(
      businessId: businessId,
      productId: productId,
      inventoryLocationId: inventoryLocationId,
      qty: qty,
      isAvailable: isAvailable,
      unit: unit,
    );
  }
} 