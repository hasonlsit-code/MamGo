class UserAccount {
  final String name;
  final String email;
  final String password;

  const UserAccount({
    required this.name,
    required this.email,
    required this.password,
  });

  Map<String, dynamic> toJson() => {
        'name': name,
        'email': email,
        'password': password,
      };

  factory UserAccount.fromJson(Map<String, dynamic> json) => UserAccount(
        name: json['name'] ?? '',
        email: json['email'] ?? '',
        password: json['password'] ?? '',
      );
}
