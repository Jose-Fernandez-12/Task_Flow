import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/task.dart';

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
    final tasksJson = prefs.getString('tf_tasks');
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
    await prefs.setString('tf_tasks', encoded);
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
  }) {
    if (id != null) {
      // Edit
      final index = _tasks.indexWhere((t) => t.id == id);
      if (index != -1) {
        _tasks[index].title = title;
        _tasks[index].desc = desc;
        _tasks[index].date = date;
        _tasks[index].priority = priority;
      }
    } else {
      // Add
      final newTask = Task(
        id: 't\${DateTime.now().millisecondsSinceEpoch}',
        title: title,
        desc: desc,
        date: date,
        priority: priority,
        createdAt: DateTime.now().millisecondsSinceEpoch,
      );
      _tasks.insert(0, newTask);
    }
    _saveTasks();
  }

  void toggleDone(String id) {
    final index = _tasks.indexWhere((t) => t.id == id);
    if (index != -1) {
      _tasks[index].done = !_tasks[index].done;
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

  // Helpers to get specific groups of tasks
  List<Task> get recordatorios => _tasks.where((t) => t.date.isEmpty).toList();

  List<Task> get pendingToday {
    final now = DateTime.now();
    final todayStr = "\${now.year}-\${now.month.toString().padLeft(2, '0')}-\${now.day.toString().padLeft(2, '0')}";
    return _tasks.where((t) => t.date == todayStr && !t.done).toList();
  }

  List<Task> _getSampleData() {
    final now = DateTime.now();
    String day(int offset) {
      final d = now.add(Duration(days: offset));
      return "\${d.year}-\${d.month.toString().padLeft(2, '0')}-\${d.day.toString().padLeft(2, '0')}";
    }
    final tNow = now.millisecondsSinceEpoch;

    return [
      Task(id: 's1', title: 'Revisar correo pendiente', desc: 'Responder a los emails del equipo de diseño', date: day(0), priority: TaskPriority.media, createdAt: tNow - 3600000),
      Task(id: 's2', title: 'Comprar víveres', desc: 'Leche, huevos, pan, fruta', date: day(0), priority: TaskPriority.alta, createdAt: tNow - 7200000),
      Task(id: 's3', title: 'Preparar presentación', desc: 'Slides para la reunión del jueves con stakeholders', date: day(2), priority: TaskPriority.alta, createdAt: tNow - 10800000),
      Task(id: 's4', title: 'Pagar factura internet', desc: 'Vence el viernes — pago automático', date: day(4), priority: TaskPriority.media, createdAt: tNow - 14400000),
      Task(id: 's5', title: 'Lavar el coche', desc: '', date: day(5), priority: TaskPriority.baja, createdAt: tNow - 18000000),
      Task(id: 's6', title: 'Informe mensual', desc: 'Completar el reporte de métricas del departamento', date: day(14), priority: TaskPriority.media, createdAt: tNow - 21600000),
      Task(id: 's7', title: 'Revisar suscripción SaaS', desc: 'Evaluar si renovamos la licencia anual', date: day(20), priority: TaskPriority.baja, createdAt: tNow - 25200000),
      Task(id: 's8', title: 'Cita dentista', desc: 'Limpieza anual — 11:30am', date: day(1), priority: TaskPriority.alta, done: true, createdAt: tNow - 28800000),
      Task(id: 's9', title: 'Llamar al seguro', desc: 'Preguntar por la cobertura dental', date: '', priority: TaskPriority.media, createdAt: tNow - 32400000),
      Task(id: 's10', title: 'Cambiar contraseñas', desc: 'Actualizar cuentas principales por seguridad', date: '', priority: TaskPriority.baja, createdAt: tNow - 36000000),
      Task(id: 's11', title: 'Pedir presupuesto reforma', desc: 'Contactar a 3 empresas para presupuesto del baño', date: day(10), priority: TaskPriority.media, createdAt: tNow - 39600000),
    ];
  }
}
