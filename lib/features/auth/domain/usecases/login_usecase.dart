import 'package:firebase_auth/firebase_auth.dart';

import '../repositories/login_repository.dart';

class LoginUsecase {
  final LoginRepository repository;
  LoginUsecase({required this.repository});
  
  Future<UserCredential?> login(String email, String password) async{
    return repository.login(email, password);
  }

  Future<UserCredential?> register(String username, String email, String password) async{
    return repository.register(username, email, password);
  }

  Future<void> loginWithGoogle() async{
    return repository.loginWithGoogle();
  }
}