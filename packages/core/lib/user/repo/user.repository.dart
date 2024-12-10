import 'package:imela_core/loyalty/dto/loyalty.response.dart';
import 'package:imela_core/shared/repository.intereface.dart';
import 'package:imela_core/user/dto/update_user_input.dart';
import 'package:imela_core/user/model/auth_response.dart';
import 'package:imela_core/user/model/user.response.dart';
import 'package:imela_data/network/graphql/auth/__generated__/update_profile.data.gql.dart';
import 'package:imela_data/network/graphql/auth/__generated__/update_profile.req.gql.dart';
import 'package:imela_data/network/graphql/graphql_datasource.dart';
import 'package:imela_data/network/graphql/loyalty/__generated__/get_customer_loyalties.data.gql.dart';
import 'package:imela_data/network/graphql/loyalty/__generated__/get_customer_loyalties.req.gql.dart';
import 'package:imela_data/network/graphql_exception.dart';
import 'package:imela_data/shared_pref/preference_datastore.dart';
import 'package:injectable/injectable.dart';

abstract class IUserRepository extends IRepository {
  Future<LoyaltyResponse> getUserLoyaltyRewards();
  Future<AuthResponse> updateProfile(UpdateUserInput input);
}

@Injectable(as: IUserRepository)
@Named(UserRepository.injectName)
class UserRepository implements IUserRepository {
  static const injectName = 'AUTH_REPOSITORY_INJECTION';

  final IGraphQLDataSource _graphQLDataSource;
  final ISharedPreferenceDataStore _sharedPreferenceDataStore;

  const UserRepository(
    @Named(GraphqlDatasource.injectName) this._graphQLDataSource,
    @Named(SharedPreferenceDataStore.injectName) this._sharedPreferenceDataStore,
  );

  @override
  Future<LoyaltyResponse> getUserLoyaltyRewards() async {
    final request = GGetMyLoyaltiesReq((b) => b..fetchPolicy = _graphQLDataSource.getFetchPolicy(ApiDataFetchPolicy.networkOnly));
    final response = await _graphQLDataSource.request<GGetMyLoyaltiesData>(request, type: 'GET_CUSTOMER_BUSINESS_LOYALTY', isMainError: false);
    if (response == null) {
      throw GraphqlException(message: 'Unable to get user loyalty rewards');
    }
    return LoyaltyResponse.fromJson(response.getCustomerLoyalties.toJson());
  }

  @override
  Future<AuthResponse> updateProfile(UpdateUserInput input) async {
    final request = GUpdateProfileReq((b) => b
      ..vars.input.update(
            (b) => b
              ..firstName = input.firstName
              ..lastName = input.lastName
              ..email = input.email
              ..profileImageUrl = input.profileImageUrl,
          ));
    final response = await _graphQLDataSource.request<GUpdateProfileData>(request, type: 'UPDATE_PROFILE', isMainError: false);
    if (response == null) {
      throw GraphqlException(message: 'Unable to update profile');
    }
    return AuthResponse.fromJson(response.updateProfileInfo.toJson());
  }
}
