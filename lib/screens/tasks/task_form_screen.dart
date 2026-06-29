import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../providers/app_provider.dart';
import '../../models/farm_task.dart';

class TaskFormScreen extends StatefulWidget {
  final FarmTask? task;
  const TaskFormScreen({super.key, this.task});

  @override
  State<TaskFormScreen> createState() => _TaskFormScreenState();
}

class _TaskFormScreenState extends State<TaskFormScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _titleCtrl;
  late TextEditingController _descriptionCtrl;
  late TextEditingController _assignedToCtrl;
  late TextEditingController _categoryCtrl;
  TaskPriority _priority = TaskPriority.medium;
  TaskStatus _status = TaskStatus.pending;
  DateTime? _dueDate;

  bool get isEditing => widget.task != null;

  @override
  void initState() {
    super.initState();
    final t = widget.task;
    _titleCtrl = TextEditingController(text: t?.title ?? '');
    _descriptionCtrl =
        TextEditingController(text: t?.description ?? '');
    _assignedToCtrl = TextEditingController(text: t?.assignedTo ?? '');
    _categoryCtrl = TextEditingController(text: t?.category ?? 'general');
    if (t != null) {
      _priority = t.priority;
      _status = t.status;
      _dueDate = t.dueDate;
    }
  }

  @override
  void dispose() {
    _titleCtrl.dispose();
    _descriptionCtrl.dispose();
    _assignedToCtrl.dispose();
    _categoryCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final dateFormat = DateFormat('dd/MM/yyyy');

    return Scaffold(
      appBar: AppBar(
        title: Text(isEditing ? 'Editar tarea' : 'Nueva tarea'),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: EdgeInsets.all(16),
          children: [
            TextFormField(
              controller: _titleCtrl,
              decoration: InputDecoration(labelText: 'Título *'),
              validator: (v) =>
                  v?.isEmpty == true ? 'Requerido' : null,
            ),
            SizedBox(height: 12),
            TextFormField(
              controller: _descriptionCtrl,
              decoration: InputDecoration(labelText: 'Descripción'),
              maxLines: 3,
            ),
            SizedBox(height: 12),
            DropdownButtonFormField<TaskPriority>(
              initialValue: _priority,
              decoration: InputDecoration(labelText: 'Prioridad'),
              items: [
                DropdownMenuItem(
                    value: TaskPriority.low,
                    child: Text('Baja')),
                DropdownMenuItem(
                    value: TaskPriority.medium,
                    child: Text('Media')),
                DropdownMenuItem(
                    value: TaskPriority.high,
                    child: Text('Alta')),
                DropdownMenuItem(
                    value: TaskPriority.urgent,
                    child: Text('Urgente')),
              ],
              onChanged: (v) =>
                  setState(() => _priority = v!),
            ),
            SizedBox(height: 12),
            if (isEditing)
              DropdownButtonFormField<TaskStatus>(
                initialValue: _status,
                decoration: InputDecoration(labelText: 'Estado'),
                items: [
                  DropdownMenuItem(
                      value: TaskStatus.pending,
                      child: Text('Pendiente')),
                  DropdownMenuItem(
                      value: TaskStatus.inProgress,
                      child: Text('En progreso')),
                  DropdownMenuItem(
                      value: TaskStatus.completed,
                      child: Text('Completada')),
                  DropdownMenuItem(
                      value: TaskStatus.cancelled,
                      child: Text('Cancelada')),
                ],
                onChanged: (v) =>
                    setState(() => _status = v!),
              ),
            SizedBox(height: 12),
            ListTile(
              contentPadding: EdgeInsets.zero,
              leading: Icon(Icons.calendar_today),
              title: Text('Fecha de vencimiento'),
              subtitle: Text(_dueDate != null
                  ? dateFormat.format(_dueDate!)
                  : 'Sin fecha límite'),
              onTap: () async {
                final date = await showDatePicker(
                  context: context,
                  initialDate: _dueDate ?? DateTime.now(),
                  firstDate: DateTime.now().subtract(Duration(days: 1)),
                  lastDate: DateTime(2030),
                );
                if (date != null) {
                  setState(() => _dueDate = date);
                }
              },
            ),
            if (_dueDate != null)
              TextButton(
                onPressed: () =>
                    setState(() => _dueDate = null),
                child: Text('Quitar fecha'),
              ),
            SizedBox(height: 12),
            TextFormField(
              controller: _assignedToCtrl,
              decoration:
                  InputDecoration(labelText: 'Asignado a'),
            ),
            SizedBox(height: 12),
            TextFormField(
              controller: _categoryCtrl,
              decoration: InputDecoration(labelText: 'Categoría'),
            ),
            SizedBox(height: 24),
            FilledButton(
              onPressed: _save,
              child:
                  Text(isEditing ? 'Guardar cambios' : 'Crear tarea'),
            ),
          ],
        ),
      ),
    );
  }

  void _save() {
    if (!_formKey.currentState!.validate()) return;

    final task = FarmTask(
      id: widget.task?.id,
      title: _titleCtrl.text,
      description: _descriptionCtrl.text,
      priority: _priority,
      status: isEditing ? _status : TaskStatus.pending,
      dueDate: _dueDate,
      assignedTo: _assignedToCtrl.text,
      category: _categoryCtrl.text,
    );

    final provider = context.read<AppProvider>();
    if (isEditing) {
      provider.updateTask(task);
    } else {
      provider.addTask(task);
    }
    Navigator.pop(context);
  }
}
