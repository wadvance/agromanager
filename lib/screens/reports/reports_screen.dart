import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/app_provider.dart';
import '../../services/firebase_service.dart';

class ReportsScreen extends StatelessWidget {
  const ReportsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text('Reportes'),
      ),
      body: Consumer<AppProvider>(
        builder: (context, provider, _) {
          return ListView(
            padding: EdgeInsets.all(16),
            children: [
              Text(
                'Reportes PDF',
                style: theme.textTheme.titleMedium
                    ?.copyWith(fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 8),
              _reportTile(
                context,
                icon: Icons.grass,
                title: 'Cultivos',
                subtitle: 'Listado completo de cultivos',
                color: Colors.green,
                onPdf: () => provider.exportCropReport(),
                onCsv: () => provider.exportCropCsv(),
              ),
              _reportTile(
                context,
                icon: Icons.pets,
                title: 'Ganado',
                subtitle: 'Inventario de animales',
                color: Colors.brown,
                onPdf: () => provider.exportLivestockReport(),
              ),
              _reportTile(
                context,
                icon: Icons.inventory,
                title: 'Inventario',
                subtitle: 'Productos e insumos',
                color: Colors.blue,
                onPdf: () => provider.exportInventoryReport(),
                onCsv: () => provider.exportInventoryCsv(),
              ),
              _reportTile(
                context,
                icon: Icons.account_balance,
                title: 'Finanzas',
                subtitle: 'Ingresos y gastos',
                color: Colors.orange,
                onPdf: () => provider.exportFinanceReport(),
                onCsv: () => provider.exportFinanceCsv(),
              ),
              _reportTile(
                context,
                icon: Icons.checklist,
                title: 'Tareas',
                subtitle: 'Tareas de la finca',
                color: Colors.purple,
                onPdf: () => provider.exportTaskReport(),
              ),
              Divider(height: 32),
              SizedBox(
                width: double.infinity,
                child: FilledButton.icon(
                  onPressed: () => provider.exportFullReport(),
                  icon: Icon(Icons.description),
                  label: Text('Reporte completo PDF'),
                  style: FilledButton.styleFrom(
                    padding: EdgeInsets.all(16),
                  ),
                ),
              ),
              SizedBox(height: 24),
              Text(
                'Sincronización en la nube',
                style: theme.textTheme.titleMedium
                    ?.copyWith(fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: provider.isSyncing
                          ? null
                          : () => provider.syncToCloud(),
                      icon: Icon(Icons.cloud_upload),
                      label: Text('Subir datos'),
                    ),
                  ),
                  SizedBox(width: 12),
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: provider.isSyncing
                          ? null
                          : () => provider.syncFromCloud(),
                      icon: Icon(Icons.cloud_download),
                      label: Text('Descargar'),
                    ),
                  ),
                ],
              ),
              if (provider.syncMessage != null) ...[
                SizedBox(height: 8),
                Card(
                  color: theme.colorScheme.primaryContainer,
                  child: Padding(
                    padding: EdgeInsets.all(12),
                    child: Row(
                      children: [
                        if (provider.isSyncing)
                          Padding(
                            padding: EdgeInsets.only(right: 8),
                            child: SizedBox(
                              width: 16,
                              height: 16,
                              child: CircularProgressIndicator(
                                  strokeWidth: 2),
                            ),
                          ),
                        Expanded(
                          child: Text(provider.syncMessage!),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
              SizedBox(height: 24),
              Text(
                'Cuenta',
                style: theme.textTheme.titleMedium
                    ?.copyWith(fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 8),
              if (provider.isLoggedIn)
                Card(
                  child: ListTile(
                    leading: Icon(Icons.logout, color: Colors.red),
                    title: Text('Cerrar sesión'),
                    onTap: () {
                      FirebaseService.signOut();
                      provider.setLoggedIn(false);
                    },
                  ),
                ),
            ],
          );
        },
      ),
    );
  }

  Widget _reportTile(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String subtitle,
    required Color color,
    VoidCallback? onPdf,
    VoidCallback? onCsv,
  }) {
    return Card(
      margin: EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: Container(
          padding: EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: color.withAlpha(30),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, color: color),
        ),
        title: Text(title, style: TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text(subtitle),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (onPdf != null)
              IconButton(
                icon: Icon(Icons.picture_as_pdf, color: Colors.red),
                tooltip: 'Exportar PDF',
                onPressed: onPdf,
              ),
            if (onCsv != null)
              IconButton(
                icon: Icon(Icons.table_chart, color: Colors.green),
                tooltip: 'Exportar CSV',
                onPressed: onCsv,
              ),
          ],
        ),
      ),
    );
  }
}
