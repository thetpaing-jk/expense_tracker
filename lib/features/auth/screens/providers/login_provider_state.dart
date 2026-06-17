import '../../data/models/user_model.dart';

sealed class LoginProviderState {}

class LoginLoadingState extends LoginProviderState{}
class LoginFormState extends LoginProviderState{}

class LoginSuccessState extends LoginProviderState{
  String message;
  UserModel userData;
  LoginSuccessState({required this.message, required this.userData});
}

class LoginErrorState extends LoginProviderState{
  String errorMessage;
  LoginErrorState({required this.errorMessage});
}