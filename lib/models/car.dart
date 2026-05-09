class Car {
  final int? id;
  final String brand;
  final String model;
  final int? year;
  final String? color;
  final String? plateNumber;
  final String? chassisNumber;
  final double purchasePrice;
  final double expectedPrice;
  final String ownershipType; // office / consignment
  final String status; // available / sold
  final int kilometers;
  final String? fuelType;
  final String? transmission;
  final String? engineCapacity;
  final String? carCondition; // new / used
  final String? accessories;
  final String? technicalNotes;
  final String? purchaseDate;
  final String? purchasedFrom;
  final String? purchasePaymentMethod;
  final int? ownerId;
  final String? commissionType; // percentage / fixed
  final double commissionValue;
  final double displayFees;
  final String? monthYear;
  final String? createdAt;

  Car({
    this.id,
    required this.brand,
    required this.model,
    this.year,
    this.color,
    this.plateNumber,
    this.chassisNumber,
    this.purchasePrice = 0,
    this.expectedPrice = 0,
    required this.ownershipType,
    this.status = 'available',
    this.kilometers = 0,
    this.fuelType,
    this.transmission,
    this.engineCapacity,
    this.carCondition,
    this.accessories,
    this.technicalNotes,
    this.purchaseDate,
    this.purchasedFrom,
    this.purchasePaymentMethod,
    this.ownerId,
    this.commissionType,
    this.commissionValue = 0,
    this.displayFees = 0,
    this.monthYear,
    this.createdAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'brand': brand,
      'model': model,
      'year': year,
      'color': color,
      'plate_number': plateNumber,
      'chassis_number': chassisNumber,
      'purchase_price': purchasePrice,
      'expected_price': expectedPrice,
      'ownership_type': ownershipType,
      'status': status,
      'kilometers': kilometers,
      'fuel_type': fuelType,
      'transmission': transmission,
      'engine_capacity': engineCapacity,
      'car_condition': carCondition,
      'accessories': accessories,
      'technical_notes': technicalNotes,
      'purchase_date': purchaseDate,
      'purchased_from': purchasedFrom,
      'purchase_payment_method': purchasePaymentMethod,
      'owner_id': ownerId,
      'commission_type': commissionType,
      'commission_value': commissionValue,
      'display_fees': displayFees,
      'month_year': monthYear,
      'created_at': createdAt ?? DateTime.now().toIso8601String(),
    };
  }

  Map<String, dynamic> toMapForInsert() {
    final map = toMap();
    map.remove('id');
    return map;
  }

  factory Car.fromMap(Map<String, dynamic> map) {
    return Car(
      id: map['id'],
      brand: map['brand'] ?? '',
      model: map['model'] ?? '',
      year: map['year'],
      color: map['color'],
      plateNumber: map['plate_number'],
      chassisNumber: map['chassis_number'],
      purchasePrice: (map['purchase_price'] ?? 0).toDouble(),
      expectedPrice: (map['expected_price'] ?? 0).toDouble(),
      ownershipType: map['ownership_type'] ?? 'office',
      status: map['status'] ?? 'available',
      kilometers: map['kilometers'] ?? 0,
      fuelType: map['fuel_type'],
      transmission: map['transmission'],
      engineCapacity: map['engine_capacity'],
      carCondition: map['car_condition'],
      accessories: map['accessories'],
      technicalNotes: map['technical_notes'],
      purchaseDate: map['purchase_date'],
      purchasedFrom: map['purchased_from'],
      purchasePaymentMethod: map['purchase_payment_method'],
      ownerId: map['owner_id'],
      commissionType: map['commission_type'],
      commissionValue: (map['commission_value'] ?? 0).toDouble(),
      displayFees: (map['display_fees'] ?? 0).toDouble(),
      monthYear: map['month_year'],
      createdAt: map['created_at'],
    );
  }

  double calculateProfit(double totalExpenses) {
    if (ownershipType == 'office') {
      return expectedPrice - purchasePrice - totalExpenses;
    } else {
      if (commissionType == 'percentage') {
        return (expectedPrice * commissionValue / 100) + displayFees;
      } else {
        return commissionValue + displayFees;
      }
    }
  }

  Car copyWith({
    int? id,
    String? brand,
    String? model,
    Object? year = _sentinel,
    Object? color = _sentinel,
    Object? plateNumber = _sentinel,
    Object? chassisNumber = _sentinel,
    double? purchasePrice,
    double? expectedPrice,
    String? ownershipType,
    String? status,
    int? kilometers,
    Object? fuelType = _sentinel,
    Object? transmission = _sentinel,
    Object? engineCapacity = _sentinel,
    Object? carCondition = _sentinel,
    Object? accessories = _sentinel,
    Object? technicalNotes = _sentinel,
    Object? purchaseDate = _sentinel,
    Object? purchasedFrom = _sentinel,
    Object? purchasePaymentMethod = _sentinel,
    Object? ownerId = _sentinel,
    Object? commissionType = _sentinel,
    double? commissionValue,
    double? displayFees,
    Object? monthYear = _sentinel,
    Object? createdAt = _sentinel,
  }) {
    return Car(
      id: id ?? this.id,
      brand: brand ?? this.brand,
      model: model ?? this.model,
      year: year == _sentinel ? this.year : year as int?,
      color: color == _sentinel ? this.color : color as String?,
      plateNumber:
          plateNumber == _sentinel ? this.plateNumber : plateNumber as String?,
      chassisNumber: chassisNumber == _sentinel
          ? this.chassisNumber
          : chassisNumber as String?,
      purchasePrice: purchasePrice ?? this.purchasePrice,
      expectedPrice: expectedPrice ?? this.expectedPrice,
      ownershipType: ownershipType ?? this.ownershipType,
      status: status ?? this.status,
      kilometers: kilometers ?? this.kilometers,
      fuelType: fuelType == _sentinel ? this.fuelType : fuelType as String?,
      transmission: transmission == _sentinel
          ? this.transmission
          : transmission as String?,
      engineCapacity: engineCapacity == _sentinel
          ? this.engineCapacity
          : engineCapacity as String?,
      carCondition: carCondition == _sentinel
          ? this.carCondition
          : carCondition as String?,
      accessories:
          accessories == _sentinel ? this.accessories : accessories as String?,
      technicalNotes: technicalNotes == _sentinel
          ? this.technicalNotes
          : technicalNotes as String?,
      purchaseDate: purchaseDate == _sentinel
          ? this.purchaseDate
          : purchaseDate as String?,
      purchasedFrom: purchasedFrom == _sentinel
          ? this.purchasedFrom
          : purchasedFrom as String?,
      purchasePaymentMethod: purchasePaymentMethod == _sentinel
          ? this.purchasePaymentMethod
          : purchasePaymentMethod as String?,
      ownerId: ownerId == _sentinel ? this.ownerId : ownerId as int?,
      commissionType: commissionType == _sentinel
          ? this.commissionType
          : commissionType as String?,
      commissionValue: commissionValue ?? this.commissionValue,
      displayFees: displayFees ?? this.displayFees,
      monthYear: monthYear == _sentinel ? this.monthYear : monthYear as String?,
      createdAt: createdAt == _sentinel ? this.createdAt : createdAt as String?,
    );
  }

  @override
  String toString() =>
      'Car(id: $id, brand: $brand, model: $model, status: $status)';

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Car && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}

const Object _sentinel = Object();
