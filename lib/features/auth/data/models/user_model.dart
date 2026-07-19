class UserModel {
  final String username;
  final String password;
  final String email;
  final String? createdAt;
  
  UserModel({
    required this.username,
    required this.password,
    required this.email,
    this.createdAt 
  });

  factory UserModel.fromJson(Map<String,dynamic> json) {
    return UserModel(
      username: json['username'], 
      password: "",
      email: json['email'],
      createdAt: DateTime.now().toString()
    );
  }

  Map<String,dynamic> toJson(){
    return {
      "username" : username,
      "password" : password,
      "email" : email,
      "createdAt" : createdAt ?? DateTime.now().toString()
    };
  }
}