import 'package:firebase_auth/firebase_auth.dart';

abstract class AuthRemoteDataSource {
  Future<UserCredential> login({
    required String email,
    required String password,
  });

  Future<UserCredential> register({
    required String email,
    required String password,
  });

  Future<UserCredential> loginWithGoogle();

  Future<void> logout();
}

class AuthRemoteDataSourceImpl implements AuthRemoteDataSource {
  final FirebaseAuth _firebaseAuth;

  AuthRemoteDataSourceImpl({FirebaseAuth? firebaseAuth})
    : _firebaseAuth = firebaseAuth ?? FirebaseAuth.instance;

  @override
  Future<UserCredential> login({
    required String email,
    required String password,
  }) async{
    try {
      return _firebaseAuth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
    } catch (e) {
      throw Exception("$e");
    }
  }

  @override
  Future<UserCredential> register({
    required String email,
    required String password,
  }) async{
    try {
      return _firebaseAuth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
    } catch (e) {
      throw Exception("$e");
    }
  }

  @override
  Future<void> logout() {
    return _firebaseAuth.signOut();
  }
  
  @override
  Future<UserCredential> loginWithGoogle() {
    // TODO: implement loginWithGoogle
    throw UnimplementedError();
  }
}
