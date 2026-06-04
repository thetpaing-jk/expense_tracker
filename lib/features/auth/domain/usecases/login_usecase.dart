import '../repositories/login_repository.dart';

class LoginUsecase {
  final LoginRepository repository;
  LoginUsecase({required this.repository});
  
  Future<void> login(String username, String password) async{
    return repository.login(username, password);
  }

  Future<void> loginWithGoogle() async{
    return repository.loginWithGoogle();
  }
}