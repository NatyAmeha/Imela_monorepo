import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:imela_core/user/model/auth_response.dart';
import 'package:imela_utils/exception/app_exception.dart';
import 'package:injectable/injectable.dart';
import 'package:jwt_decode/jwt_decode.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'package:imela_core/user/model/user.model.dart' as AppUser;

abstract class IAuthService {
  Future<IAuthResponse> signInWithPhoneNumber(String phoneNumber);
  Future<IAuthResponse> verifyPhoneNumber(String verificationId, String smsCode);
  Future<IAuthResponse> signInWithGoogle();
  Future<void> signOut();
  Future<AppUser.User?> getCurrentUser(String token);
}

@LazySingleton(as: IAuthService)
@Named(FirebaseAuthService.injectName)
class FirebaseAuthService implements IAuthService {
  static const injectName = 'FIREBASE_AUTH_SERVICE_INJECTION';

  @override
  Future<IAuthResponse> signInWithGoogle() async {
    try {
      final GoogleAuthProvider googleProvider = GoogleAuthProvider();
      final firebaseAuth = FirebaseAuth.instance;
      if (kIsWeb) {
        // Handle web platform sign in
        final UserCredential userCredential = await firebaseAuth.signInWithPopup(googleProvider);
        if (userCredential.user != null) {
          final userInfo = AppUser.User(
            id: userCredential.user!.uid,
            email: userCredential.user!.email,
            username: userCredential.user!.displayName,
            phoneNumber: userCredential.user!.phoneNumber,
            profileImageUrl: userCredential.user!.photoURL,
          );
          return FirebaseAuthResponse(authenticated: true, user: userInfo);
        }
        return FirebaseAuthResponse(authenticated: false, errorMsg: 'An error occured while trying to sign in with google');
      } else {
        // Handle native platform sign in
        final UserCredential userCredential = await firebaseAuth.signInWithProvider(googleProvider);

        if (userCredential.user != null) {
          final userInfo = AppUser.User(
            id: userCredential.user!.uid,
            email: userCredential.user!.email,
            username: userCredential.user!.displayName,
            phoneNumber: userCredential.user!.phoneNumber,
            profileImageUrl: userCredential.user!.photoURL,
          );
          return FirebaseAuthResponse(authenticated: true, user: userInfo);
        }
        return FirebaseAuthResponse(authenticated: false, errorMsg: 'An error occured while trying to sign in with google');
      }
    } catch (e) {
      print('Google SignIn Error: $e');
    }
    throw AppException(message: 'An error occured while trying to sign in with google');
  }

  @override
  Future<IAuthResponse> signInWithPhoneNumber(String phoneNumber) async {
    final firebaseAuth = FirebaseAuth.instance;
    final completer = Completer<FirebaseAuthResponse>();
    try {
      // For web platform
      if (kIsWeb) {
        final formattedPhone = phoneNumber.startsWith('+') ? phoneNumber : '+$phoneNumber';
        try {
          final confirmationResult = await firebaseAuth.signInWithPhoneNumber(formattedPhone);
          print('SMS sent successfully, verification ID: ${confirmationResult.verificationId}');
          return FirebaseAuthResponse(authenticated: false, verificationId: confirmationResult.verificationId);
        } catch (signInError) {
          print('Error during signInWithPhoneNumber: $signInError');
          throw AppException(message: 'Failed to send SMS verification code');
        }
      }
      // For native platforms
      else {
        await firebaseAuth.verifyPhoneNumber(
          phoneNumber: phoneNumber,
          timeout: const Duration(seconds: 120),
          verificationCompleted: (PhoneAuthCredential credential) async {
            await firebaseAuth.signInWithCredential(credential);
            completer.complete(FirebaseAuthResponse(authenticated: true));
          },
          verificationFailed: (FirebaseAuthException e) {
            var message = e.message;
            if (e.code == 'invalid-phone-number') {
              message = 'The provided phone number is not valid.';
            }
            completer.complete(FirebaseAuthResponse(authenticated: false, errorMsg: message));
          },
          codeSent: (String verificationId, int? resendToken) {
            print('response verificationId $verificationId');
            completer.complete(FirebaseAuthResponse(authenticated: false, verificationId: verificationId));
          },
          codeAutoRetrievalTimeout: (String verificationId) {
            completer.complete(FirebaseAuthResponse(authenticated: false, errorMsg: 'SMS code timeout', verificationId: verificationId));
          },
        );
        return completer.future;
      }
    } catch (e) {
      print('SignIn Error: $e');
      throw AppException(message: 'An error occurred while trying to sign in with phone number');
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

  // will be moved to a different service
  @override
  Future<AppUser.User?> getCurrentUser(String token) async {
    try {
      final jwtData = Jwt.parseJwt(token);
      final user = AppUser.User.FromJwt(jwtData);
      return user;
    } catch (e) {
      throw AppException(message: 'An error occured while trying to get current user');
    }
  }

  @override
  Future<void> signOut() {
    // TODO: implement signOut
    throw UnimplementedError();
  }
}
