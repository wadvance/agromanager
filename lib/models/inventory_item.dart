class InventoryItem {
  final int? id;
  final String name;
  final String category;
  final int quantity;
  final String unit;
  final double unitPrice;
  final int minStockLevel;
  final String supplier;
  final String notes;

  InventoryItem({
    this.id,
    required this.name,
    this.category = 'general',
    required this.quantity,
    this.unit = 'unidad',
    this.unitPrice = 0,
    this.minStockLevel = 0,
    this.supplier = '',
    this.notes = '',
  });

  double get totalValue => quantity * unitPrice;
  bool get isLowStock => quantity <= minStockLevel;

  Map<String, dynamic> toMap() => {
        'id': id,
        'name': name,
        'category': category,
        'quantity': quantity,
        'unit': unit,
        'unitPrice': unitPrice,
        'minStockLevel': minStockLevel,
        'supplier': supplier,
        'notes': notes,
      };

  factory InventoryItem.fromMap(Map<String, dynamic> map) => InventoryItem(
        id: map['id'] as int?,
        name: map['name'] as String,
        category: map['category'] as String? ?? 'general',
        quantity: map['quantity'] as int? ?? 0,
        unit: map['unit'] as String? ?? 'unidad',
        unitPrice: (map['unitPrice'] as num?)?.toDouble() ?? 0,
        minStockLevel: map['minStockLevel'] as int? ?? 0,
        supplier: map['supplier'] as String? ?? '',
        notes: map['notes'] as String? ?? '',
      );

  InventoryItem copyWith({
    int? id,
    String? name,
    String? category,
    int? quantity,
    String? unit,
    double? unitPrice,
    int? minStockLevel,
    String? supplier,
    String? notes,
  }) =>
      InventoryItem(
        id: id ?? this.id,
        name: name ?? this.name,
        category: category ?? this.category,
        quantity: quantity ?? this.quantity,
        unit: unit ?? this.unit,
        unitPrice: unitPrice ?? this.unitPrice,
        minStockLevel: minStockLevel ?? this.minStockLevel,
        supplier: supplier ?? this.supplier,
        notes: notes ?? this.notes,
      );
}
