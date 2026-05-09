class Owner {
  final int? id;
  final String name;
  final String? phone;
  final String? nationalId;
  final String? notes;
  final String? createdAt;

  Owner({
    this.id,
    required this.name,
    this.phone,
    this.nationalId,
    this.notes,
    this.createdAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'phone': phone,
      'national_id': nationalId,
      'notes': notes,
      'created_at': createdAt ?? DateTime.now().toIso8601String(),
    };
  }

  Map<String, dynamic> toMapForInsert() {
    final map = toMap();
    map.remove('id');
    return map;
  }

  factory Owner.fromMap(Map<String, dynamic> map) {
    return Owner(
      id: map['id'],
      name: map['name'] ?? '',
      phone: map['phone'],
      nationalId: map['national_id'],
      notes: map['notes'],
      createdAt: map['created_at'],
    );
  }

  Owner copyWith({
    int? id,
    String? name,
    String? phone,
    String? nationalId,
    String? notes,
    String? createdAt,
  }) {
    return Owner(
      id: id ?? this.id,
      name: name ?? this.name,
      phone: phone ?? this.phone,
      nationalId: nationalId ?? this.nationalId,
      notes: notes ?? this.notes,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  String toString() => 'Owner(id: $id, name: $name, phone: $phone)';

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Owner && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}
