import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../providers/app_provider.dart';
import '../../models/livestock.dart';
import '../../widgets/empty_state.dart';
import 'livestock_form_screen.dart';

class LivestockScreen extends StatelessWidget {
  const LivestockScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final dateFormat = DateFormat('dd/MM/yyyy');

    return Consumer<AppProvider>(
      builder: (context, provider, _) {
        final animals = provider.livestock;

        return Scaffold(
          appBar: AppBar(
            title: Text('Ganado'),
            actions: [
              TextButton.icon(
                onPressed: () => _showForm(context),
                icon: Icon(Icons.add, color: Colors.white),
                label:
                    Text('Nuevo', style: TextStyle(color: Colors.white)),
              ),
            ],
          ),
          body: animals.isEmpty
              ? EmptyState(
                  icon: Icons.pets,
                  title: 'No hay animales registrados',
                  subtitle: 'Agrega tu primer animal',
                  actionLabel: 'Agregar animal',
                  onAction: () => _showForm(context),
                )
              : RefreshIndicator(
                  onRefresh: () => provider.loadAll(),
                  child: ListView.builder(
                    padding: EdgeInsets.all(12),
                    itemCount: animals.length,
                    itemBuilder: (context, index) {
                      final animal = animals[index];
                      return Card(
                        child: ListTile(
                          contentPadding: EdgeInsets.all(12),
                          leading: Container(
                            width: 48,
                            height: 48,
                            decoration: BoxDecoration(
                              color: _typeColor(animal.type).withAlpha(30),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Icon(
                              Icons.pets,
                              color: _typeColor(animal.type),
                            ),
                          ),
                          title: Text(animal.name,
                              style:
                                  TextStyle(fontWeight: FontWeight.bold)),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(animal.typeString),
                              Text(
                                  'Nacido: ${dateFormat.format(animal.birthDate)}'),
                              Row(
                                children: [
                                  if (animal.healthStatus == 'healthy')
                                    Icon(Icons.check_circle,
                                        size: 14, color: Colors.green)
                                  else
                                    Icon(Icons.warning,
                                        size: 14, color: Colors.red),
                                  SizedBox(width: 4),
                                  Text(
                                    animal.healthStatus == 'healthy'
                                        ? 'Saludable'
                                        : animal.healthStatus == 'sick'
                                            ? 'Enfermo'
                                            : 'En tratamiento',
                                    style: TextStyle(fontSize: 12),
                                  ),
                                ],
                              ),
                            ],
                          ),
                          isThreeLine: true,
                          trailing: PopupMenuButton<String>(
                            onSelected: (value) {
                              if (value == 'edit') {
                                _showForm(context, animal: animal);
                              } else if (value == 'delete') {
                                _confirmDelete(context, animal);
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
                                        size: 18, color: Colors.red),
                                    SizedBox(width: 8),
                                    Text('Eliminar',
                                        style: TextStyle(color: Colors.red))
                                  ])),
                            ],
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

  Color _typeColor(AnimalType type) {
    switch (type) {
      case AnimalType.cattle:
        return Colors.brown;
      case AnimalType.pig:
        return Colors.pink;
      case AnimalType.chicken:
        return Colors.orange;
      case AnimalType.goat:
        return Colors.grey;
      case AnimalType.sheep:
        return Colors.blueGrey;
      case AnimalType.horse:
        return Colors.indigo;
      case AnimalType.other:
        return Colors.purple;
    }
  }

  void _showForm(BuildContext context, {Livestock? animal}) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => LivestockFormScreen(animal: animal),
      ),
    );
  }

  void _confirmDelete(BuildContext context, Livestock animal) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('Eliminar animal'),
        content: Text('¿Eliminar "${animal.name}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text('Cancelar'),
          ),
          TextButton(
            onPressed: () {
              context.read<AppProvider>().deleteLivestock(animal.id!);
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
