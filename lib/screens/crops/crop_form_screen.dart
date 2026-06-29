import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../providers/app_provider.dart';
import '../../models/crop.dart';

class CropFormScreen extends StatefulWidget {
  final Crop? crop;
  const CropFormScreen({super.key, this.crop});

  @override
  State<CropFormScreen> createState() => _CropFormScreenState();
}

class _CropFormScreenState extends State<CropFormScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameCtrl;
  late TextEditingController _varietyCtrl;
  late TextEditingController _areaCtrl;
  late TextEditingController _notesCtrl;
  late TextEditingController _quantityCtrl;
  late TextEditingController _costCtrl;
  DateTime _plantingDate = DateTime.now();
  DateTime? _harvestDate;
  String _status = 'growing';

  bool get isEditing => widget.crop != null;

  @override
  void initState() {
    super.initState();
    final c = widget.crop;
    _nameCtrl = TextEditingController(text: c?.name ?? '');
    _varietyCtrl = TextEditingController(text: c?.variety ?? '');
    _areaCtrl = TextEditingController(
        text: c?.area.toString() ?? '');
    _notesCtrl = TextEditingController(text: c?.notes ?? '');
    _quantityCtrl = TextEditingController(
        text: c?.quantity.toString() ?? '');
    _costCtrl = TextEditingController(
        text: c?.cost.toString() ?? '');
    if (c != null) {
      _plantingDate = c.plantingDate;
      _harvestDate = c.harvestDate;
      _status = c.status;
    }
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _varietyCtrl.dispose();
    _areaCtrl.dispose();
    _notesCtrl.dispose();
    _quantityCtrl.dispose();
    _costCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {

    final dateFormat = DateFormat('dd/MM/yyyy');

    return Scaffold(
      appBar: AppBar(
        title: Text(isEditing ? 'Editar cultivo' : 'Nuevo cultivo'),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: EdgeInsets.all(16),
          children: [
            TextFormField(
              controller: _nameCtrl,
              decoration: InputDecoration(labelText: 'Nombre del cultivo *'),
              validator: (v) =>
                  v?.isEmpty == true ? 'Requerido' : null,
            ),
            SizedBox(height: 12),
            TextFormField(
              controller: _varietyCtrl,
              decoration: InputDecoration(labelText: 'Variedad'),
            ),
            SizedBox(height: 12),
            TextFormField(
              controller: _areaCtrl,
              decoration: InputDecoration(
                labelText: 'Área (hectáreas) *',
                suffixText: 'ha',
              ),
              keyboardType: TextInputType.number,
              validator: (v) =>
                  v?.isEmpty == true ? 'Requerido' : null,
            ),
            SizedBox(height: 12),
            ListTile(
              contentPadding: EdgeInsets.zero,
              leading: Icon(Icons.calendar_today),
              title: Text('Fecha de siembra'),
              subtitle: Text(dateFormat.format(_plantingDate)),
              onTap: () async {
                final date = await showDatePicker(
                  context: context,
                  initialDate: _plantingDate,
                  firstDate: DateTime(2020),
                  lastDate: DateTime(2030),
                );
                if (date != null) {
                  setState(() => _plantingDate = date);
                }
              },
            ),
            ListTile(
              contentPadding: EdgeInsets.zero,
              leading: Icon(Icons.calendar_today),
              title: Text('Fecha de cosecha'),
              subtitle: Text(_harvestDate != null
                  ? dateFormat.format(_harvestDate!)
                  : 'No definida'),
              onTap: () async {
                final date = await showDatePicker(
                  context: context,
                  initialDate: _harvestDate ?? DateTime.now(),
                  firstDate: DateTime(2020),
                  lastDate: DateTime(2030),
                );
                if (date != null) {
                  setState(() => _harvestDate = date);
                }
              },
            ),
            SizedBox(height: 12),
            DropdownButtonFormField<String>(
              initialValue: _status,
              decoration: InputDecoration(labelText: 'Estado'),
              items: [
                DropdownMenuItem(value: 'planted', child: Text('Sembrado')),
                DropdownMenuItem(value: 'growing', child: Text('Creciendo')),
                DropdownMenuItem(
                    value: 'harvested', child: Text('Cosechado')),
              ],
              onChanged: (v) => setState(() => _status = v!),
            ),
            SizedBox(height: 12),
            TextFormField(
              controller: _quantityCtrl,
              decoration: InputDecoration(
                labelText: 'Rendimiento esperado',
                suffixText: 'kg',
              ),
              keyboardType: TextInputType.number,
            ),
            SizedBox(height: 12),
            TextFormField(
              controller: _costCtrl,
              decoration: InputDecoration(
                labelText: 'Costo',
                prefixText: 'USD ',
              ),
              keyboardType: TextInputType.number,
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
              child: Text(isEditing ? 'Guardar cambios' : 'Agregar cultivo'),
            ),
          ],
        ),
      ),
    );
  }

  void _save() {
    if (!_formKey.currentState!.validate()) return;

    final crop = Crop(
      id: widget.crop?.id,
      name: _nameCtrl.text,
      variety: _varietyCtrl.text,
      plantingDate: _plantingDate,
      harvestDate: _harvestDate,
      area: double.parse(_areaCtrl.text),
      status: _status,
      notes: _notesCtrl.text,
      quantity: double.tryParse(_quantityCtrl.text) ?? 0,
      cost: double.tryParse(_costCtrl.text) ?? 0,
    );

    final provider = context.read<AppProvider>();
    if (isEditing) {
      provider.updateCrop(crop);
    } else {
      provider.addCrop(crop);
    }
    Navigator.pop(context);
  }
}
