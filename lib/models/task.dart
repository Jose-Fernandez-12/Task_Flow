import 'dart:convert';

enum TaskPriority {
  alta,
  media,
  baja,
}

enum TaskType {
  tarea,
  recordatorio,
  reunion,
}

class Task {
  final String id;
  String title;
  String desc;
  String date; // "YYYY-MM-DD" o vacio
  TaskPriority priority;
  bool done;
  TaskType type;
  String? time; // "HH:MM" para reuniones
  final int createdAt; // Timestamp in milliseconds

  Task({
    required this.id,
    required this.title,
    this.desc = '',
    this.date = '',
    this.priority = TaskPriority.media,
    this.done = false,
    this.type = TaskType.tarea,
    this.time,
    required this.createdAt,
  });

  factory Task.fromJson(Map<String, dynamic> json) {
    TaskPriority parsedPriority = TaskPriority.media;
    if (json['priority'] == 'alta') parsedPriority = TaskPriority.alta;
    if (json['priority'] == 'baja') parsedPriority = TaskPriority.baja;

    TaskType parsedType = TaskType.tarea;
    if (json['type'] != null) {
      if (json['type'] == 'recordatorio') parsedType = TaskType.recordatorio;
      if (json['type'] == 'reunion') parsedType = TaskType.reunion;
    } else {
      bool isRem = json['isReminder'] as bool? ?? ((json['date'] as String? ?? '') == '');
      if (isRem) parsedType = TaskType.recordatorio;
    }

    return Task(
      id: json['id'] as String,
      title: json['title'] as String,
      desc: json['desc'] as String? ?? '',
      date: json['date'] as String? ?? '',
      priority: parsedPriority,
      done: json['done'] as bool? ?? false,
      type: parsedType,
      time: json['time'] as String?,
      createdAt: json['createdAt'] as int? ?? DateTime.now().millisecondsSinceEpoch,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'desc': desc,
      'date': date,
      'priority': priority.name, // Enum to string ("alta", "media", "baja")
      'done': done,
      'type': type.name, // Enum to string ("tarea", "recordatorio", "reunion")
      'time': time,
      'createdAt': createdAt,
    };
  }
}
