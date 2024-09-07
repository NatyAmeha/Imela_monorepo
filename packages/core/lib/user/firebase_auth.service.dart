import 'dart:async';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:imela_core/user/model/auth_response.dart';
import 'package:imela_utils/exception/app_exception.dart';
import 'package:injectable/injectable.dart';

abstract class IAuthService {
  Future<IAuthResponse> signInWithPhoneNumber(String phoneNumber);
  Future<IAuthResponse> verifyPhoneNumber(String verificationId, String smsCode);
  Future<void> signInWithGoogle();
  Future<void> signOut();
}

@LazySingleton(as: IAuthService)
@Named(FirebaseAuthService.injectName)
class FirebaseAuthService implements IAuthService {
  static const injectName = 'FIREBASE_AUTH_SERVICE_INJECTION';
  @override
  Future<void> signInWithGoogle() {
    // TODO: implement signInWithGoogle
    throw UnimplementedError();
  }

  @override
  Future<IAuthResponse> signInWithPhoneNumber(String phoneNumber) async {
    final firebaseAuth = FirebaseAuth.instance;
    final completer = Completer<FirebaseAuthResponse>();
    try {
      await firebaseAuth.verifyPhoneNumber(
        phoneNumber: phoneNumber,
        verificationCompleted: (PhoneAuthCredential credential) async {
          await firebaseAuth.signInWithCredential(credential);
          return completer.complete(Future.value(FirebaseAuthResponse(authenticated: true)));
        },
        verificationFailed: (FirebaseAuthException e) {
          var message = e.message;
          if (e.code == 'invalid-phone-number') {
            message = 'The provided phone number is not valid.';
          }
          return completer.complete(Future.value(FirebaseAuthResponse(authenticated: false, errorMsg: message)));
        },
        codeSent: (String verificationId, int? resendToken) {
          return completer.complete(Future.value(FirebaseAuthResponse(authenticated: false, verificationId: verificationId)));
        },
        codeAutoRetrievalTimeout: (String verificationId) {
          return completer.complete(Future.value(FirebaseAuthResponse(authenticated: false, errorMsg: 'timeout', verificationId: verificationId)));
        },
        autoRetrievedSmsCodeForTesting: '123456',
      );
      return completer.future;
    } catch (e) {
      print('error: $e');
      throw AppException(message: 'An error occured while trying to sign in with phone number');
    }
  }

  @override
  Future<IAuthResponse> verifyPhoneNumber(String verificationId, String smsCode) async {
    try {
      final credential = PhoneAuthProvider.credential(verificationId: verificationId, smsCode: smsCode);
      final result = await FirebaseAuth.instance.signInWithCredential(credential);
      if (result.user != null) {
        return FirebaseAuthResponse(authenticated: true);
      }
      return FirebaseAuthResponse(authenticated: false, errorMsg: 'An error occured while trying to verify phone number');
    } catch (ex) {
      print('error: $ex');
      throw AppException(message: 'An error occured while trying to verify phone number');
    }
  }

  @override
  Future<void> signOut() {
    // TODO: implement signOut
    throw UnimplementedError();
  }
}
