import 'package:injectable/injectable.dart';
import 'package:imela/domain/user/model/user.response.dart';
import 'package:imela/domain/user/repo/auth.repository.dart';

@injectable
class AuthUsecase {
  final IAuthRepository _authRepo;

  AuthUsecase(@Named(AuthRepository.injectName) this._authRepo);

  Future<UserResponse> login(String email, String password) async {
    return await _authRepo.loginWithEmail(email, password);
  }

  Future<UserResponse> register(String email, String password) async {
    // return await _authRepo.register(email, password);
    throw UnimplementedError();
  }
}
