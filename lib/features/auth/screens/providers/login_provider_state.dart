sealed class LoginProviderState {}

class LoginLoadingState extends LoginProviderState{}
class LoginFormState extends LoginProviderState{}

class LoginSuccessState extends LoginProviderState{
  String message;
  LoginSuccessState({required this.message});
}

class LoginErrorState extends LoginProviderState{
  String errorMessage;
  LoginErrorState({required this.errorMessage});
}