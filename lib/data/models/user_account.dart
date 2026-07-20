import 'package:mamgo/domain/entities/user_account_entity.dart';

export 'package:mamgo/domain/entities/user_account_entity.dart';

class UserAccountModel extends UserAccount {
  const UserAccountModel({
    required super.name,
    required super.email,
    required super.password,
  });

  Map<String, dynamic> toJson() => {
        'name': name,
        'email': email,
        'password': password,
      };

  factory UserAccountModel.fromJson(Map<String, dynamic> json) => UserAccountModel(
        name: json['name'] ?? '',
        email: json['email'] ?? '',
        password: json['password'] ?? '',
      );
}
