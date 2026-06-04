abstract class LoginRepository{
  Future<void> login(String username, String password);
  Future<void> loginWithGoogle();
}