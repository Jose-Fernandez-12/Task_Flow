import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/task.dart';
import '../theme/app_theme.dart';
import 'priority_chip.dart';
import 'calendar_picker.dart';

class AddTaskModal extends StatefulWidget {
  final Task? taskToEdit;
  final Function(String title, String desc, String date, TaskPriority priority, TaskType type, String? time) onSave;

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
  TaskType _selectedType = TaskType.tarea;
  String? _selectedTime;
  
  bool _showingCalendar = false;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.taskToEdit?.title ?? '');
    _descController = TextEditingController(text: widget.taskToEdit?.desc ?? '');
    _selectedPriority = widget.taskToEdit?.priority ?? TaskPriority.media;
    _selectedType = widget.taskToEdit?.type ?? TaskType.tarea;
    _selectedTime = widget.taskToEdit?.time;

    if (widget.taskToEdit != null) {
      _selectedDate = widget.taskToEdit!.date;
    } else {
      _selectedDate = "";
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
        const SnackBar(content: Text('El título es requerido'), duration: Duration(seconds: 2)),
      );
      return;
    }
    widget.onSave(title, _descController.text.trim(), _selectedDate, _selectedPriority, _selectedType, _selectedTime);
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
              isEditing ? 'Editar' : 'Nuevo',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600, color: colors.fg),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                _buildTypeChip('Tarea', TaskType.tarea, colors),
                const SizedBox(width: 8),
                _buildTypeChip('Recordatorio', TaskType.recordatorio, colors),
                const SizedBox(width: 8),
                _buildTypeChip('Reunión', TaskType.reunion, colors),
              ],
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
                      if (_selectedType == TaskType.reunion) ...[
                        const SizedBox(height: 16),
                        _buildLabel('Hora (Requerido)', colors),
                        GestureDetector(
                          onTap: () async {
                            FocusScope.of(context).unfocus();
                            final time = await showTimePicker(
                              context: context,
                              initialTime: _selectedTime != null 
                                  ? TimeOfDay(hour: int.parse(_selectedTime!.split(':')[0]), minute: int.parse(_selectedTime!.split(':')[1]))
                                  : TimeOfDay.now(),
                            );
                            if (time != null) {
                              setState(() {
                                _selectedTime = "${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}";
                              });
                            }
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
                              _selectedTime ?? 'Seleccionar hora',
                              style: TextStyle(fontSize: 14, color: colors.fg),
                            ),
                          ),
                        ),
                      ],
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
            if (_showingCalendar) ...[
              CalendarPicker(
                selectedDate: _selectedDate,
                onSelect: (date) {
                  setState(() {
                    _selectedDate = date;
                    _showingCalendar = false;
                  });
                },
              ),
              const SizedBox(height: 4),
              Align(
                alignment: Alignment.centerRight,
                child: TextButton(
                  onPressed: () {
                    setState(() {
                      _selectedDate = '';
                      _showingCalendar = false;
                    });
                  },
                  child: Text(
                    'Borrar fecha',
                    style: TextStyle(fontSize: 12, color: colors.muted),
                  ),
                ),
              ),
            ],
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

  Widget _buildTypeChip(String label, TaskType type, AppColors colors) {
    final isSelected = _selectedType == type;
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => _selectedType = type),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 10),
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: isSelected ? colors.accent : colors.surfaceWarm,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Text(
            label,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: isSelected ? colors.accentOn : colors.fg2,
            ),
          ),
        ),
      ),
    );
  }
}
