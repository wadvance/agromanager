class Crop {
  final int? id;
  final String name;
  final String variety;
  final DateTime plantingDate;
  final DateTime? harvestDate;
  final double area; // hectares
  final String status; // planted, growing, harvested
  final String notes;
  final double quantity; // expected yield in kg
  final double cost;

  Crop({
    this.id,
    required this.name,
    this.variety = '',
    required this.plantingDate,
    this.harvestDate,
    required this.area,
    this.status = 'growing',
    this.notes = '',
    this.quantity = 0,
    this.cost = 0,
  });

  Map<String, dynamic> toMap() => {
        'id': id,
        'name': name,
        'variety': variety,
        'plantingDate': plantingDate.toIso8601String(),
        'harvestDate': harvestDate?.toIso8601String(),
        'area': area,
        'status': status,
        'notes': notes,
        'quantity': quantity,
        'cost': cost,
      };

  factory Crop.fromMap(Map<String, dynamic> map) => Crop(
        id: map['id'] as int?,
        name: map['name'] as String,
        variety: map['variety'] as String? ?? '',
        plantingDate: DateTime.parse(map['plantingDate'] as String),
        harvestDate: map['harvestDate'] != null
            ? DateTime.parse(map['harvestDate'] as String)
            : null,
        area: (map['area'] as num).toDouble(),
        status: map['status'] as String? ?? 'growing',
        notes: map['notes'] as String? ?? '',
        quantity: (map['quantity'] as num?)?.toDouble() ?? 0,
        cost: (map['cost'] as num?)?.toDouble() ?? 0,
      );

  Crop copyWith({
    int? id,
    String? name,
    String? variety,
    DateTime? plantingDate,
    DateTime? harvestDate,
    double? area,
    String? status,
    String? notes,
    double? quantity,
    double? cost,
  }) =>
      Crop(
        id: id ?? this.id,
        name: name ?? this.name,
        variety: variety ?? this.variety,
        plantingDate: plantingDate ?? this.plantingDate,
        harvestDate: harvestDate ?? this.harvestDate,
        area: area ?? this.area,
        status: status ?? this.status,
        notes: notes ?? this.notes,
        quantity: quantity ?? this.quantity,
        cost: cost ?? this.cost,
      );
}
