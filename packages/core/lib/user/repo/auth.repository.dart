import 'package:imela_core/shared/repository.intereface.dart';
import 'package:imela_core/user/dto/user_signup_input.dart';
import 'package:imela_core/user/model/auth_response.dart';
import 'package:imela_data/injection.dart';
import 'package:imela_data/network/graphql/auth/__generated__/authenticate_staff.data.gql.dart';
import 'package:imela_data/network/graphql/auth/__generated__/authenticate_staff.req.gql.dart';
import 'package:imela_data/network/graphql/auth/__generated__/refresh_token.data.gql.dart';
import 'package:imela_data/network/graphql/auth/__generated__/refresh_token.req.gql.dart';
import 'package:imela_data/network/graphql/auth/__generated__/signin_with_email.data.gql.dart';
import 'package:imela_data/network/graphql/auth/__generated__/signin_with_email.req.gql.dart';
import 'package:imela_data/network/graphql/auth/__generated__/signup_signin_with_phone.data.gql.dart';
import 'package:imela_data/network/graphql/auth/__generated__/signup_signin_with_phone.req.gql.dart';
import 'package:imela_data/network/graphql/auth/__generated__/signup_with_email.data.gql.dart';
import 'package:imela_data/network/graphql/auth/__generated__/signup_with_email.req.gql.dart';
import 'package:imela_data/network/graphql/graphql_config.dart';
import 'package:imela_data/network/graphql/graphql_datasource.dart';
import 'package:imela_data/network/graphql_exception.dart';
import 'package:imela_data/shared_pref/preference_datastore.dart';
import 'package:imela_data/shared_pref/preference_exception.dart';
import 'package:imela_data/shared_pref/shared_preference.constant.dart';
import 'package:imela_utils/exception/app_exception.dart';
import 'package:injectable/injectable.dart';

abstract class IAuthRepository extends IRepository {
  Future<AuthResponse> signinOrSignupUsingPhoneNumber(String phoneNumber);
  Future<AuthResponse> registerUser(UserEmailSignupInput signupInput);
  Future<AuthResponse> loginWithEmail(String email, String password);
  Future<AuthResponse> refreshToken();
  Future<bool> saveAuthCredentialToPreference(AuthResponse authResponse);

  Future<bool> removeAuthCredentialFromPreference();
  Future<AuthResponse> getAuthInfoFromPreference();
  Future<AuthResponse> generateTokenForStaff(String phoneNumber);
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
  Future<AuthResponse> registerUser(UserEmailSignupInput signupInput) async {
    updateDIValue<bool>(ClientInterceptor.BYPASS_TOKEN_VALIDATION, true);
    final request = GSignUpWithEmailReq(
      (b) => b
        ..vars.signUpInfo.update((b) {
          b.firstName = signupInput.firstName;
          b.email = signupInput.email;
          b.password = signupInput.password;
          b.phoneNumber = signupInput.phoneNumber;
        })
        ..fetchPolicy = _graphQLDataSource.getFetchPolicy(ApiDataFetchPolicy.networkOnly),
    );
    final result = await _graphQLDataSource.request<GSignUpWithEmailData>(request, type: 'SIGNUP_WITH_EMAIL', isMainError: true);
    if (result?.createUserAccountUsingEmailPassword == null) {
      throw GraphqlException(message: 'Unable to login with phone number');
    }
    final responseData = AuthResponse.fromJson(result!.createUserAccountUsingEmailPassword.toJson());
    if (!responseData.isSuccessfull) {
      throw AppException(message: 'An error occured while trying to sign in with phone number');
    }
    updateDIValue<bool>(ClientInterceptor.BYPASS_TOKEN_VALIDATION, false);
    return responseData;
  }

  @override
  Future<AuthResponse> loginWithEmail(String email, String password) async {
    final req = GSigninWithEmailReq(
      (b) => b
        ..vars.email = email
        ..vars.password = password
        ..fetchPolicy = _graphQLDataSource.getFetchPolicy(ApiDataFetchPolicy.networkOnly),
    );
    final result = await _graphQLDataSource.request<GSigninWithEmailData>(req, type: 'SIGNIN_WITH_EMAIL', isMainError: true);
    if (result?.signInWithEmailAndPassword == null) {
      throw GraphqlException(message: 'Unable to login with email and password');
    }
    final responseData = AuthResponse.fromJson(result!.signInWithEmailAndPassword.toJson());
    if (!responseData.isSuccessfull) {
      throw AppException(message: 'An error occured while trying to sign in with phone number');
    }
    return responseData;
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
    if (!responseData.isSuccessfull) {
      throw AppException(message: 'An error occured while trying to sign in with phone number');
    }
    final saveResult = await saveAuthCredentialToPreference(responseData);
    if (!saveResult) {
      throw PreferenceException(source: 'Signin with email', errorMessage: 'An error occured while trying to save user credential');
    }
    updateDIValue<bool>(ClientInterceptor.BYPASS_TOKEN_VALIDATION, false);
    return responseData;
  }

  @override
  Future<AuthResponse> generateTokenForStaff(String phoneNumber) async {
    final request = GGenerateTokenForStaffReq((b) => b
      ..vars.phoneNumber = phoneNumber
      ..fetchPolicy = _graphQLDataSource.getFetchPolicy(ApiDataFetchPolicy.networkOnly));
    final result = await _graphQLDataSource.request<GGenerateTokenForStaffData>(request, type: 'GENERATE_TOKEN_FOR_STAFF', isMainError: true);
    if (result?.generateTokenForStaff == null) {
      throw GraphqlException(message: 'Unable to generate token for staff');
    }
    final responseData = AuthResponse.fromJson(result!.generateTokenForStaff.toJson());
    return responseData;
  }

  @override
  Future<AuthResponse> refreshToken() async {
    final request = GRefreshTokenReq(
      (b) => b..fetchPolicy = _graphQLDataSource.getFetchPolicy(ApiDataFetchPolicy.networkOnly),
    );
    final result = await _graphQLDataSource.request<GRefreshTokenData>(request, type: 'REFRESH_TOKEN', isMainError: true);
    if (result?.refreshToken == null) {
      throw GraphqlException(message: 'Unable to refresh token');
    }
    final responseData = AuthResponse.fromJson(result!.refreshToken.toJson());
    if (!responseData.isSuccessfull) {
      throw AppException(message: 'An error occured while trying to refresh token');
    }
    return responseData;
  }

  @override
  Future<AuthResponse> getAuthInfoFromPreference() async {
    final accessToken = await _sharedPreferenceDataStore.get<String>(SharedPreferenceConstant.ACCESS_TOKEN);
    final refreshToken = await _sharedPreferenceDataStore.get<String>(SharedPreferenceConstant.REFRESH_TOKEN);
    final isNewUser = await _sharedPreferenceDataStore.get<bool>(SharedPreferenceConstant.IS_NEW_USER);
    return AuthResponse(success: true, accessToken: accessToken, refreshToken: refreshToken, isNewUser: isNewUser);
  }

  @override
  Future<bool> saveAuthCredentialToPreference(AuthResponse authResponse) async {
    var result = false;
    result = await _sharedPreferenceDataStore.create<bool, String>(SharedPreferenceConstant.ACCESS_TOKEN, authResponse.accessToken!);
    if (authResponse.refreshToken != null) {
      result = await _sharedPreferenceDataStore.create(SharedPreferenceConstant.REFRESH_TOKEN, authResponse.refreshToken!);
    }
    if (authResponse.isNewUser != null) {
      result = await _sharedPreferenceDataStore.create(SharedPreferenceConstant.IS_NEW_USER, authResponse.isNewUser!);
    }
    if (!result) {
      throw PreferenceException(source: 'Refresh token', errorMessage: 'An error occured while trying to save user credential');
    }
    return result;
  }

  @override
  Future<bool> removeAuthCredentialFromPreference() async {
    var result = false;
    result = await _sharedPreferenceDataStore.delete(SharedPreferenceConstant.ACCESS_TOKEN);
    result = await _sharedPreferenceDataStore.delete(SharedPreferenceConstant.REFRESH_TOKEN);
    result = await _sharedPreferenceDataStore.delete(SharedPreferenceConstant.IS_NEW_USER);
    return result;
  }
}
