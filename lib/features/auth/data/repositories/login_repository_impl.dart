import 'package:expense_tracker/features/auth/data/models/user_model.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/rendering.dart';

import '../datasource/auth_remote_datasource.dart';
import '../../domain/repositories/login_repository.dart';
import '../datasource/auth_local_datasource.dart';

class LoginRepositoryImpl implements LoginRepository{
  final AuthRemoteDataSource authRemoteDataSource;
  final AuthLocalDataSource authLocalDatasource;
  LoginRepositoryImpl({
    required this.authLocalDatasource,
    required this.authRemoteDataSource
  });

  @override
  Future<UserCredential?> login(String email, String password) async {
    try {
      UserCredential credential = await authRemoteDataSource.login(email: email, password: password);
      if(credential.user != null){
        return credential;
      }
      return null;
    } catch (e) {
      throw Exception("Login repository error [login] : $e");
    }
  }

  @override
  Future<void> loginWithGoogle() {
    // TODO: implement loginWithGoogle
    throw UnimplementedError();
  }
  
  @override
  Future<UserCredential?> register(String username, String email, String password) async{
    try {
      UserCredential credential = await authRemoteDataSource.register(email: email, password: password);
      await authLocalDatasource.register(username, email, password);
      if(credential.user != null){
        return credential;
      }
      return null;
    } catch (e) {
      throw Exception("Login repository error [register] : $e");
    }
  }

  @override
  Future<UserModel> getUser(String email) async{
    try {
      UserModel? user = await authLocalDatasource.getUserData(email);
      if(user != null){
        return user;
      }throw Exception("There is user with this email");
    } catch (e) {
      debugPrint("Login repository error [get user] error : $e");
      throw Exception("Login repository error [get user] error : $e");
    }
  }
}
