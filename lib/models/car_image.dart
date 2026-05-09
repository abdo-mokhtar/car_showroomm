class CarImage {
  final int? id;
  final int carId;
  final String imagePath;
  final String? createdAt;

  CarImage({
    this.id,
    required this.carId,
    required this.imagePath,
    this.createdAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'car_id': carId,
      'image_path': imagePath,
      'created_at': createdAt ?? DateTime.now().toIso8601String(),
    };
  }

  Map<String, dynamic> toMapForInsert() {
    final map = toMap();
    map.remove('id');
    return map;
  }

  factory CarImage.fromMap(Map<String, dynamic> map) {
    return CarImage(
      id: map['id'],
      carId: map['car_id'],
      imagePath: map['image_path'] ?? '',
      createdAt: map['created_at'],
    );
  }

  CarImage copyWith({
    int? id,
    int? carId,
    String? imagePath,
    String? createdAt,
  }) {
    return CarImage(
      id: id ?? this.id,
      carId: carId ?? this.carId,
      imagePath: imagePath ?? this.imagePath,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  String toString() =>
      'CarImage(id: $id, carId: $carId, imagePath: $imagePath)';

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is CarImage && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}
