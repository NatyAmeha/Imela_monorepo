import 'package:imela_core/calendar/dto/calendar.response.dart';
import 'package:imela_core/calendar/repo/calendar.repository.dart';
import 'package:imela_core/product/dto/create_product.input.dart';
import 'package:imela_core/product/model/product_response.dart';
import 'package:imela_core/product/repo/product.repository.dart';
import 'package:imela_data/network/graphql/graphql_datasource.dart';
import 'package:injectable/injectable.dart';

@injectable
class ProductUsecase {
  final IProductRepository _productRepository;
  final ICalendarRepository _calendarRepository;

  const ProductUsecase(
    @Named(ProductRepository.injectName) this._productRepository,
    @Named(CalendarRepository.injectName) this._calendarRepository,
  );

  Future<ProductResponse?> getBusinessProducts(String businessId, {int page = 1, int pageSize = 20, ApiDataFetchPolicy fetchPolicy = ApiDataFetchPolicy.networkOnly}) async {
    return await _productRepository.getBusinessProducts(businessId, page: page, limit: pageSize, fetchPolicy: fetchPolicy);
  }

  Future<ProductResponse?> createProduct(String businessId, List<CreateProductInput> productInputs) async {
    return await _productRepository.createProduct(businessId, productInputs);
  }

  Future<ProductResponse?> getProductDetails(String productId, {String? branchId, ApiDataFetchPolicy fetchPolicy = ApiDataFetchPolicy.cacheFirst}) async {
    var result = await _productRepository.getProductDetails(productId, branchId: branchId, fetchPolicy: fetchPolicy);
    if (!(result?.isSuccessfull ?? false)) {
      result = await _productRepository.getProductDetails(productId, branchId: branchId, fetchPolicy: ApiDataFetchPolicy.networkOnly);
    }
    return result;
  }

  Future<CalendarResponse?> getProductCalendar(String calendarId, {ApiDataFetchPolicy fetchPolicy = ApiDataFetchPolicy.cacheFirst}) async {
    var result = await _calendarRepository.getCalendar(calendarId);
    if (!(result?.success ?? false) && fetchPolicy == ApiDataFetchPolicy.cacheFirst) {
      result = await _calendarRepository.getCalendar(calendarId, fetchPolicy: ApiDataFetchPolicy.networkOnly);
    }
    return result;
  }

  Future<CalendarResponse?> getProductsCalendar(String businessId, String branchId, List<String> productIds, {ApiDataFetchPolicy fetchPolicy = ApiDataFetchPolicy.cacheFirst}) async {
    var result = await _calendarRepository.getProductsCalendar(businessId: businessId, branchId: branchId, productIds: productIds, fetchPolicy: fetchPolicy);
    if (!(result?.success ?? false)) {
      result = await _calendarRepository.getProductsCalendar(businessId: businessId, branchId: branchId, productIds: productIds, fetchPolicy: ApiDataFetchPolicy.networkOnly);
    }
    return result;
  }
}
