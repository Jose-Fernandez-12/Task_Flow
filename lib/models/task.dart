import 'dart:convert';

enum TaskPriority {
  alta,
  media,
  baja,
}

class Task {
  final String id;
  String title;
  String desc;
  String date; // "YYYY-MM-DD" o vacio
  TaskPriority priority;
  bool done;
  final int createdAt; // Timestamp in milliseconds

  Task({
    required this.id,
    required this.title,
    this.desc = '',
    this.date = '',
    this.priority = TaskPriority.media,
    this.done = false,
    required this.createdAt,
  });

  factory Task.fromJson(Map<String, dynamic> json) {
    TaskPriority parsedPriority = TaskPriority.media;
    if (json['priority'] == 'alta') parsedPriority = TaskPriority.alta;
    if (json['priority'] == 'baja') parsedPriority = TaskPriority.baja;

    return Task(
      id: json['id'] as String,
      title: json['title'] as String,
      desc: json['desc'] as String? ?? '',
      date: json['date'] as String? ?? '',
      priority: parsedPriority,
      done: json['done'] as bool? ?? false,
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
      'createdAt': createdAt,
    };
  }
}
