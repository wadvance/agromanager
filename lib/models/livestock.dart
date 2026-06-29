enum AnimalType { cattle, pig, chicken, goat, sheep, horse, other }

class Livestock {
  final int? id;
  final String name;
  final AnimalType type;
  final String breed;
  final DateTime birthDate;
  final double weight; // kg
  final String gender;
  final String healthStatus;
  final String notes;
  final double purchaseCost;
  final double salePrice;

  Livestock({
    this.id,
    required this.name,
    required this.type,
    this.breed = '',
    required this.birthDate,
    this.weight = 0,
    this.gender = '',
    this.healthStatus = 'healthy',
    this.notes = '',
    this.purchaseCost = 0,
    this.salePrice = 0,
  });

  String get typeString {
    switch (type) {
      case AnimalType.cattle:
        return 'Bovino';
      case AnimalType.pig:
        return 'Porcino';
      case AnimalType.chicken:
        return 'Ave de corral';
      case AnimalType.goat:
        return 'Caprino';
      case AnimalType.sheep:
        return 'Ovino';
      case AnimalType.horse:
        return 'Equino';
      case AnimalType.other:
        return 'Otro';
    }
  }

  Map<String, dynamic> toMap() => {
        'id': id,
        'name': name,
        'type': type.index,
        'breed': breed,
        'birthDate': birthDate.toIso8601String(),
        'weight': weight,
        'gender': gender,
        'healthStatus': healthStatus,
        'notes': notes,
        'purchaseCost': purchaseCost,
        'salePrice': salePrice,
      };

  factory Livestock.fromMap(Map<String, dynamic> map) => Livestock(
        id: map['id'] as int?,
        name: map['name'] as String,
        type: AnimalType.values[map['type'] as int? ?? 0],
        breed: map['breed'] as String? ?? '',
        birthDate: DateTime.parse(map['birthDate'] as String),
        weight: (map['weight'] as num?)?.toDouble() ?? 0,
        gender: map['gender'] as String? ?? '',
        healthStatus: map['healthStatus'] as String? ?? 'healthy',
        notes: map['notes'] as String? ?? '',
        purchaseCost: (map['purchaseCost'] as num?)?.toDouble() ?? 0,
        salePrice: (map['salePrice'] as num?)?.toDouble() ?? 0,
      );

  Livestock copyWith({
    int? id,
    String? name,
    AnimalType? type,
    String? breed,
    DateTime? birthDate,
    double? weight,
    String? gender,
    String? healthStatus,
    String? notes,
    double? purchaseCost,
    double? salePrice,
  }) =>
      Livestock(
        id: id ?? this.id,
        name: name ?? this.name,
        type: type ?? this.type,
        breed: breed ?? this.breed,
        birthDate: birthDate ?? this.birthDate,
        weight: weight ?? this.weight,
        gender: gender ?? this.gender,
        healthStatus: healthStatus ?? this.healthStatus,
        notes: notes ?? this.notes,
        purchaseCost: purchaseCost ?? this.purchaseCost,
        salePrice: salePrice ?? this.salePrice,
      );
}
