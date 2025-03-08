import 'package:imela_core/business/model/business_response.dart';
import 'package:imela_core/product/dto/product_price.response.dart';
import 'package:imela_core/product/repo/product_price.repository.dart';
import 'package:imela_core/shared/localized_field.model.dart';
import 'package:imela_core/shared/price.model.dart';
import 'package:imela_data/network/graphql/graphql_datasource.dart';
import 'package:injectable/injectable.dart';

@injectable
class ProductPriceUsecase {
  final IProductPriceRepository _productPriceRepository;

  const ProductPriceUsecase(
    @Named(ProductPriceRepository.injectName) this._productPriceRepository,
  );

  Future<ProductPriceResponse?> getProductsPriceAndPriceList({
    required String businessId,
    required List<String> productIds,
    String? branchId,
    ApiDataFetchPolicy fetchPolicy = ApiDataFetchPolicy.cacheFirst,
  }) async {
    var result = await _productPriceRepository.getProductsPriceAndPriceList(
      businessId: businessId,
      productIds: productIds,
      branchId: branchId,
      fetchPolicy: fetchPolicy,
    );
    
    // Try again with network policy if cache fails
    if (!((result?.isPriceListsSuccessful() ?? false) && (result?.isProductPricesSuccessful() ?? false)) 
        && fetchPolicy == ApiDataFetchPolicy.cacheFirst) {
      result = await _productPriceRepository.getProductsPriceAndPriceList(
        businessId: businessId,
        productIds: productIds,
        branchId: branchId,
        fetchPolicy: ApiDataFetchPolicy.networkOnly,
      );
    }
    
    return result;
  }

  Future<ProductPriceResponse?> updateProductPrice({
    required String businessId,
    required String productId,
    required String productPriceId,
    required String priceListId,
    required String branchId,
    required List<Price> prices,
    bool isDefault = false,
  }) async {
    return await _productPriceRepository.updateProductPrice(
      businessId: businessId,
      productId: productId,
      productPriceId: productPriceId,
      priceListId: priceListId,
      branchId: branchId,
      prices: prices,
      isDefault: isDefault,
    );
  }
  
  Future<BusinessResponse?> addPriceListToBusiness({
    required String businessId,
    required List<LocalizedField> name,
    required List<LocalizedField> description,
    required List<String> branchIds,
  }) async {
    return await _productPriceRepository.addPriceListToBusiness(
      businessId: businessId,
      name: name,
      description: description,
      branchIds: branchIds,
    );
  }
  
  Future<BusinessResponse?> updateBusinessPriceList({
    required String businessId,
    required String priceListId,
    required List<LocalizedField> name,
    required List<LocalizedField> description,
    required List<String> branchIds,
    bool? isActive,
  }) async {
    return await _productPriceRepository.updateBusinessPriceList(
      businessId: businessId,
      priceListId: priceListId,
      name: name,
      description: description,
      branchIds: branchIds,
      isActive: isActive,
    );
  }

  Future<ProductPriceResponse?> createProductPrice({
    required String businessId,
    required String productId,
    required String priceListId,
    required String branchId,
    required List<Price> prices,
    bool isDefault = false,
  }) async {
    return await _productPriceRepository.createProductPrice(
      businessId: businessId,
      productId: productId,
      priceListId: priceListId,
      branchId: branchId,
      prices: prices,
      isDefault: isDefault,
    );
  }
} 