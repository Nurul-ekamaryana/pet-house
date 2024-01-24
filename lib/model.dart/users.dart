class Users {
  final String password;
  final String role;
  final String nama;
  final String username;
  final String created_at;
  final String updated_at;

  Users({
    required this.password,
    required this.role,
    required this.nama,
    required this.username,
    required this.created_at,
    required this.updated_at,
  });

  factory Users.fromJson(Map<String, dynamic> json) {
    return Users(
      password: json['password'],
      role: json['role'],
      nama: json['nama'],
      username: json['username'],
      created_at: json['created_at'],
      updated_at: json['updated_at'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'password': password,
      'role': role,
      'nama': nama,
      'username': username,
      'created_at': created_at,
      'updated_at': updated_at,
    };
  }
}
