import 'package:imela_core/loyalty/dto/loyalty.response.dart';
import 'package:imela_core/user/dto/update_user_input.dart';
import 'package:imela_core/user/model/auth_response.dart';
import 'package:imela_core/user/model/user.response.dart';
import 'package:imela_core/user/repo/auth.repository.dart';
import 'package:imela_core/user/repo/user.repository.dart';
import 'package:injectable/injectable.dart';

@injectable
class UserUsecase {
  final IUserRepository _userRepo;
  final IAuthRepository _authRepo;

  const UserUsecase(
    @Named(UserRepository.injectName) this._userRepo,
    @Named(AuthRepository.injectName) this._authRepo,
  );

  Future<LoyaltyResponse?> getUserLoyaltyRewards() async {
    final result = await _userRepo.getUserLoyaltyRewards();
    return result;
  }

  Future<AuthResponse> updateProfile(UpdateUserInput input) async {
    final authResponse = await _userRepo.updateProfile(input);
    final saveToPreferenceResult = await _authRepo.saveAuthCredentialToPreference(authResponse);
    if (!saveToPreferenceResult) {
    }
    return authResponse;
  }
}
