import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../providers/app_provider.dart';
import '../../models/inventory_item.dart';
import '../../widgets/empty_state.dart';
import 'inventory_form_screen.dart';

class InventoryScreen extends StatelessWidget {
  const InventoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final currencyFormat =
        NumberFormat.currency(symbol: 'USD ', decimalDigits: 2);

    return Consumer<AppProvider>(
      builder: (context, provider, _) {
        final items = provider.inventory;

        return Scaffold(
          appBar: AppBar(
            title: Text('Inventario'),
            actions: [
              TextButton.icon(
                onPressed: () => _showForm(context),
                icon: Icon(Icons.add, color: Colors.white),
                label:
                    Text('Nuevo', style: TextStyle(color: Colors.white)),
              ),
            ],
          ),
          body: items.isEmpty
              ? EmptyState(
                  icon: Icons.inventory,
                  title: 'Inventario vacío',
                  subtitle: 'Agrega productos e insumos',
                  actionLabel: 'Agregar item',
                  onAction: () => _showForm(context),
                )
              : RefreshIndicator(
                  onRefresh: () => provider.loadAll(),
                  child: ListView.builder(
                    padding: EdgeInsets.all(12),
                    itemCount: items.length,
                    itemBuilder: (context, index) {
                      final item = items[index];
                      final isLow = item.isLowStock;

                      return Card(
                        child: ListTile(
                          contentPadding: EdgeInsets.all(12),
                          leading: Container(
                            width: 48,
                            height: 48,
                            decoration: BoxDecoration(
                              color: isLow
                                  ? Colors.red.withAlpha(30)
                                  : theme.colorScheme.primary.withAlpha(30),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Icon(
                              isLow
                                  ? Icons.warning_amber
                                  : Icons.inventory_2,
                              color: isLow ? Colors.red : theme.colorScheme.primary,
                            ),
                          ),
                          title: Text(item.name,
                              style:
                                  TextStyle(fontWeight: FontWeight.bold)),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                  '${item.quantity} ${item.unit} | ${currencyFormat.format(item.totalValue)}'),
                              if (isLow)
                                Text(
                                  'Stock bajo (mín: ${item.minStockLevel})',
                                  style: TextStyle(
                                      color: Colors.red, fontSize: 12),
                                ),
                            ],
                          ),
                          isThreeLine: isLow,
                          trailing: PopupMenuButton<String>(
                            onSelected: (value) {
                              if (value == 'edit') {
                                _showForm(context, item: item);
                              } else if (value == 'delete') {
                                _confirmDelete(context, item);
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
                                        style:
                                            TextStyle(color: Colors.red))
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

  void _showForm(BuildContext context, {InventoryItem? item}) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => InventoryFormScreen(item: item),
      ),
    );
  }

  void _confirmDelete(BuildContext context, InventoryItem item) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('Eliminar item'),
        content: Text('¿Eliminar "${item.name}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text('Cancelar'),
          ),
          TextButton(
            onPressed: () {
              context.read<AppProvider>().deleteInventoryItem(item.id!);
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
