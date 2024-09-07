import 'package:imela_core/user/model/auth_response.dart';
import 'package:imela_data/injection.dart';
import 'package:imela_data/network/graphql/auth/__generated__/signup_signin_with_phone.data.gql.dart';
import 'package:imela_data/network/graphql/auth/__generated__/signup_signin_with_phone.req.gql.dart';
import 'package:imela_data/network/graphql/graphql_config.dart';
import 'package:imela_data/network/graphql/graphql_datasource.dart';
import 'package:imela_data/network/graphql_exception.dart';
import 'package:imela_data/shared_pref/preference_datastore.dart';
import 'package:imela_data/shared_pref/shared_preference.constant.dart';
import 'package:imela_utils/exception/app_exception.dart';
import 'package:injectable/injectable.dart';
import '../../shared/repository.intereface.dart';
import '../model/user.response.dart';

abstract class IAuthRepository extends IRepository {
  Future<AuthResponse> signinOrSignupUsingPhoneNumber(String phoneNumber);
  Future<UserResponse> loginWithEmail(String email, String password);
  Future<AuthResponse> getAuthInfoFromPreference();
}

@Injectable(as: IAuthRepository)
@Named(AuthRepository.injectName)
class AuthRepository implements IAuthRepository {
  static const injectName = 'AUTH_REPOSITORY_INJECTION';

  final IGraphQLDataSource _graphQLDataSource;
  final ISharedPreferenceDataStore _sharedPreferenceDataStore;

  const AuthRepository(
    @Named(GraphqlDatasource.injectName) this._graphQLDataSource,
    @Named(SharedPreferenceDataStore.injectName) this._sharedPreferenceDataStore,
  );
  @override
  Future<UserResponse> loginWithEmail(String email, String password) {
    throw UnimplementedError();
  }

  @override
  Future<AuthResponse> signinOrSignupUsingPhoneNumber(String phoneNumber) async {
    updateDIValue<bool>(ClientInterceptor.BYPASS_TOKEN_VALIDATION, true);
    final request = GSignInWithPhoneReq(
      (b) => b
        ..vars.phone = phoneNumber
        ..fetchPolicy = _graphQLDataSource.getFetchPolicy(ApiDataFetchPolicy.networkOnly),
    );
    final result = await _graphQLDataSource.request<GSignInWithPhoneData>(request, type: 'SIGNIN_WITH_PHONE', isMainError: true);
    if (result?.signInWithPhoneNumber == null) {
      throw GraphqlException(message: 'Unable to login with phone number');
    }
    final responseData = AuthResponse.fromJson(result!.signInWithPhoneNumber.toJson());
    if(!responseData.isSuccessfull){
      throw AppException(message: 'An error occured while trying to sign in with phone number');
    }
    await _sharedPreferenceDataStore.create<bool, String>(SharedPreferenceConstant.ACCESS_TOKEN, responseData.accessToken!);
    await _sharedPreferenceDataStore.create(SharedPreferenceConstant.REFRESH_TOKEN, responseData.refreshToken!);
    await _sharedPreferenceDataStore.create(SharedPreferenceConstant.IS_NEW_USER, responseData.isNewUser!);
    updateDIValue<bool>(ClientInterceptor.BYPASS_TOKEN_VALIDATION, false);
    return responseData;
  }

  @override
  Future<AuthResponse> getAuthInfoFromPreference() async {
    final accessToken = await _sharedPreferenceDataStore.get<String>(SharedPreferenceConstant.ACCESS_TOKEN);
    final refreshToken = await _sharedPreferenceDataStore.get<String>(SharedPreferenceConstant.REFRESH_TOKEN);
    final isNewUser = await _sharedPreferenceDataStore.get<bool>(SharedPreferenceConstant.IS_NEW_USER);
    return AuthResponse(success: true, accessToken: accessToken, refreshToken: refreshToken, isNewUser: isNewUser);
  }
}
