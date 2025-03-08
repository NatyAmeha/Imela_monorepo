import 'package:imela_core/inventory/model/inventory_response.dart';
import 'package:imela_data/network/graphql/__generated__/schema.schema.gql.dart';
import 'package:imela_data/network/graphql/graphql_datasource.dart';
import 'package:imela_data/network/graphql/inventory/__generated__/create_inventory.data.gql.dart';
import 'package:imela_data/network/graphql/inventory/__generated__/create_inventory.req.gql.dart';
import 'package:imela_data/network/graphql/inventory/__generated__/get_inventory_locations.data.gql.dart';
import 'package:imela_data/network/graphql/inventory/__generated__/get_inventory_locations.req.gql.dart';
import 'package:imela_data/network/graphql/inventory/__generated__/get_product_inventory.data.gql.dart';
import 'package:imela_data/network/graphql/inventory/__generated__/get_product_inventory.req.gql.dart';
import 'package:imela_data/network/graphql/inventory/__generated__/update_product_inventory.data.gql.dart';
import 'package:imela_data/network/graphql/inventory/__generated__/update_product_inventory.req.gql.dart';
import 'package:injectable/injectable.dart';

abstract class IInventoryRepository {
  Future<InventoryResponse?> getProductInventory({
    required String businessId, 
    required String inventoryLocationId, 
    List<String>? productListIds,
    ApiDataFetchPolicy fetchPolicy = ApiDataFetchPolicy.cacheFirst,
  });
  
  Future<InventoryResponse?> getInventoryLocations({
    required String businessId, 
    String? branchId,
    ApiDataFetchPolicy fetchPolicy = ApiDataFetchPolicy.cacheFirst,
  });

  Future<InventoryResponse?> updateProductInventory({
    required String businessId,
    required String productId,
    required String inventoryId,
    required double qty,
    required bool isAvailable,
    String? unit,
    ApiDataFetchPolicy fetchPolicy = ApiDataFetchPolicy.networkOnly,
  });

  Future<InventoryResponse?> createInventory({
    required String businessId,
    required String productId, 
    required String inventoryLocationId,
    required double qty,
    required bool isAvailable,
    String? unit,
    ApiDataFetchPolicy fetchPolicy = ApiDataFetchPolicy.networkOnly,
  });
}

@Injectable(as: IInventoryRepository)
@Named(InventoryRepository.injectName)
class InventoryRepository implements IInventoryRepository {
  static const injectName = 'InventoryRepository';
  final IGraphQLDataSource _graphQLDataSource;

  InventoryRepository(@Named(GraphqlDatasource.injectName) this._graphQLDataSource);

  @override
  Future<InventoryResponse?> getProductInventory({
    required String businessId, 
    required String inventoryLocationId, 
    List<String>? productListIds,
    ApiDataFetchPolicy fetchPolicy = ApiDataFetchPolicy.cacheFirst,
  }) async {
    final request = GGetProductInventoryReq(
      (b) => b
        ..vars.businessId = businessId
        ..vars.inventoryLocationId = inventoryLocationId
        ..vars.productListIds.addAll(productListIds ?? [])
        ..fetchPolicy = _graphQLDataSource.getFetchPolicy(fetchPolicy),
    );
    
    final result = await _graphQLDataSource.request<GGetProductInventoryData>(
      request, 
      type: 'GET_PRODUCT_INVENTORY',
      isMainError: true,
    );
    
    if (result?.getProductInventory == null) {
      return null;
    }
    
    return InventoryResponse.fromJson(result!.getProductInventory.toJson());
  }

  @override
  Future<InventoryResponse?> getInventoryLocations({
    required String businessId, 
    String? branchId,
    ApiDataFetchPolicy fetchPolicy = ApiDataFetchPolicy.cacheFirst,
  }) async {
    final request = GGetInventoryLocationsReq(
      (b) => b
        ..vars.businessId = businessId
        ..vars.branchId = branchId
        ..fetchPolicy = _graphQLDataSource.getFetchPolicy(fetchPolicy),
    );
    
    final result = await _graphQLDataSource.request<GGetInventoryLocationsData>(
      request, 
      type: 'GET_INVENTORY_LOCATIONS',
      isMainError: true,
    );
    
    if (result?.getInventoryLocations == null) {
      return null;
    }
    
    return InventoryResponse.fromJson(result!.getInventoryLocations.toJson());
  }

  @override
  Future<InventoryResponse?> updateProductInventory({
    required String businessId,
    required String productId,
    required String inventoryId,
    required double qty,
    required bool isAvailable,
    String? unit,
    ApiDataFetchPolicy fetchPolicy = ApiDataFetchPolicy.networkOnly,
  }) async {
    final request = GUpdateProductInventoryInformationReq(
      (b) => b
        ..vars.businessId = businessId
        ..vars.productId = productId
        ..vars.input.addAll([
          GUpdateInventoryInput((b) => b
            ..qty = qty
            ..isAvailable = isAvailable
            ..unit = unit
            ..priceInfo.addAll([])
            ..id = inventoryId
          )
        ])
        
    );
    
    final result = await _graphQLDataSource.request<GUpdateProductInventoryInformationData>(
      request, 
      type: 'UPDATE_PRODUCT_INVENTORY',
      isMainError: true,
    );
    
    if (result?.updateProductInventoryInformations == null) {
      return null;
    }
    
    return InventoryResponse.fromJson(result!.updateProductInventoryInformations.toJson());
  }

  @override
  Future<InventoryResponse?> createInventory({
    required String businessId,
    required String productId,
    required String inventoryLocationId,
    required double qty,
    required bool isAvailable,
    String? unit,
    ApiDataFetchPolicy fetchPolicy = ApiDataFetchPolicy.networkOnly,
  }) async {
    final request = GCreateNewInventoryOnInventoryLocationReq(
      (b) => b
        ..vars.businessId = businessId
        ..vars.productId = productId
        ..vars.inventoryData.inventoryLocationId = inventoryLocationId
        ..vars.inventoryData.qty = qty
        ..vars.inventoryData.unit = unit ?? 'Unit'
        // ..vars.inventoryData.isAvailable = isAvailable
        ..vars.inventoryData.priceInfo.addAll([]), // Empty price info as we're only setting inventory
    );
    
    final result = await _graphQLDataSource.request<GCreateNewInventoryOnInventoryLocationData>(
      request, 
      type: 'CREATE_INVENTORY',
      isMainError: true,
    );
    
    if (result?.createNewInventoryOnInventoryLocation == null) {
      return null;
    }
    
    return InventoryResponse.fromJson(result!.createNewInventoryOnInventoryLocation.toJson());
  }
} 