import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../providers/app_provider.dart';
import '../../models/finance_record.dart';

class FinanceFormScreen extends StatefulWidget {
  final FinanceRecord? record;
  const FinanceFormScreen({super.key, this.record});

  @override
  State<FinanceFormScreen> createState() => _FinanceFormScreenState();
}

class _FinanceFormScreenState extends State<FinanceFormScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _descriptionCtrl;
  late TextEditingController _amountCtrl;
  late TextEditingController _categoryCtrl;
  late TextEditingController _paymentMethodCtrl;
  late TextEditingController _notesCtrl;
  TransactionType _type = TransactionType.expense;
  DateTime _date = DateTime.now();

  bool get isEditing => widget.record != null;

  @override
  void initState() {
    super.initState();
    final r = widget.record;
    _descriptionCtrl = TextEditingController(text: r?.description ?? '');
    _amountCtrl =
        TextEditingController(text: r?.amount.toString() ?? '');
    _categoryCtrl = TextEditingController(text: r?.category ?? 'general');
    _paymentMethodCtrl =
        TextEditingController(text: r?.paymentMethod ?? 'efectivo');
    _notesCtrl = TextEditingController(text: r?.notes ?? '');
    if (r != null) {
      _type = r.type;
      _date = r.date;
    }
  }

  @override
  void dispose() {
    _descriptionCtrl.dispose();
    _amountCtrl.dispose();
    _categoryCtrl.dispose();
    _paymentMethodCtrl.dispose();
    _notesCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final dateFormat = DateFormat('dd/MM/yyyy');

    return Scaffold(
      appBar: AppBar(
        title:
            Text(isEditing ? 'Editar transacción' : 'Nueva transacción'),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: EdgeInsets.all(16),
          children: [
            SegmentedButton<TransactionType>(
              segments: [
                ButtonSegment(
                  value: TransactionType.income,
                  label: Text('Ingreso'),
                  icon: Icon(Icons.arrow_upward),
                ),
                ButtonSegment(
                  value: TransactionType.expense,
                  label: Text('Gasto'),
                  icon: Icon(Icons.arrow_downward),
                ),
              ],
              selected: {_type},
              onSelectionChanged: (v) =>
                  setState(() => _type = v.first),
            ),
            SizedBox(height: 16),
            TextFormField(
              controller: _descriptionCtrl,
              decoration:
                  InputDecoration(labelText: 'Descripción *'),
              validator: (v) =>
                  v?.isEmpty == true ? 'Requerido' : null,
            ),
            SizedBox(height: 12),
            TextFormField(
              controller: _amountCtrl,
              decoration: InputDecoration(
                labelText: 'Monto *',
                prefixText: 'USD ',
              ),
              keyboardType: TextInputType.number,
              validator: (v) =>
                  v?.isEmpty == true ? 'Requerido' : null,
            ),
            SizedBox(height: 12),
            TextFormField(
              controller: _categoryCtrl,
              decoration: InputDecoration(labelText: 'Categoría'),
            ),
            SizedBox(height: 12),
            ListTile(
              contentPadding: EdgeInsets.zero,
              leading: Icon(Icons.calendar_today),
              title: Text('Fecha'),
              subtitle: Text(dateFormat.format(_date)),
              onTap: () async {
                final date = await showDatePicker(
                  context: context,
                  initialDate: _date,
                  firstDate: DateTime(2020),
                  lastDate: DateTime(2030),
                );
                if (date != null) {
                  setState(() => _date = date);
                }
              },
            ),
            SizedBox(height: 12),
            TextFormField(
              controller: _paymentMethodCtrl,
              decoration: InputDecoration(labelText: 'Método de pago'),
            ),
            SizedBox(height: 12),
            TextFormField(
              controller: _notesCtrl,
              decoration: InputDecoration(labelText: 'Notas'),
              maxLines: 3,
            ),
            SizedBox(height: 24),
            FilledButton(
              onPressed: _save,
              child: Text(isEditing
                  ? 'Guardar cambios'
                  : 'Agregar transacción'),
            ),
          ],
        ),
      ),
    );
  }

  void _save() {
    if (!_formKey.currentState!.validate()) return;

    final record = FinanceRecord(
      id: widget.record?.id,
      description: _descriptionCtrl.text,
      amount: double.parse(_amountCtrl.text),
      type: _type,
      category: _categoryCtrl.text,
      date: _date,
      paymentMethod: _paymentMethodCtrl.text,
      notes: _notesCtrl.text,
    );

    final provider = context.read<AppProvider>();
    if (isEditing) {
      provider.updateFinanceRecord(record);
    } else {
      provider.addFinanceRecord(record);
    }
    Navigator.pop(context);
  }
}
