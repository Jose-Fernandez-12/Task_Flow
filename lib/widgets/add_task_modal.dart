import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/task.dart';
import '../theme/app_theme.dart';
import 'priority_chip.dart';

class AddTaskModal extends StatefulWidget {
  final Task? taskToEdit;
  final Function(String title, String desc, String date, TaskPriority priority) onSave;

  const AddTaskModal({
    Key? key,
    this.taskToEdit,
    required this.onSave,
  }) : super(key: key);

  @override
  State<AddTaskModal> createState() => _AddTaskModalState();
}

class _AddTaskModalState extends State<AddTaskModal> {
  late TextEditingController _titleController;
  late TextEditingController _descController;
  late TaskPriority _selectedPriority;
  String _selectedDate = '';
  
  bool _showingCalendar = false;
  late DateTime _calMonth;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.taskToEdit?.title ?? '');
    _descController = TextEditingController(text: widget.taskToEdit?.desc ?? '');
    _selectedPriority = widget.taskToEdit?.priority ?? TaskPriority.media;
    
    if (widget.taskToEdit != null) {
      _selectedDate = widget.taskToEdit!.date;
    } else {
      final now = DateTime.now();
      _selectedDate = "${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}";
    }
    
    _initCalendarMonth();
  }

  void _initCalendarMonth() {
    if (_selectedDate.isNotEmpty) {
      try {
        _calMonth = DateTime.parse(_selectedDate);
        _calMonth = DateTime(_calMonth.year, _calMonth.month, 1);
      } catch (e) {
        final now = DateTime.now();
        _calMonth = DateTime(now.year, now.month, 1);
      }
    } else {
      final now = DateTime.now();
      _calMonth = DateTime(now.year, now.month, 1);
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descController.dispose();
    super.dispose();
  }

  void _save() {
    final title = _titleController.text.trim();
    if (title.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('El título es requerido')),
      );
      return;
    }
    widget.onSave(title, _descController.text.trim(), _selectedDate, _selectedPriority);
    Navigator.pop(context);
  }

  String _formatDisplayDate() {
    if (_selectedDate.isEmpty) return 'Sin fecha';
    try {
      final d = DateTime.parse(_selectedDate);
      return "${d.day} ${DateFormat('MMM', 'es_ES').format(d)}";
    } catch (_) {
      return _selectedDate;
    }
  }

  Widget _buildCalendarPicker(AppColors colors) {
    if (!_showingCalendar) return const SizedBox.shrink();

    final daysInMonth = DateUtils.getDaysInMonth(_calMonth.year, _calMonth.month);
    final firstDayOffset = _calMonth.weekday - 1; // 0 = Lunes, 6 = Domingo
    
    final dayNames = ['Lu', 'Ma', 'Mi', 'Ju', 'Vi', 'Sa', 'Do'];
    final now = DateTime.now();
    final todayStr = "${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}";

    return Container(
      margin: const EdgeInsets.only(top: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: colors.surface,
        border: Border.all(color: colors.borderSoft),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              IconButton(
                icon: const Icon(Icons.chevron_left),
                onPressed: () {
                  setState(() {
                    _calMonth = DateTime(_calMonth.year, _calMonth.month - 1, 1);
                  });
                },
              ),
              Text(
                DateFormat('MMMM yyyy', 'es_ES').format(_calMonth),
                style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: colors.fg),
              ),
              IconButton(
                icon: const Icon(Icons.chevron_right),
                onPressed: () {
                  setState(() {
                    _calMonth = DateTime(_calMonth.year, _calMonth.month + 1, 1);
                  });
                },
              ),
            ],
          ),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 7,
              childAspectRatio: 1.2,
              crossAxisSpacing: 2,
              mainAxisSpacing: 2,
            ),
            itemCount: 7 + firstDayOffset + daysInMonth,
            itemBuilder: (context, index) {
              if (index < 7) {
                return Center(
                  child: Text(
                    dayNames[index],
                    style: TextStyle(fontSize: 10, fontWeight: FontWeight.w600, color: colors.muted),
                  ),
                );
              }
              final dayIndex = index - 7 - firstDayOffset;
              if (dayIndex < 0) return const SizedBox.shrink();

              final day = dayIndex + 1;
              final dateStr = "${_calMonth.year}-${_calMonth.month.toString().padLeft(2, '0')}-${day.toString().padLeft(2, '0')}";
              final isSelected = dateStr == _selectedDate;
              final isToday = dateStr == todayStr;

              return GestureDetector(
                onTap: () {
                  setState(() {
                    _selectedDate = dateStr;
                    _showingCalendar = false;
                  });
                },
                child: Container(
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: isSelected ? colors.accent : Colors.transparent,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    day.toString(),
                    style: TextStyle(
                      fontSize: 12,
                      color: isSelected ? colors.accentOn : (isToday ? colors.accent : colors.fg2),
                      fontWeight: isSelected || isToday ? FontWeight.w700 : FontWeight.normal,
                    ),
                  ),
                ),
              );
            },
          ),
          TextButton(
            onPressed: () {
              setState(() {
                _selectedDate = '';
                _showingCalendar = false;
              });
            },
            child: Text(
              'Sin fecha (recordatorio)',
              style: TextStyle(fontSize: 12, color: colors.muted),
            ),
          )
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).extension<AppColors>()!;
    final isEditing = widget.taskToEdit != null;

    return Container(
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      padding: EdgeInsets.only(
        left: 24,
        right: 24,
        top: 20,
        bottom: 24 + MediaQuery.of(context).viewInsets.bottom,
      ),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 36,
                height: 4,
                margin: const EdgeInsets.only(bottom: 16),
                decoration: BoxDecoration(
                  color: colors.border,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            Text(
              isEditing ? 'Editar tarea' : 'Nueva tarea',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600, color: colors.fg),
            ),
            const SizedBox(height: 20),
            _buildLabel('Título', colors),
            TextField(
              controller: _titleController,
              decoration: _inputDecoration(colors, '¿Qué hay que hacer?'),
              style: TextStyle(fontSize: 14, color: colors.fg),
            ),
            const SizedBox(height: 16),
            _buildLabel('Descripción', colors),
            TextField(
              controller: _descController,
              maxLines: 3,
              minLines: 2,
              decoration: _inputDecoration(colors, 'Detalles opcionales…'),
              style: TextStyle(fontSize: 14, color: colors.fg),
            ),
            const SizedBox(height: 16),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildLabel('Fecha', colors),
                      GestureDetector(
                        onTap: () {
                          FocusScope.of(context).unfocus();
                          setState(() {
                            _showingCalendar = !_showingCalendar;
                            if (_showingCalendar) _initCalendarMonth();
                          });
                        },
                        child: Container(
                          width: double.infinity,
                          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                          decoration: BoxDecoration(
                            color: colors.bg,
                            border: Border.all(color: colors.borderSoft),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Text(
                            _formatDisplayDate(),
                            style: TextStyle(fontSize: 14, color: colors.fg),
                          ),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Sin fecha = recordatorio',
                        style: TextStyle(fontSize: 11, color: colors.muted),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildLabel('Prioridad', colors),
                      Wrap(
                        spacing: 4,
                        runSpacing: 4,
                        children: [
                          PriorityChip(
                            label: 'Alta',
                            value: TaskPriority.alta,
                            isSelected: _selectedPriority == TaskPriority.alta,
                            onTap: () {
                              FocusScope.of(context).unfocus();
                              setState(() => _selectedPriority = TaskPriority.alta);
                            },
                          ),
                          PriorityChip(
                            label: 'Media',
                            value: TaskPriority.media,
                            isSelected: _selectedPriority == TaskPriority.media,
                            onTap: () {
                              FocusScope.of(context).unfocus();
                              setState(() => _selectedPriority = TaskPriority.media);
                            },
                          ),
                          PriorityChip(
                            label: 'Baja',
                            value: TaskPriority.baja,
                            isSelected: _selectedPriority == TaskPriority.baja,
                            onTap: () {
                              FocusScope.of(context).unfocus();
                              setState(() => _selectedPriority = TaskPriority.baja);
                            },
                          ),
                        ],
                      )
                    ],
                  ),
                ),
              ],
            ),
            _buildCalendarPicker(colors),
            const SizedBox(height: 24),
            Row(
              children: [
                Expanded(
                  child: TextButton(
                    onPressed: () => Navigator.pop(context),
                    style: TextButton.styleFrom(
                      backgroundColor: colors.bg,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                        side: BorderSide(color: colors.borderSoft),
                      ),
                    ),
                    child: Text('Cancelar', style: TextStyle(color: colors.muted, fontWeight: FontWeight.w600)),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: TextButton(
                    onPressed: _save,
                    style: TextButton.styleFrom(
                      backgroundColor: colors.accent,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    ),
                    child: Text(
                      isEditing ? 'Actualizar tarea' : 'Guardar tarea',
                      style: TextStyle(color: colors.accentOn, fontWeight: FontWeight.w600),
                    ),
                  ),
                ),
              ],
            )
          ],
        ),
      ),
    );
  }

  Widget _buildLabel(String text, AppColors colors) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Text(
        text,
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w600,
          color: colors.fg2,
          letterSpacing: 0.2,
        ),
      ),
    );
  }

  InputDecoration _inputDecoration(AppColors colors, String hint) {
    return InputDecoration(
      hintText: hint,
      hintStyle: TextStyle(color: colors.muted),
      filled: true,
      fillColor: colors.bg,
      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: BorderSide(color: colors.borderSoft),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: BorderSide(color: colors.borderSoft),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: BorderSide(color: colors.accent, width: 2),
      ),
    );
  }
}
