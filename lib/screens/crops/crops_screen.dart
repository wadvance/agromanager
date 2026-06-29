import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../providers/app_provider.dart';
import '../../models/crop.dart';
import '../../widgets/empty_state.dart';
import 'crop_form_screen.dart';

class CropsScreen extends StatelessWidget {
  const CropsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final dateFormat = DateFormat('dd/MM/yyyy');

    return Consumer<AppProvider>(
      builder: (context, provider, _) {
        final crops = provider.crops;

        return Scaffold(
          appBar: AppBar(
            title: Text('Cultivos'),
            actions: [
              TextButton.icon(
                onPressed: () => _showCropForm(context),
                icon: Icon(Icons.add, color: Colors.white),
                label: Text('Nuevo', style: TextStyle(color: Colors.white)),
              ),
            ],
          ),
          body: crops.isEmpty
              ? EmptyState(
                  icon: Icons.grass,
                  title: 'No hay cultivos registrados',
                  subtitle: 'Agrega tu primer cultivo',
                  actionLabel: 'Agregar cultivo',
                  onAction: () => _showCropForm(context),
                )
              : RefreshIndicator(
                  onRefresh: () => provider.loadAll(),
                  child: ListView.builder(
                    padding: EdgeInsets.all(12),
                    itemCount: crops.length,
                    itemBuilder: (context, index) {
                      final crop = crops[index];
                      return Card(
                        child: ListTile(
                          contentPadding: EdgeInsets.all(12),
                          leading: Container(
                            width: 48,
                            height: 48,
                            decoration: BoxDecoration(
                              color: _statusColor(crop.status).withAlpha(30),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Icon(
                              Icons.grass,
                              color: _statusColor(crop.status),
                            ),
                          ),
                          title: Text(crop.name,
                              style: TextStyle(fontWeight: FontWeight.bold)),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              if (crop.variety.isNotEmpty)
                                Text('Variedad: ${crop.variety}'),
                              Text(
                                  '${crop.area.toStringAsFixed(1)} ha | ${dateFormat.format(crop.plantingDate)}'),
                              Row(
                                children: [
                                  Container(
                                    padding: EdgeInsets.symmetric(
                                        horizontal: 8, vertical: 2),
                                    decoration: BoxDecoration(
                                      color: _statusColor(crop.status),
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: Text(
                                      crop.status == 'planted'
                                          ? 'Sembrado'
                                          : crop.status == 'growing'
                                              ? 'Creciendo'
                                              : 'Cosechado',
                                      style: TextStyle(
                                          color: Colors.white, fontSize: 11),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                          isThreeLine: true,
                          trailing: PopupMenuButton<String>(
                            onSelected: (value) {
                              if (value == 'edit') {
                                _showCropForm(context, crop: crop);
                              } else if (value == 'delete') {
                                _confirmDelete(context, crop);
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
                                    Icon(Icons.delete, size: 18,
                                        color: Colors.red),
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

  Color _statusColor(String status) {
    switch (status) {
      case 'planted':
        return Colors.blue;
      case 'growing':
        return Colors.green;
      case 'harvested':
        return Colors.orange;
      default:
        return Colors.grey;
    }
  }

  void _showCropForm(BuildContext context, {Crop? crop}) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => CropFormScreen(crop: crop),
      ),
    );
  }

  void _confirmDelete(BuildContext context, Crop crop) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('Eliminar cultivo'),
        content: Text('¿Eliminar "${crop.name}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text('Cancelar'),
          ),
          TextButton(
            onPressed: () {
              context.read<AppProvider>().deleteCrop(crop.id!);
              Navigator.pop(ctx);
            },
            child: Text('Eliminar', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}
