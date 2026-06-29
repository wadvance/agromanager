enum TransactionType { income, expense }

class FinanceRecord {
  final int? id;
  final String description;
  final double amount;
  final TransactionType type;
  final String category;
  final DateTime date;
  final String paymentMethod;
  final String notes;

  FinanceRecord({
    this.id,
    required this.description,
    required this.amount,
    required this.type,
    this.category = 'general',
    required this.date,
    this.paymentMethod = 'efectivo',
    this.notes = '',
  });

  String get typeString => type == TransactionType.income ? 'Ingreso' : 'Gasto';
  IconType get iconType => type == TransactionType.income ? IconType.income : IconType.expense;

  Map<String, dynamic> toMap() => {
        'id': id,
        'description': description,
        'amount': amount,
        'type': type.index,
        'category': category,
        'date': date.toIso8601String(),
        'paymentMethod': paymentMethod,
        'notes': notes,
      };

  factory FinanceRecord.fromMap(Map<String, dynamic> map) => FinanceRecord(
        id: map['id'] as int?,
        description: map['description'] as String,
        amount: (map['amount'] as num).toDouble(),
        type: TransactionType.values[map['type'] as int? ?? 0],
        category: map['category'] as String? ?? 'general',
        date: DateTime.parse(map['date'] as String),
        paymentMethod: map['paymentMethod'] as String? ?? 'efectivo',
        notes: map['notes'] as String? ?? '',
      );

  FinanceRecord copyWith({
    int? id,
    String? description,
    double? amount,
    TransactionType? type,
    String? category,
    DateTime? date,
    String? paymentMethod,
    String? notes,
  }) =>
      FinanceRecord(
        id: id ?? this.id,
        description: description ?? this.description,
        amount: amount ?? this.amount,
        type: type ?? this.type,
        category: category ?? this.category,
        date: date ?? this.date,
        paymentMethod: paymentMethod ?? this.paymentMethod,
        notes: notes ?? this.notes,
      );
}

enum IconType { income, expense }
