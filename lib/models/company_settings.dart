class CompanySettings {
  final int? id;
  final String? companyName;
  final String? logoPath;
  final String? address;
  final String? phone;
  final String currency;
  final String language;
  final String? managerSignature;

  CompanySettings({
    this.id,
    this.companyName,
    this.logoPath,
    this.address,
    this.phone,
    this.currency = 'EGP',
    this.language = 'ar',
    this.managerSignature,
  });

  bool get isArabic => language == 'ar';

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'company_name': companyName,
      'logo_path': logoPath,
      'address': address,
      'phone': phone,
      'currency': currency,
      'language': language,
      'manager_signature': managerSignature,
    };
  }

  Map<String, dynamic> toMapForInsert() {
    final map = toMap();
    map.remove('id');
    return map;
  }

  factory CompanySettings.fromMap(Map<String, dynamic> map) {
    return CompanySettings(
      id: map['id'],
      companyName: map['company_name'],
      logoPath: map['logo_path'],
      address: map['address'],
      phone: map['phone'],
      currency: map['currency'] ?? 'EGP',
      language: map['language'] ?? 'ar',
      managerSignature: map['manager_signature'],
    );
  }

  CompanySettings copyWith({
    int? id,
    Object? companyName = _sentinel,
    Object? logoPath = _sentinel,
    Object? address = _sentinel,
    Object? phone = _sentinel,
    String? currency,
    String? language,
    Object? managerSignature = _sentinel,
  }) {
    return CompanySettings(
      id: id ?? this.id,
      companyName:
          companyName == _sentinel ? this.companyName : companyName as String?,
      logoPath: logoPath == _sentinel ? this.logoPath : logoPath as String?,
      address: address == _sentinel ? this.address : address as String?,
      phone: phone == _sentinel ? this.phone : phone as String?,
      currency: currency ?? this.currency,
      language: language ?? this.language,
      managerSignature: managerSignature == _sentinel
          ? this.managerSignature
          : managerSignature as String?,
    );
  }

  @override
  String toString() =>
      'CompanySettings(id: $id, companyName: $companyName, language: $language)';

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is CompanySettings && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}

const Object _sentinel = Object();
