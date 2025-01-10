import 'package:imela_core/user/dto/user_signup_input.dart';
import 'package:imela_core/user/model/user.model.dart';
import 'package:imela_data/injection.dart';
import 'package:imela_data/network/graphql/graphql_config.dart';
import 'package:imela_data/shared_pref/preference_exception.dart';

import 'firebase_auth.service.dart';
import 'model/auth_response.dart';
import 'package:injectable/injectable.dart';
import 'repo/auth.repository.dart';

@injectable
class AuthUsecase {
  final IAuthRepository _authRepo;
  final IAuthService _authService;

  AuthUsecase(
    @Named(AuthRepository.injectName) this._authRepo,
    @Named(FirebaseAuthService.injectName) this._authService,
  );

  Future<User?> getCurrentUserInfoFromJwt() async {
    final authResponse = await _authRepo.getAuthInfoFromPreference();
    if (authResponse.accessToken != null) {
      final userInfo = await _authService.getCurrentUser(authResponse.accessToken!);
      return userInfo;
    }
    return null;
  }

  Future<AuthResponse?> signInWithEmailAndPassword(String email, String password) async {
    final authResponse = await _authRepo.loginWithEmail(email, password);
    if (authResponse.isSuccessfull) {
      await _authRepo.saveAuthCredentialToPreference(authResponse);
    }
    return authResponse;
  }

  Future<AuthResponse> getAuthInfoFromPreference() async {
    return await _authRepo.getAuthInfoFromPreference();
  }

  Future<IAuthResponse> continueWithPhoneNumber(String phoneNumber) async {
    final firebaseAuthResponse = await _authService.signInWithPhoneNumber(phoneNumber) as FirebaseAuthResponse;
    if (firebaseAuthResponse.authenticated) {
      final apiResponse = await _authRepo.signinOrSignupUsingPhoneNumber(phoneNumber);
      return apiResponse;
    }
    // let the ui navigate to the next screen to enter the sms code
    return firebaseAuthResponse;
  }

  Future<AuthResponse> continueWithGoogle() async {
    final firebaseAuthResponse = await _authService.signInWithGoogle() as FirebaseAuthResponse;
    if (firebaseAuthResponse.authenticated && firebaseAuthResponse.user?.id != null) {
      final apiResponse = await _authRepo.getUserByGoogleId(firebaseAuthResponse.user!.id!);
      if (apiResponse.success && apiResponse.user != null) {
        await _authRepo.saveAuthCredentialToPreference(apiResponse);
        return AuthResponse(success: true, user: apiResponse.user, googleId: firebaseAuthResponse.user!.id);
      }
      return AuthResponse(success: false, user: firebaseAuthResponse.user, message: 'An error occured while trying to sign in with google');
    }
    return const AuthResponse(success: false, message: 'An error occured while trying to sign in with google');
  }

  Future<AuthResponse> verifyPhoneNumber(String phoneNumber, String verificationId, String smsCode) async {
    final firebaseAuthResponse = await _authService.verifyPhoneNumber(verificationId, smsCode) as FirebaseAuthResponse;
    if (firebaseAuthResponse.authenticated) {
      final apiResponse = await _authRepo.signinOrSignupUsingPhoneNumber(phoneNumber);
      return apiResponse;
    }
    return const AuthResponse(success: false, message: 'An error occured while trying to sign in with phone number');
  }

  Future<AuthResponse> register({String? firstName, String? email, String? password, String? phoneNumber, String? googleId}) async {
    final signupInfo = SignupInput.getEmailSignupInput(email: email, firstName: firstName, phoneNumber: phoneNumber, googleId: googleId);
    final authResponse = await _authRepo.registerUser(signupInfo);
    if (authResponse.isSuccessfull) {
      await _authRepo.saveAuthCredentialToPreference(authResponse);
    }
    return authResponse;
  }

  Future<AuthResponse> registerWithGoogleAccountData(SignupInput signupInput) async {
    final authResponse = await _authRepo.registerUserWithGoogleAccountData(signupInput);
    if (authResponse.isSuccessfull) {
      await _authRepo.saveAuthCredentialToPreference(authResponse);
    }
    return authResponse;
  }

  Future<bool> refreshToken() async {
    final refreshTokenResult = await _authRepo.refreshToken();
    await _authRepo.saveAuthCredentialToPreference(refreshTokenResult);
    updateDIValue<bool>(ClientInterceptor.BYPASS_TOKEN_VALIDATION, false);
    return refreshTokenResult.isSuccessfull;
  }

  Future<bool> logout() async {
    resetGraphQlClientInstance();
    return await _authRepo.removeAuthCredentialFromPreference();
  }
}
