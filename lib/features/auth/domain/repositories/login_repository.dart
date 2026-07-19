import 'package:firebase_auth/firebase_auth.dart';

import '../../data/models/user_model.dart';

abstract class LoginRepository{
  Future<UserCredential?> login(String email, String password);
  Future<UserCredential?> register(String username, String email, String password);
  Future<UserModel> getUser(String email);
  Future<void> logout();
  Future<void> loginWithGoogle();
}