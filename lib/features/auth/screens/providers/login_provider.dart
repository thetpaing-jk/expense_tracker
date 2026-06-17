import 'package:expense_tracker/features/auth/data/models/user_model.dart';
import 'package:expense_tracker/features/auth/screens/providers/login_provider_state.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';

import '../../domain/providers/auth_usecase_provider.dart';
import '../../domain/usecases/login_usecase.dart';
import '../../domain/usecases/user_usecase.dart';

final visibilityProvider = StateProvider<bool>((ref){
  return false;
});
final visibilityProvider1 = StateProvider<bool>((ref){
  return false;
});

final authProvider = AuthNotifierProvider((){
  return AuthNotifier();
});

typedef AuthNotifierProvider = NotifierProvider<AuthNotifier,LoginProviderState>;
class AuthNotifier extends Notifier<LoginProviderState>{
  LoginUsecase get loginUsecase => ref.read(loginProvider);
  UserUsecase get userUsecase => ref.read(userProvider);
  @override
  build() {
    return LoginFormState();
  }
  
  Future<void> login(String email, String password) async{
    try {
      state = LoginLoadingState();
      UserCredential? credential = await loginUsecase.login(email, password);
      if(credential != null){
        UserModel userModel = await userUsecase.getUser(email);
        state = LoginSuccessState(message: "Login Successful!", userData: userModel);
      }
      state = LoginErrorState(errorMessage: "Login something went wrong");
    } catch (e) {
      state = LoginErrorState(errorMessage: "$e");
    }
  }

  Future<void> register(String email, String username, String password)async{
    try {
      state = LoginLoadingState();
      UserCredential? credential = await loginUsecase.register(username, email, password);
      if(credential != null){
        UserModel userModel = await userUsecase.getUser(email);
        state = LoginSuccessState(message: "Successfully Register", userData: userModel);
      }
      state = LoginErrorState(errorMessage: "Register something went wrong");
    } catch (e) {
      state = LoginErrorState(errorMessage: "$e");
    }
  }

}