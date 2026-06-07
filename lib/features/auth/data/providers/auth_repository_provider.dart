import 'package:expense_tracker/features/auth/data/repositories/login_repository_impl.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/repositories/login_repository.dart';
import '../datasource/auth_remote_datasource.dart';
import '../datasource/auth_local_datasource.dart';

final authRemoteDatasourceProvider = Provider<AuthRemoteDataSource>((ref){
  return AuthRemoteDataSourceImpl();
});

final authLocalDatasourceProvider = Provider<AuthLocalDataSource>((ref){
  return AuthLocalDataSourceImpl();
});

final authRepositoryProvider = Provider<LoginRepository>((ref){
  final remoteProvider = ref.read(authRemoteDatasourceProvider);
  final localProvider = ref.read(authLocalDatasourceProvider);
  return LoginRepositoryImpl(authLocalDatasource: localProvider, authRemoteDataSource: remoteProvider);
});