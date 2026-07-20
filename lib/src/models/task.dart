import 'package:projet1/src/exceptions/task_exception.dart';

enum TaskPriority { low, medium, high }

/// Base type of every task in the app.
///
/// Inheritance chain: `Task` (abstract) -> `BasicTask` (concrete) ->
/// `UrgentTask` (adds a `contact` to notify). Each level adds behaviour
/// on top of the previous one instead of duplicating it.
abstract class Task {
  Task({
    required this.id,
    required this.title,
    required this.priority,
    this.deadline,
    this.isDone = false,
  });

  final String id;
  final String title;
  final TaskPriority priority;
  final DateTime? deadline;
  final bool isDone;

  String get typeTag;

  Map<String, dynamic> toJson();

  Task copyWith({
    String? id,
    String? title,
    TaskPriority? priority,
    DateTime? deadline,
    bool? isDone,
  });

  static TaskPriority parsePriority(String value) {
    for (final priority in TaskPriority.values) {
      if (priority.name.toLowerCase() == value.trim().toLowerCase()) {
        return priority;
      }
    }
    throw InvalidTaskDataException(
      'Priority "$value" is invalid. Expected one of: low, medium, high.',
    );
  }

  static Map<String, dynamic> baseJson(Task task) {
    return {
      'id': task.id,
      'title': task.title,
      'priority': task.priority.name,
      'deadline': task.deadline?.toIso8601String(),
      'isDone': task.isDone,
      'type': task.typeTag,
    };
  }

  static Task fromJson(Map<String, dynamic> json) {
    final typeTag = json['type'] as String? ?? 'basic';
    if (typeTag == 'urgent') {
      return UrgentTask.fromJson(json);
    }
    return BasicTask.fromJson(json);
  }
}

/// A regular task with no special handling. Extends [Task] directly.
class BasicTask extends Task {
  BasicTask({
    required super.id,
    required super.title,
    required super.priority,
    super.deadline,
    super.isDone,
  });

  factory BasicTask.fromJson(Map<String, dynamic> json) {
    if (json['id'] == null || json['title'] == null) {
      throw InvalidTaskDataException('A basic task requires an id and a title.');
    }
    return BasicTask(
      id: json['id'] as String,
      title: json['title'] as String,
      priority: TaskPriority.values.firstWhere(
        (priority) => priority.name == json['priority'],
        orElse: () => TaskPriority.medium,
      ),
      deadline: json['deadline'] == null
          ? null
          : DateTime.parse(json['deadline'] as String),
      isDone: json['isDone'] as bool? ?? false,
    );
  }

  @override
  String get typeTag => 'basic';

  @override
  Map<String, dynamic> toJson() => Task.baseJson(this);

  @override
  Task copyWith({
    String? id,
    String? title,
    TaskPriority? priority,
    DateTime? deadline,
    bool? isDone,
  }) {
    return BasicTask(
      id: id ?? this.id,
      title: title ?? this.title,
      priority: priority ?? this.priority,
      deadline: deadline ?? this.deadline,
      isDone: isDone ?? this.isDone,
    );
  }
}

/// A task that requires immediate attention and carries a [contact] to
/// notify. Extends [BasicTask] (which itself extends [Task]), giving the
/// three-level chain `Task -> BasicTask -> UrgentTask` and letting
/// `UrgentTask` reuse `BasicTask`'s JSON encoding via `super.toJson()`.
class UrgentTask extends BasicTask {
  UrgentTask({
    required super.id,
    required super.title,
    required super.priority,
    super.deadline,
    super.isDone,
    required this.contact,
  });

  factory UrgentTask.fromJson(Map<String, dynamic> json) {
    if (json['id'] == null || json['title'] == null) {
      throw InvalidTaskDataException('An urgent task requires an id and a title.');
    }
    return UrgentTask(
      id: json['id'] as String,
      title: json['title'] as String,
      priority: TaskPriority.values.firstWhere(
        (priority) => priority.name == json['priority'],
        orElse: () => TaskPriority.high,
      ),
      deadline: json['deadline'] == null
          ? null
          : DateTime.parse(json['deadline'] as String),
      isDone: json['isDone'] as bool? ?? false,
      contact: json['contact'] as String? ?? 'n/a',
    );
  }

  final String contact;

  @override
  String get typeTag => 'urgent';

  @override
  Map<String, dynamic> toJson() => {
        ...super.toJson(),
        'contact': contact,
      };

  @override
  Task copyWith({
    String? id,
    String? title,
    TaskPriority? priority,
    DateTime? deadline,
    bool? isDone,
    String? contact,
  }) {
    return UrgentTask(
      id: id ?? this.id,
      title: title ?? this.title,
      priority: priority ?? this.priority,
      deadline: deadline ?? this.deadline,
      isDone: isDone ?? this.isDone,
      contact: contact ?? this.contact,
    );
  }
}
