import 'package:injectable/injectable.dart';
import 'package:imela/data/network/graphql_datasource.dart';
import 'package:imela/data/network/product_response.dart';
import 'package:imela/domain/product/repo/product.repository.dart';

@injectable
class ProductUsecase {
  final IProductRepository _productRepository;


  const ProductUsecase(@Named(ProductRepository.injectName) this._productRepository);

  Future<ProductResponse?> getProductDetails(String productId, {ApiDataFetchPolicy fetchPolicy = ApiDataFetchPolicy.cacheFirst}) async {
    final result = await _productRepository.getProductDetails(productId, fetchPolicy: fetchPolicy);
    return result;
  }
}
