import 'package:expense_tracker/features/auth/domain/usecases/user_usecase.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/providers/auth_repository_provider.dart';
import '../usecases/login_usecase.dart';

final loginProvider = Provider((ref){
  final repository = ref.read(authRepositoryProvider);
  return LoginUsecase(repository: repository);
});

final userProvider = Provider((ref){
  final repository = ref.read(authRepositoryProvider);
  return UserUsecase(repository: repository);
});