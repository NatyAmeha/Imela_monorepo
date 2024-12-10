import 'package:imela_core/customer/dto/customer.response.dart';
import 'package:imela_core/customer/dto/customer_input.dart';
import 'package:imela_core/customer/model/customer.model.dart';
import 'package:imela_data/injection.dart';
import 'package:imela_data/network/graphql/__generated__/schema.schema.gql.dart';
import 'package:imela_data/network/graphql/customer/__generated__/add_customer_to_business.data.gql.dart';
import 'package:imela_data/network/graphql/customer/__generated__/add_customer_to_business.req.gql.dart';
import 'package:imela_data/network/graphql/customer/__generated__/get_business_customer.data.gql.dart';
import 'package:imela_data/network/graphql/customer/__generated__/get_business_customer.req.gql.dart';
import 'package:imela_data/network/graphql/graphql_config.dart';
import 'package:imela_data/network/graphql/graphql_datasource.dart';
import 'package:injectable/injectable.dart';

abstract class ICustomerRepository {
  Future<CustomerResponse?> getBusinessCustomer(String businessId, int page, int limit, {required ApiDataFetchPolicy fetchPolicy});
  Future<CustomerResponse?> createCustomer(String businessId, List<CreateCustomerData> customers);
}

@Injectable(as: ICustomerRepository)
@Named(CustomerRepository.injectName)
class CustomerRepository implements ICustomerRepository {
  static const injectName = 'CUSTOMER_REPOSITORY_INJECTION';
  final IGraphQLDataSource _graphQLDataSource;

  const CustomerRepository(@Named(GraphqlDatasource.injectName) this._graphQLDataSource);

  @override
  Future<CustomerResponse?> getBusinessCustomer(String businessId, int page, int limit, {required ApiDataFetchPolicy fetchPolicy}) async {
    final req = GGetBusinessCustomerReq((b) => b
      ..vars.businessId = businessId
      ..vars.page = page.toDouble()
      ..vars.limit = limit.toDouble()
      ..fetchPolicy = _graphQLDataSource.getFetchPolicy(fetchPolicy));

    final result = await _graphQLDataSource.request<GGetBusinessCustomerData>(req, type: 'Get Business Customers', isMainError: true);
    if (result == null) {
      return null;
    }
    return CustomerResponse.fromJson(result.getBusinessCustomers.toJson());
  }

  @override
  Future<CustomerResponse?> createCustomer(String businessId, List<CreateCustomerData> customers) async {
    updateDIValue<bool>(ClientInterceptor.BYPASS_TOKEN_VALIDATION, true);
    final req = GAddCustomerToBusinessReq((b) => b
      ..vars.businessId = businessId
      ..vars.customers.addAll(customers.map((c) => GCreateCustomerInput((b) => b
        ..name = c.firstName
        ..phoneNumber = c.phoneNumber
        ..email = c.email))));
    final result = await _graphQLDataSource.request<GAddCustomerToBusinessData>(req, type: 'Add Customer To Business', isMainError: true);
    if (result == null) {
      return null;
    }
    updateDIValue<bool>(ClientInterceptor.BYPASS_TOKEN_VALIDATION, false); 

    return CustomerResponse.fromJson(result.addBusinessCustomers.toJson());
  }
}
