import 'package:imela_core/customer/dto/customer.response.dart';
import 'package:imela_core/customer/model/customer.model.dart';
import 'package:imela_core/customer/repo/customer_repository.dart';
import 'package:imela_data/network/graphql/graphql_datasource.dart';
import 'package:injectable/injectable.dart';
import 'package:imela_core/customer/dto/customer_input.dart';

@injectable
class CustomerUsecase {
  final ICustomerRepository _customerRepository;

  const CustomerUsecase(@Named(CustomerRepository.injectName) this._customerRepository);


  Future<CustomerResponse?> getBusinessCustomer(String businessId, int page, int limit, {ApiDataFetchPolicy fetchPolicy = ApiDataFetchPolicy.cacheFirst}) async {
    var result =  await _customerRepository.getBusinessCustomer(businessId, page, limit, fetchPolicy: fetchPolicy);

    return result;
  }

  Future<CustomerResponse?> createCustomer(String businessId, List<CreateCustomerData> customers) async {
    return await _customerRepository.createCustomer(businessId, customers);
  }
}
