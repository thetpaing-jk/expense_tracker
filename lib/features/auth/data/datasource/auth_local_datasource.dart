import 'package:flutter/rendering.dart';
import 'package:sqflite/sqlite_api.dart';

import '../../../../core/database/database_service.dart';
import '../../../../core/utils/app_const.dart';
import '../models/user_model.dart';

abstract class AuthLocalDataSource{
  Future<void> logout();
  Future<void> register(String username, String email, String password);
}

class AuthLocalDataSourceImpl implements AuthLocalDataSource{
  final DatabaseService _databaseService;
  AuthLocalDataSourceImpl({DatabaseService? databaseService})
  : _databaseService = databaseService ?? DatabaseService.instance;

  @override
  Future<void> register(
    String username, String email, String password
  ) async{
    try {
      Database db = await _databaseService.database;
      UserModel user = UserModel(username: username, password: password, email: email);
      Map<String,dynamic> userData = user.toJson();
      await db.insert(AppConst.userTable, userData);
    } catch (e) {
      debugPrint("auth_local_datasource [register] error : $e");
      throw Exception("auth_local_datasource [register] error : $e");
    }
  }

  @override
  Future<void> logout() {
    // TODO: implement logout
    throw UnimplementedError();
  }
  
}