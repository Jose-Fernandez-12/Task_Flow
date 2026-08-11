import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/task.dart';
import '../services/notification_service.dart';

class TaskProvider with ChangeNotifier {
  List<Task> _tasks = [];
  bool _isDarkMode = false;
  Task? _lastDeleted;

  List<Task> get tasks => _tasks;
  bool get isDarkMode => _isDarkMode;

  TaskProvider() {
    _loadData();
  }

  Future<void> _loadData() async {
    final prefs = await SharedPreferences.getInstance();
    
    // Load Theme
    _isDarkMode = prefs.getBool('tf_dark') ?? false;

    // Load Tasks
    final tasksJson = prefs.getString('tf_tasks_v2');
    if (tasksJson != null) {
      try {
        final List<dynamic> decoded = jsonDecode(tasksJson);
        _tasks = decoded.map((e) => Task.fromJson(e)).toList();
      } catch (e) {
        _tasks = _getSampleData();
      }
    } else {
      _tasks = _getSampleData();
    }
    notifyListeners();
  }

  Future<void> _saveTasks() async {
    final prefs = await SharedPreferences.getInstance();
    final String encoded = jsonEncode(_tasks.map((e) => e.toJson()).toList());
    await prefs.setString('tf_tasks_v2', encoded);
    notifyListeners();
  }

  Future<void> toggleTheme() async {
    _isDarkMode = !_isDarkMode;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('tf_dark', _isDarkMode);
    notifyListeners();
  }

  void addOrUpdateTask({
    String? id,
    required String title,
    String desc = '',
    String date = '',
    TaskPriority priority = TaskPriority.media,
    TaskType type = TaskType.tarea,
    String? time,
  }) {
    if (id != null) {
      // Edit
      final index = _tasks.indexWhere((t) => t.id == id);
      if (index != -1) {
        _tasks[index].title = title;
        _tasks[index].desc = desc;
        _tasks[index].date = date;
        _tasks[index].priority = priority;
        _tasks[index].type = type;
        _tasks[index].time = time;
      }
    } else {
      // Add
      final newTask = Task(
        id: 't${DateTime.now().millisecondsSinceEpoch}',
        title: title,
        desc: desc,
        date: date,
        priority: priority,
        type: type,
        time: time,
        createdAt: DateTime.now().millisecondsSinceEpoch,
      );
      _tasks.insert(0, newTask);
    }
    _saveTasks();
    
    if (type == TaskType.reunion) {
      final taskToSchedule = id != null ? _tasks.firstWhere((t) => t.id == id) : _tasks.first;
      NotificationService.scheduleMeetingReminders(taskToSchedule);
    }
  }

  void toggleDone(String id) {
    final index = _tasks.indexWhere((t) => t.id == id);
    if (index != -1) {
      _tasks[index].done = !_tasks[index].done;
      _saveTasks();
    }
  }

  void postponeTask(String id) {
    final index = _tasks.indexWhere((t) => t.id == id);
    if (index != -1) {
      final task = _tasks[index];
      if (task.date.isNotEmpty) {
        try {
          final currentDate = DateTime.parse(task.date);
          final nextDate = currentDate.add(const Duration(days: 1));
          task.date = "${nextDate.year}-${nextDate.month.toString().padLeft(2, '0')}-${nextDate.day.toString().padLeft(2, '0')}";
        } catch (e) {
          final now = DateTime.now().add(const Duration(days: 1));
          task.date = "${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}";
        }
      } else {
        final now = DateTime.now().add(const Duration(days: 1));
        task.date = "${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}";
      }
      _saveTasks();
    }
  }

  void deleteTask(String id) {
    final index = _tasks.indexWhere((t) => t.id == id);
    if (index != -1) {
      _lastDeleted = _tasks[index];
      _tasks.removeAt(index);
      _saveTasks();
    }
  }

  void undoDelete() {
    if (_lastDeleted != null) {
      _tasks.insert(0, _lastDeleted!);
      _lastDeleted = null;
      _saveTasks();
    }
  }

  int deleteCompleted() {
    int count = _tasks.where((t) => t.done).length;
    _tasks.removeWhere((t) => t.done);
    _saveTasks();
    return count;
  }

  /// Reorders a subset of tasks (e.g. tasks for one day) within the global
  /// list while keeping other tasks' relative order intact.
  void reorderTasks(List<Task> newOrder) {
    if (newOrder.length < 2) return;
    final ids = newOrder.map((t) => t.id).toSet();
    int? firstIndex;
    for (var i = 0; i < _tasks.length; i++) {
      if (ids.contains(_tasks[i].id)) {
        firstIndex = i;
        break;
      }
    }
    if (firstIndex == null) return;
    _tasks.removeWhere((t) => ids.contains(t.id));
    _tasks.insertAll(firstIndex, newOrder);
    _saveTasks();
  }

  /// Creates a copy of the task and inserts it right after the original.
  void duplicateTask(String id) {
    final index = _tasks.indexWhere((t) => t.id == id);
    if (index == -1) return;
    final t = _tasks[index];
    final copy = Task(
      id: 't${DateTime.now().millisecondsSinceEpoch}',
      title: t.title,
      desc: t.desc,
      date: t.date,
      priority: t.priority,
      done: false,
      type: t.type,
      time: t.time,
      createdAt: DateTime.now().millisecondsSinceEpoch,
    );
    _tasks.insert(index + 1, copy);
    _saveTasks();
    if (copy.type == TaskType.reunion) {
      NotificationService.scheduleMeetingReminders(copy);
    }
  }

  /// Moves a task to a different date.
  void moveTaskToDay(String id, String date) {
    final index = _tasks.indexWhere((t) => t.id == id);
    if (index == -1) return;
    final task = _tasks[index];
    task.date = date;
    _saveTasks();
    if (task.type == TaskType.reunion) {
      NotificationService.scheduleMeetingReminders(task);
    }
  }

  // Helpers to get specific groups of tasks
  List<Task> get recordatorios => _tasks.where((t) => t.type == TaskType.recordatorio).toList();
  List<Task> get recordatoriosPendientes => recordatorios.where((t) => !t.done).toList();

  List<Task> get pendingToday {
    final now = DateTime.now();
    final todayStr = "${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}";
    return _tasks.where((t) => t.date == todayStr && !t.done && t.type != TaskType.recordatorio).toList();
  }

  List<Task> _getSampleData() {
    return [];
  }
}
