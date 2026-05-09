class User {
  final int? id;
  final String username;
  final String password;
  final String role; // admin / employee
  final String? createdAt;

  User({
    this.id,
    required this.username,
    required this.password,
    required this.role,
    this.createdAt,
  });

  bool get isAdmin => role == 'admin';
  bool get isEmployee => role == 'employee';

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'username': username,
      'password': password,
      'role': role,
      'created_at': createdAt ?? DateTime.now().toIso8601String(),
    };
  }

  Map<String, dynamic> toMapForInsert() {
    final map = toMap();
    map.remove('id');
    return map;
  }

  factory User.fromMap(Map<String, dynamic> map) {
    return User(
      id: map['id'],
      username: map['username'] ?? '',
      password: map['password'] ?? '',
      role: map['role'] ?? 'employee',
      createdAt: map['created_at'],
    );
  }

  User copyWith({
    int? id,
    String? username,
    String? password,
    String? role,
    String? createdAt,
  }) {
    return User(
      id: id ?? this.id,
      username: username ?? this.username,
      password: password ?? this.password,
      role: role ?? this.role,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  String toString() => 'User(id: $id, username: $username, role: $role)';

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is User && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}
