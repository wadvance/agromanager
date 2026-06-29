import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../providers/app_provider.dart';
import '../../models/farm_task.dart';
import '../../widgets/empty_state.dart';
import 'task_form_screen.dart';

class TasksScreen extends StatelessWidget {
  const TasksScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final dateFormat = DateFormat('dd/MM/yyyy');

    return Consumer<AppProvider>(
      builder: (context, provider, _) {
        final tasks = provider.tasks;

        return Scaffold(
          appBar: AppBar(
            title: Text('Tareas'),
            actions: [
              TextButton.icon(
                onPressed: () => _showForm(context),
                icon: Icon(Icons.add, color: Colors.white),
                label:
                    Text('Nueva', style: TextStyle(color: Colors.white)),
              ),
            ],
          ),
          body: tasks.isEmpty
              ? EmptyState(
                  icon: Icons.checklist,
                  title: 'No hay tareas',
                  subtitle: 'Crea tu primera tarea',
                  actionLabel: 'Nueva tarea',
                  onAction: () => _showForm(context),
                )
              : RefreshIndicator(
                  onRefresh: () => provider.loadAll(),
                  child: ListView.builder(
                    padding: EdgeInsets.all(12),
                    itemCount: tasks.length,
                    itemBuilder: (context, index) {
                      final task = tasks[index];
                      final isOverdue = task.dueDate != null &&
                          task.dueDate!.isBefore(DateTime.now()) &&
                          task.status != TaskStatus.completed &&
                          task.status != TaskStatus.cancelled;

                      return Dismissible(
                        key: Key(task.id.toString()),
                        direction: DismissDirection.endToStart,
                        background: Container(
                          alignment: Alignment.centerRight,
                          padding: EdgeInsets.only(right: 20),
                          color: Colors.green,
                          child: Icon(Icons.check, color: Colors.white),
                        ),
                        onDismissed: (_) {
                          final updated = task.copyWith(
                            status: TaskStatus.completed,
                            completedDate: DateTime.now(),
                          );
                          provider.updateTask(updated);
                        },
                        child: Card(
                          child: ListTile(
                            contentPadding: EdgeInsets.all(12),
                            leading: GestureDetector(
                              onTap: () {
                                final newStatus =
                                    task.status == TaskStatus.completed
                                        ? TaskStatus.pending
                                        : TaskStatus.completed;
                                final updated = task.copyWith(
                                  status: newStatus,
                                  completedDate: newStatus ==
                                          TaskStatus.completed
                                      ? DateTime.now()
                                      : null,
                                );
                                provider.updateTask(updated);
                              },
                              child: Container(
                                width: 28,
                                height: 28,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  border: Border.all(
                                    color: task.status ==
                                            TaskStatus.completed
                                        ? Colors.green
                                        : Colors.grey,
                                    width: 2,
                                  ),
                                  color: task.status ==
                                          TaskStatus.completed
                                      ? Colors.green
                                      : Colors.transparent,
                                ),
                                child: task.status == TaskStatus.completed
                                    ? Icon(Icons.check,
                                        size: 18, color: Colors.white)
                                    : null,
                              ),
                            ),
                            title: Text(
                              task.title,
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                decoration: task.status ==
                                        TaskStatus.completed
                                    ? TextDecoration.lineThrough
                                    : null,
                                color: task.status ==
                                        TaskStatus.completed
                                    ? Colors.grey
                                    : null,
                              ),
                            ),
                            subtitle: Column(
                              crossAxisAlignment:
                                  CrossAxisAlignment.start,
                              children: [
                                if (task.description.isNotEmpty)
                                  Text(task.description,
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis),
                                if (task.dueDate != null)
                                  Row(
                                    children: [
                                      Icon(
                                        Icons.schedule,
                                        size: 14,
                                        color: isOverdue
                                            ? Colors.red
                                            : Colors.grey,
                                      ),
                                      SizedBox(width: 4),
                                      Text(
                                        dateFormat.format(task.dueDate!),
                                        style: TextStyle(
                                          fontSize: 12,
                                          color: isOverdue
                                              ? Colors.red
                                              : Colors.grey,
                                        ),
                                      ),
                                    ],
                                  ),
                              ],
                            ),
                            trailing: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Container(
                                  padding: EdgeInsets.symmetric(
                                      horizontal: 8, vertical: 4),
                                  decoration: BoxDecoration(
                                    color: _priorityColor(task.priority)
                                        .withAlpha(30),
                                    borderRadius:
                                        BorderRadius.circular(12),
                                  ),
                                  child: Text(
                                    task.priorityString,
                                    style: TextStyle(
                                      fontSize: 11,
                                      color:
                                          _priorityColor(task.priority),
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                                PopupMenuButton<String>(
                                  onSelected: (value) {
                                    if (value == 'edit') {
                                      _showForm(context, task: task);
                                    } else if (value == 'delete') {
                                      _confirmDelete(context, task);
                                    }
                                  },
                                  itemBuilder: (_) => [
                                    PopupMenuItem(
                                        value: 'edit',
                                        child: Row(children: [
                                          Icon(Icons.edit, size: 18),
                                          SizedBox(width: 8),
                                          Text('Editar')
                                        ])),
                                    PopupMenuItem(
                                        value: 'delete',
                                        child: Row(children: [
                                          Icon(Icons.delete,
                                              size: 18,
                                              color: Colors.red),
                                          SizedBox(width: 8),
                                          Text('Eliminar',
                                              style: TextStyle(
                                                  color: Colors.red))
                                        ])),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
        );
      },
    );
  }

  Color _priorityColor(TaskPriority p) {
    switch (p) {
      case TaskPriority.low:
        return Colors.grey;
      case TaskPriority.medium:
        return Colors.blue;
      case TaskPriority.high:
        return Colors.orange;
      case TaskPriority.urgent:
        return Colors.red;
    }
  }

  void _showForm(BuildContext context, {FarmTask? task}) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => TaskFormScreen(task: task),
      ),
    );
  }

  void _confirmDelete(BuildContext context, FarmTask task) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('Eliminar tarea'),
        content: Text('¿Eliminar "${task.title}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text('Cancelar'),
          ),
          TextButton(
            onPressed: () {
              context.read<AppProvider>().deleteTask(task.id!);
              Navigator.pop(ctx);
            },
            child: Text('Eliminar',
                style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}
