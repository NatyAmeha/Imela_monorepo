import 'package:imela_core/product/model/product_response.dart';
import 'package:imela_core/product/repo/product.repository.dart';
import 'package:imela_data/network/graphql/graphql_datasource.dart';
import 'package:injectable/injectable.dart';

@injectable
class ProductUsecase {
  final IProductRepository _productRepository;

  const ProductUsecase(@Named(ProductRepository.injectName) this._productRepository);

  Future<ProductResponse?> getProductDetails(String productId, {ApiDataFetchPolicy fetchPolicy = ApiDataFetchPolicy.cacheFirst}) async {
    var result = await _productRepository.getProductDetails(productId, fetchPolicy: fetchPolicy);
    if (!(result?.isSuccessfull ?? false)) {
      result = await _productRepository.getProductDetails(productId, fetchPolicy: ApiDataFetchPolicy.networkOnly);
    }
    return result;
  }
}
