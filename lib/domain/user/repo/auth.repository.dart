import 'package:injectable/injectable.dart';
import 'package:melegna_customer/domain/shared/repository.intereface.dart';
import 'package:melegna_customer/domain/user/model/user.response.dart';

abstract class IAuthRepository extends IRepository {
  Future<UserResponse> loginWithPhoneNumber(String phoneNumber);
  Future<UserResponse> loginWithEmail(String email, String password);
}

@Injectable(as: IAuthRepository)
@Named(AuthRepository.injectName)
class AuthRepository implements IAuthRepository {
  static const injectName = 'AUTH_REPOSITORY_INJECTION';
  @override
  Future<UserResponse> loginWithEmail(String email, String password) {
    throw UnimplementedError();
  }

  @override
  Future<UserResponse> loginWithPhoneNumber(String phoneNumber) {
    throw UnimplementedError();
  }

}