import '../../data/models/user_model.dart';
import '../repositories/login_repository.dart';

class UserUsecase {
  final LoginRepository repository;
  UserUsecase({
    required this.repository
  });
  
  Future<UserModel> getUser(String email)async{
    return repository.getUser(email);
  }
}