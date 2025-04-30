class UserModel {
  final String id;
  final String email;
  final String name;
  final String role;
  final DateTime createdAt;
  final String? photoUrl;
  final bool synced;
  
  UserModel({
    required this.id,
    required this.email,
    required this.name,
    required this.role,
    required this.createdAt,
    this.photoUrl,
    this.synced = false,
  });
  
  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'],
      email: json['email'],
      name: json['name'],
      role: json['role'],
      createdAt: json['createdAt'] is DateTime 
        ? json['createdAt'] 
        : DateTime.parse(json['createdAt']),
      photoUrl: json['photoUrl'],
      synced: json['synced'] ?? false,
    );
  }
  
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      'name': name,
      'role': role,
      'createdAt': createdAt.toIso8601String(),
      'photoUrl': photoUrl,
      'synced': synced,
    };
  }
  
  UserModel copyWith({
    String? id,
    String? email,
    String? name,
    String? role,
    DateTime? createdAt,
    String? photoUrl,
    bool? synced,
  }) {
    return UserModel(
      id: id ?? this.id,
      email: email ?? this.email,
      name: name ?? this.name,
      role: role ?? this.role,
      createdAt: createdAt ?? this.createdAt,
      photoUrl: photoUrl ?? this.photoUrl,
      synced: synced ?? this.synced,
    );
  }
}
