import 'firebase_auth.service.dart';
import 'model/auth_response.dart';
import 'package:injectable/injectable.dart';
import 'model/user.response.dart';
import 'repo/auth.repository.dart';

@injectable
class AuthUsecase {
  final IAuthRepository _authRepo;
  final IAuthService _authService;

  AuthUsecase(
    @Named(AuthRepository.injectName) this._authRepo,
    @Named(FirebaseAuthService.injectName) this._authService,
  );

  Future<UserResponse> login(String email, String password) async {
    return await _authRepo.loginWithEmail(email, password);
  }

  Future<AuthResponse> getAuthInfoFromPreference(){
    return _authRepo.getAuthInfoFromPreference();

  }

  Future<IAuthResponse> continueWithPhoneNumber(String phoneNumber) async {
    final firebaseAuthResponse = await _authService.signInWithPhoneNumber(phoneNumber) as FirebaseAuthResponse;
    if(firebaseAuthResponse.authenticated){
      final apiResponse = await _authRepo.signinOrSignupUsingPhoneNumber(phoneNumber);
      return apiResponse;
    }
    // let the ui navigate to the next screen to enter the sms code
    return firebaseAuthResponse;
  }

  Future<AuthResponse> verifyPhoneNumber(String phoneNumber,  String verificationId, String smsCode) async {
    final firebaseAuthResponse = await _authService.verifyPhoneNumber(verificationId, smsCode) as FirebaseAuthResponse;
    if(firebaseAuthResponse.authenticated){
      final apiResponse = await _authRepo.signinOrSignupUsingPhoneNumber(phoneNumber);
      return apiResponse;
    }
    return const AuthResponse(success: false, message: 'An error occured while trying to sign in with phone number');
  }

  Future<UserResponse> register(String email, String password) async {
    // return await _authRepo.register(email, password);
    throw UnimplementedError();
  }
}
