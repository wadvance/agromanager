import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../providers/app_provider.dart';
import '../../models/livestock.dart';

class LivestockFormScreen extends StatefulWidget {
  final Livestock? animal;
  const LivestockFormScreen({super.key, this.animal});

  @override
  State<LivestockFormScreen> createState() => _LivestockFormScreenState();
}

class _LivestockFormScreenState extends State<LivestockFormScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameCtrl;
  late TextEditingController _breedCtrl;
  late TextEditingController _weightCtrl;
  late TextEditingController _genderCtrl;
  late TextEditingController _notesCtrl;
  late TextEditingController _purchaseCostCtrl;
  late TextEditingController _salePriceCtrl;
  AnimalType _type = AnimalType.cattle;
  DateTime _birthDate = DateTime.now();
  String _healthStatus = 'healthy';

  bool get isEditing => widget.animal != null;

  @override
  void initState() {
    super.initState();
    final a = widget.animal;
    _nameCtrl = TextEditingController(text: a?.name ?? '');
    _breedCtrl = TextEditingController(text: a?.breed ?? '');
    _weightCtrl =
        TextEditingController(text: a?.weight.toString() ?? '');
    _genderCtrl = TextEditingController(text: a?.gender ?? '');
    _notesCtrl = TextEditingController(text: a?.notes ?? '');
    _purchaseCostCtrl =
        TextEditingController(text: a?.purchaseCost.toString() ?? '');
    _salePriceCtrl =
        TextEditingController(text: a?.salePrice.toString() ?? '');
    if (a != null) {
      _type = a.type;
      _birthDate = a.birthDate;
      _healthStatus = a.healthStatus;
    }
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _breedCtrl.dispose();
    _weightCtrl.dispose();
    _genderCtrl.dispose();
    _notesCtrl.dispose();
    _purchaseCostCtrl.dispose();
    _salePriceCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final dateFormat = DateFormat('dd/MM/yyyy');

    return Scaffold(
      appBar: AppBar(
        title: Text(isEditing ? 'Editar animal' : 'Nuevo animal'),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: EdgeInsets.all(16),
          children: [
            TextFormField(
              controller: _nameCtrl,
              decoration:
                  InputDecoration(labelText: 'Nombre del animal *'),
              validator: (v) =>
                  v?.isEmpty == true ? 'Requerido' : null,
            ),
            SizedBox(height: 12),
            DropdownButtonFormField<AnimalType>(
              initialValue: _type,
              decoration: InputDecoration(labelText: 'Tipo'),
              items: AnimalType.values.map((t) {
                String label;
                switch (t) {
                  case AnimalType.cattle:
                    label = 'Bovino';
                    break;
                  case AnimalType.pig:
                    label = 'Porcino';
                    break;
                  case AnimalType.chicken:
                    label = 'Ave de corral';
                    break;
                  case AnimalType.goat:
                    label = 'Caprino';
                    break;
                  case AnimalType.sheep:
                    label = 'Ovino';
                    break;
                  case AnimalType.horse:
                    label = 'Equino';
                    break;
                  case AnimalType.other:
                    label = 'Otro';
                    break;
                }
                return DropdownMenuItem(value: t, child: Text(label));
              }).toList(),
              onChanged: (v) => setState(() => _type = v!),
            ),
            SizedBox(height: 12),
            TextFormField(
              controller: _breedCtrl,
              decoration: InputDecoration(labelText: 'Raza'),
            ),
            SizedBox(height: 12),
            ListTile(
              contentPadding: EdgeInsets.zero,
              leading: Icon(Icons.cake),
              title: Text('Fecha de nacimiento'),
              subtitle: Text(dateFormat.format(_birthDate)),
              onTap: () async {
                final date = await showDatePicker(
                  context: context,
                  initialDate: _birthDate,
                  firstDate: DateTime(2018),
                  lastDate: DateTime.now(),
                );
                if (date != null) {
                  setState(() => _birthDate = date);
                }
              },
            ),
            SizedBox(height: 12),
            TextFormField(
              controller: _weightCtrl,
              decoration: InputDecoration(
                labelText: 'Peso',
                suffixText: 'kg',
              ),
              keyboardType: TextInputType.number,
            ),
            SizedBox(height: 12),
            TextFormField(
              controller: _genderCtrl,
              decoration: InputDecoration(labelText: 'Sexo'),
            ),
            SizedBox(height: 12),
            DropdownButtonFormField<String>(
              initialValue: _healthStatus,
              decoration: InputDecoration(labelText: 'Estado de salud'),
              items: [
                DropdownMenuItem(
                    value: 'healthy', child: Text('Saludable')),
                DropdownMenuItem(
                    value: 'sick', child: Text('Enfermo')),
                DropdownMenuItem(
                    value: 'treatment', child: Text('En tratamiento')),
              ],
              onChanged: (v) =>
                  setState(() => _healthStatus = v!),
            ),
            SizedBox(height: 12),
            TextFormField(
              controller: _purchaseCostCtrl,
              decoration: InputDecoration(
                labelText: 'Costo de compra',
                prefixText: 'USD ',
              ),
              keyboardType: TextInputType.number,
            ),
            SizedBox(height: 12),
            TextFormField(
              controller: _salePriceCtrl,
              decoration: InputDecoration(
                labelText: 'Precio de venta',
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
              child:
                  Text(isEditing ? 'Guardar cambios' : 'Agregar animal'),
            ),
          ],
        ),
      ),
    );
  }

  void _save() {
    if (!_formKey.currentState!.validate()) return;

    final animal = Livestock(
      id: widget.animal?.id,
      name: _nameCtrl.text,
      type: _type,
      breed: _breedCtrl.text,
      birthDate: _birthDate,
      weight: double.tryParse(_weightCtrl.text) ?? 0,
      gender: _genderCtrl.text,
      healthStatus: _healthStatus,
      notes: _notesCtrl.text,
      purchaseCost: double.tryParse(_purchaseCostCtrl.text) ?? 0,
      salePrice: double.tryParse(_salePriceCtrl.text) ?? 0,
    );

    final provider = context.read<AppProvider>();
    if (isEditing) {
      provider.updateLivestock(animal);
    } else {
      provider.addLivestock(animal);
    }
    Navigator.pop(context);
  }
}
