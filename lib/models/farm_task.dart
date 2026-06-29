enum TaskPriority { low, medium, high, urgent }
enum TaskStatus { pending, inProgress, completed, cancelled }

class FarmTask {
  final int? id;
  final String title;
  final String description;
  final TaskPriority priority;
  final TaskStatus status;
  final DateTime createdDate;
  final DateTime? dueDate;
  final DateTime? completedDate;
  final String assignedTo;
  final String category;
  final double? locationLat;
  final double? locationLng;

  FarmTask({
    this.id,
    required this.title,
    this.description = '',
    this.priority = TaskPriority.medium,
    this.status = TaskStatus.pending,
    DateTime? createdDate,
    this.dueDate,
    this.completedDate,
    this.assignedTo = '',
    this.category = 'general',
    this.locationLat,
    this.locationLng,
  }) : createdDate = createdDate ?? DateTime.now();

  String get priorityString {
    switch (priority) {
      case TaskPriority.low:
        return 'Baja';
      case TaskPriority.medium:
        return 'Media';
      case TaskPriority.high:
        return 'Alta';
      case TaskPriority.urgent:
        return 'Urgente';
    }
  }

  String get statusString {
    switch (status) {
      case TaskStatus.pending:
        return 'Pendiente';
      case TaskStatus.inProgress:
        return 'En progreso';
      case TaskStatus.completed:
        return 'Completada';
      case TaskStatus.cancelled:
        return 'Cancelada';
    }
  }

  Map<String, dynamic> toMap() => {
        'id': id,
        'title': title,
        'description': description,
        'priority': priority.index,
        'status': status.index,
        'createdDate': createdDate.toIso8601String(),
        'dueDate': dueDate?.toIso8601String(),
        'completedDate': completedDate?.toIso8601String(),
        'assignedTo': assignedTo,
        'category': category,
        'locationLat': locationLat,
        'locationLng': locationLng,
      };

  factory FarmTask.fromMap(Map<String, dynamic> map) => FarmTask(
        id: map['id'] as int?,
        title: map['title'] as String,
        description: map['description'] as String? ?? '',
        priority: TaskPriority.values[map['priority'] as int? ?? 1],
        status: TaskStatus.values[map['status'] as int? ?? 0],
        createdDate: DateTime.parse(map['createdDate'] as String),
        dueDate: map['dueDate'] != null
            ? DateTime.parse(map['dueDate'] as String)
            : null,
        completedDate: map['completedDate'] != null
            ? DateTime.parse(map['completedDate'] as String)
            : null,
        assignedTo: map['assignedTo'] as String? ?? '',
        category: map['category'] as String? ?? 'general',
        locationLat: (map['locationLat'] as num?)?.toDouble(),
        locationLng: (map['locationLng'] as num?)?.toDouble(),
      );

  FarmTask copyWith({
    int? id,
    String? title,
    String? description,
    TaskPriority? priority,
    TaskStatus? status,
    DateTime? createdDate,
    DateTime? dueDate,
    DateTime? completedDate,
    String? assignedTo,
    String? category,
    double? locationLat,
    double? locationLng,
  }) =>
      FarmTask(
        id: id ?? this.id,
        title: title ?? this.title,
        description: description ?? this.description,
        priority: priority ?? this.priority,
        status: status ?? this.status,
        createdDate: createdDate ?? this.createdDate,
        dueDate: dueDate ?? this.dueDate,
        completedDate: completedDate ?? this.completedDate,
        assignedTo: assignedTo ?? this.assignedTo,
        category: category ?? this.category,
        locationLat: locationLat ?? this.locationLat,
        locationLng: locationLng ?? this.locationLng,
      );
}
