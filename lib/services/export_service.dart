import 'dart:io';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:csv/csv.dart';
import 'package:share_plus/share_plus.dart';
import 'package:path_provider/path_provider.dart';
import 'package:intl/intl.dart';
import '../models/crop.dart';
import '../models/livestock.dart';
import '../models/inventory_item.dart';
import '../models/finance_record.dart';
import '../models/farm_task.dart';

class ExportService {
  static final _dateFormat = DateFormat('dd/MM/yyyy');
  static final _currencyFormat =
      NumberFormat.currency(symbol: 'USD ', decimalDigits: 2);

  static Future<void> shareFile(File file) async {
    await Share.shareXFiles(
      [XFile(file.path)],
      text: 'Reporte AgroManager',
    );
  }

  static pw.Table _buildTable(List<String> headers, List<List<String>> rows) {
    return pw.Table(
      border: pw.TableBorder.all(color: PdfColors.grey300),
      children: [
        pw.TableRow(
          decoration: pw.BoxDecoration(color: PdfColors.grey100),
          children: headers
              .map((h) => pw.Padding(
                    padding: pw.EdgeInsets.all(6),
                    child: pw.Text(h,
                        style: pw.TextStyle(
                            fontWeight: pw.FontWeight.bold, fontSize: 10)),
                  ))
              .toList(),
        ),
        ...rows.map((row) => pw.TableRow(
              children: row
                  .map((cell) => pw.Padding(
                        padding: pw.EdgeInsets.all(6),
                        child: pw.Text(cell, style: pw.TextStyle(fontSize: 9)),
                      ))
                  .toList(),
            )),
      ],
    );
  }

  static Future<File> generateCropReportPdf(List<Crop> crops) async {
    final pdf = pw.Document();
    pdf.addPage(
      pw.MultiPage(
        pageTheme: _pageTheme(),
        header: (_) => _header('Reporte de Cultivos'),
        footer: _footer,
        build: (_) => [
          _summary('Total de cultivos', '${crops.length}'),
          _summary('Área total',
              '${crops.fold<double>(0, (s, c) => s + c.area).toStringAsFixed(1)} ha'),
          pw.SizedBox(height: 16),
          _buildTable(
            ['Nombre', 'Variedad', 'Área (ha)', 'Estado', 'Siembra'],
            crops
                .map((c) => [
                      c.name,
                      c.variety,
                      c.area.toStringAsFixed(1),
                      _cropStatus(c.status),
                      _dateFormat.format(c.plantingDate),
                    ])
                .toList(),
          ),
        ],
      ),
    );
    return _savePdf('cultivos.pdf', pdf);
  }

  static Future<File> generateLivestockReportPdf(
      List<Livestock> animals) async {
    final pdf = pw.Document();
    pdf.addPage(
      pw.MultiPage(
        pageTheme: _pageTheme(),
        header: (_) => _header('Reporte de Ganado'),
        footer: _footer,
        build: (_) => [
          _summary('Total de animales', '${animals.length}'),
          pw.SizedBox(height: 16),
          _buildTable(
            ['Nombre', 'Tipo', 'Raza', 'Peso (kg)', 'Salud', 'Nacimiento'],
            animals
                .map((a) => [
                      a.name,
                      a.typeString,
                      a.breed,
                      a.weight.toStringAsFixed(1),
                      a.healthStatus == 'healthy'
                          ? 'Saludable'
                          : a.healthStatus == 'sick'
                              ? 'Enfermo'
                              : 'Tratamiento',
                      _dateFormat.format(a.birthDate),
                    ])
                .toList(),
          ),
        ],
      ),
    );
    return _savePdf('ganado.pdf', pdf);
  }

  static Future<File> generateInventoryReportPdf(
      List<InventoryItem> items) async {
    final pdf = pw.Document();
    final total = items.fold<double>(0, (s, i) => s + i.totalValue);
    pdf.addPage(
      pw.MultiPage(
        pageTheme: _pageTheme(),
        header: (_) => _header('Reporte de Inventario'),
        footer: _footer,
        build: (_) => [
          _summary('Total de items', '${items.length}'),
          _summary('Valor total', _currencyFormat.format(total)),
          _summary('Items con stock bajo',
              '${items.where((i) => i.isLowStock).length}'),
          pw.SizedBox(height: 16),
          _buildTable(
            ['Producto', 'Cant.', 'Unidad', 'Valor unit.', 'Valor total'],
            items
                .map((i) => [
                      i.name,
                      '${i.quantity}',
                      i.unit,
                      _currencyFormat.format(i.unitPrice),
                      _currencyFormat.format(i.totalValue),
                    ])
                .toList(),
          ),
        ],
      ),
    );
    return _savePdf('inventario.pdf', pdf);
  }

  static Future<File> generateFinanceReportPdf(
      List<FinanceRecord> records) async {
    final pdf = pw.Document();
    final income =
        records.fold<double>(0, (s, r) => r.type.index == 0 ? s + r.amount : s);
    final expense =
        records.fold<double>(0, (s, r) => r.type.index == 1 ? s + r.amount : s);
    pdf.addPage(
      pw.MultiPage(
        pageTheme: _pageTheme(),
        header: (_) => _header('Reporte de Finanzas'),
        footer: _footer,
        build: (_) => [
          _summary('Total ingresos', _currencyFormat.format(income)),
          _summary('Total gastos', _currencyFormat.format(expense)),
          _summary('Balance', _currencyFormat.format(income - expense)),
          pw.SizedBox(height: 16),
          _buildTable(
            ['Descripción', 'Tipo', 'Monto', 'Categoría', 'Fecha'],
            records
                .map((r) => [
                      r.description,
                      r.type.index == 0 ? 'Ingreso' : 'Gasto',
                      _currencyFormat.format(r.amount),
                      r.category,
                      _dateFormat.format(r.date),
                    ])
                .toList(),
          ),
        ],
      ),
    );
    return _savePdf('finanzas.pdf', pdf);
  }

  static Future<File> generateTaskReportPdf(List<FarmTask> tasks) async {
    final pdf = pw.Document();
    pdf.addPage(
      pw.MultiPage(
        pageTheme: _pageTheme(),
        header: (_) => _header('Reporte de Tareas'),
        footer: _footer,
        build: (_) => [
          _summary('Total de tareas', '${tasks.length}'),
          _summary('Pendientes',
              '${tasks.where((t) => t.status.index == 0).length}'),
          _summary('Completadas',
              '${tasks.where((t) => t.status.index == 2).length}'),
          pw.SizedBox(height: 16),
          _buildTable(
            ['Título', 'Prioridad', 'Estado', 'Categoría', 'Vencimiento'],
            tasks
                .map((t) => [
                      t.title,
                      t.priorityString,
                      t.statusString,
                      t.category,
                      t.dueDate != null ? _dateFormat.format(t.dueDate!) : '-',
                    ])
                .toList(),
          ),
        ],
      ),
    );
    return _savePdf('tareas.pdf', pdf);
  }

  static Future<File> generateFullReportPdf({
    required List<Crop> crops,
    required List<Livestock> livestock,
    required List<InventoryItem> inventory,
    required List<FinanceRecord> finances,
    required List<FarmTask> tasks,
  }) async {
    final pdf = pw.Document();
    final totalIncome =
        finances.fold<double>(0, (s, r) => r.type.index == 0 ? s + r.amount : s);
    final totalExpense =
        finances.fold<double>(0, (s, r) => r.type.index == 1 ? s + r.amount : s);
    final inventoryValue =
        inventory.fold<double>(0, (s, i) => s + i.totalValue);

    pdf.addPage(
      pw.MultiPage(
        pageTheme: _pageTheme(),
        header: (_) => _header('Reporte Completo - AgroManager'),
        footer: _footer,
        build: (_) => [
          pw.Header(level: 1, child: pw.Text('Resumen General')),
          _summary('Cultivos',
              '${crops.length} (${crops.fold<double>(0, (s, c) => s + c.area).toStringAsFixed(1)} ha)'),
          _summary('Ganado', '${livestock.length} animales'),
          _summary('Valor inventario', _currencyFormat.format(inventoryValue)),
          _summary('Total ingresos', _currencyFormat.format(totalIncome)),
          _summary('Total gastos', _currencyFormat.format(totalExpense)),
          _summary('Balance', _currencyFormat.format(totalIncome - totalExpense)),
          _summary('Tareas pendientes',
              '${tasks.where((t) => t.status.index < 2).length}'),
          pw.SizedBox(height: 20),
          pw.Header(level: 1, child: pw.Text('Cultivos')),
          _buildTable(
            ['Nombre', 'Área', 'Estado'],
            crops
                .map((c) => [c.name, '${c.area.toStringAsFixed(1)} ha', _cropStatus(c.status)])
                .toList(),
          ),
          pw.SizedBox(height: 20),
          pw.Header(level: 1, child: pw.Text('Finanzas (últimos 10)')),
          _buildTable(
            ['Descripción', 'Tipo', 'Monto'],
            finances.take(10).map((r) => [
                  r.description,
                  r.type.index == 0 ? 'Ingreso' : 'Gasto',
                  _currencyFormat.format(r.amount),
                ]).toList(),
          ),
          pw.SizedBox(height: 20),
          pw.Header(level: 1, child: pw.Text('Tareas pendientes')),
          _buildTable(
            ['Título', 'Prioridad', 'Vencimiento'],
            tasks
                .where((t) => t.status.index < 2)
                .map((t) => [
                      t.title,
                      t.priorityString,
                      t.dueDate != null ? _dateFormat.format(t.dueDate!) : '-',
                    ])
                .toList(),
          ),
        ],
      ),
    );
    return _savePdf('reporte_completo.pdf', pdf);
  }

  static String _cropStatus(String status) {
    switch (status) {
      case 'planted':
        return 'Sembrado';
      case 'growing':
        return 'Creciendo';
      case 'harvested':
        return 'Cosechado';
      default:
        return status;
    }
  }

  static pw.Widget _header(String title) {
    return pw.Row(
      mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
      children: [
        pw.Text('AgroManager', style: pw.TextStyle(fontSize: 10, color: PdfColors.grey)),
        pw.Text(title, style: pw.TextStyle(fontSize: 10, color: PdfColors.grey)),
      ],
    );
  }

  static pw.Widget _footer(pw.Context context) {
    return pw.Row(
      mainAxisAlignment: pw.MainAxisAlignment.center,
      children: [
        pw.Text(
          'Generado por AgroManager - ${_dateFormat.format(DateTime.now())}',
          style: pw.TextStyle(fontSize: 8, color: PdfColors.grey),
        ),
      ],
    );
  }

  static pw.Widget _summary(String label, String value) {
    return pw.Row(
      mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
      children: [
        pw.Text(label),
        pw.Text(value,
            style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
      ],
    );
  }

  static pw.PageTheme _pageTheme() {
    return pw.PageTheme(
      pageFormat: PdfPageFormat.a4,
      margin: pw.EdgeInsets.all(32),
      theme: pw.ThemeData.withFont(
        base: pw.Font.times(),
        bold: pw.Font.timesBold(),
      ),
    );
  }

  static Future<File> _savePdf(String filename, pw.Document pdf) async {
    final dir = await getApplicationDocumentsDirectory();
    final file = File('${dir.path}/$filename');
    await file.writeAsBytes(await pdf.save());
    return file;
  }

  static Future<File> generateCropCsv(List<Crop> crops) async {
    final rows = <List<String>>[
      ['Nombre', 'Variedad', 'Área (ha)', 'Estado', 'Siembra', 'Cosecha', 'Rend. (kg)', 'Costo (USD)'],
      ...crops.map((c) => [
            c.name,
            c.variety,
            c.area.toStringAsFixed(1),
            _cropStatus(c.status),
            _dateFormat.format(c.plantingDate),
            c.harvestDate != null ? _dateFormat.format(c.harvestDate!) : '',
            c.quantity.toStringAsFixed(1),
            c.cost.toStringAsFixed(2),
          ]),
    ];
    return _saveCsv('cultivos.csv', rows);
  }

  static Future<File> generateFinanceCsv(List<FinanceRecord> records) async {
    final rows = <List<String>>[
      ['Descripción', 'Tipo', 'Monto (USD)', 'Categoría', 'Fecha', 'Método pago'],
      ...records.map((r) => [
            r.description,
            r.type.index == 0 ? 'Ingreso' : 'Gasto',
            r.amount.toStringAsFixed(2),
            r.category,
            _dateFormat.format(r.date),
            r.paymentMethod,
          ]),
    ];
    return _saveCsv('finanzas.csv', rows);
  }

  static Future<File> generateInventoryCsv(List<InventoryItem> items) async {
    final rows = <List<String>>[
      ['Producto', 'Categoría', 'Cantidad', 'Unidad', 'Precio unit.', 'Stock mín.'],
      ...items.map((i) => [
            i.name,
            i.category,
            i.quantity.toString(),
            i.unit,
            i.unitPrice.toStringAsFixed(2),
            i.minStockLevel.toString(),
          ]),
    ];
    return _saveCsv('inventario.csv', rows);
  }

  static Future<File> _saveCsv(
      String filename, List<List<String>> rows) async {
    final csv = const ListToCsvConverter().convert(rows);
    final dir = await getApplicationDocumentsDirectory();
    final file = File('${dir.path}/$filename');
    await file.writeAsString(csv);
    return file;
  }
}
