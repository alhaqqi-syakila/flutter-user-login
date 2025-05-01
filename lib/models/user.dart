class User {
  final int? id;
  final String username;
  final String email;
  final String? password;
  final String? fullName;

  User({
    this.id,
    required this.username,
    required this.email,
    this.password,
    this.fullName,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'],
      username: json['username'],
      email: json['email'],
      fullName: json['fullName'],
    );
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = {
      'username': username,
      'email': email,
    };

    if (id != null) {
      data['id'] = id;
    }
    
    if (password != null && password!.isNotEmpty) {
      data['password'] = password;
    }
    
    if (fullName != null && fullName!.isNotEmpty) {
      data['fullName'] = fullName;
    }
    
    return data;
  }
}