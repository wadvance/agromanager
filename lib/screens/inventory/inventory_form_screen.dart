import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/app_provider.dart';
import '../../models/inventory_item.dart';

class InventoryFormScreen extends StatefulWidget {
  final InventoryItem? item;
  const InventoryFormScreen({super.key, this.item});

  @override
  State<InventoryFormScreen> createState() => _InventoryFormScreenState();
}

class _InventoryFormScreenState extends State<InventoryFormScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameCtrl;
  late TextEditingController _categoryCtrl;
  late TextEditingController _quantityCtrl;
  late TextEditingController _unitCtrl;
  late TextEditingController _unitPriceCtrl;
  late TextEditingController _minStockCtrl;
  late TextEditingController _supplierCtrl;
  late TextEditingController _notesCtrl;

  bool get isEditing => widget.item != null;

  @override
  void initState() {
    super.initState();
    final i = widget.item;
    _nameCtrl = TextEditingController(text: i?.name ?? '');
    _categoryCtrl = TextEditingController(text: i?.category ?? 'general');
    _quantityCtrl =
        TextEditingController(text: i?.quantity.toString() ?? '0');
    _unitCtrl = TextEditingController(text: i?.unit ?? 'unidad');
    _unitPriceCtrl =
        TextEditingController(text: i?.unitPrice.toString() ?? '0');
    _minStockCtrl =
        TextEditingController(text: i?.minStockLevel.toString() ?? '0');
    _supplierCtrl = TextEditingController(text: i?.supplier ?? '');
    _notesCtrl = TextEditingController(text: i?.notes ?? '');
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _categoryCtrl.dispose();
    _quantityCtrl.dispose();
    _unitCtrl.dispose();
    _unitPriceCtrl.dispose();
    _minStockCtrl.dispose();
    _supplierCtrl.dispose();
    _notesCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(isEditing ? 'Editar item' : 'Nuevo item'),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: EdgeInsets.all(16),
          children: [
            TextFormField(
              controller: _nameCtrl,
              decoration:
                  InputDecoration(labelText: 'Nombre del producto *'),
              validator: (v) =>
                  v?.isEmpty == true ? 'Requerido' : null,
            ),
            SizedBox(height: 12),
            TextFormField(
              controller: _categoryCtrl,
              decoration: InputDecoration(labelText: 'Categoría'),
            ),
            SizedBox(height: 12),
            TextFormField(
              controller: _quantityCtrl,
              decoration: InputDecoration(labelText: 'Cantidad *'),
              keyboardType: TextInputType.number,
              validator: (v) =>
                  v?.isEmpty == true ? 'Requerido' : null,
            ),
            SizedBox(height: 12),
            TextFormField(
              controller: _unitCtrl,
              decoration: InputDecoration(labelText: 'Unidad'),
            ),
            SizedBox(height: 12),
            TextFormField(
              controller: _unitPriceCtrl,
              decoration: InputDecoration(
                labelText: 'Precio unitario',
                prefixText: 'USD ',
              ),
              keyboardType: TextInputType.number,
            ),
            SizedBox(height: 12),
            TextFormField(
              controller: _minStockCtrl,
              decoration: InputDecoration(
                labelText: 'Stock mínimo',
                helperText: 'Recibirás alerta cuando el stock baje de este nivel',
              ),
              keyboardType: TextInputType.number,
            ),
            SizedBox(height: 12),
            TextFormField(
              controller: _supplierCtrl,
              decoration: InputDecoration(labelText: 'Proveedor'),
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
                  Text(isEditing ? 'Guardar cambios' : 'Agregar item'),
            ),
          ],
        ),
      ),
    );
  }

  void _save() {
    if (!_formKey.currentState!.validate()) return;

    final item = InventoryItem(
      id: widget.item?.id,
      name: _nameCtrl.text,
      category: _categoryCtrl.text,
      quantity: int.tryParse(_quantityCtrl.text) ?? 0,
      unit: _unitCtrl.text,
      unitPrice: double.tryParse(_unitPriceCtrl.text) ?? 0,
      minStockLevel: int.tryParse(_minStockCtrl.text) ?? 0,
      supplier: _supplierCtrl.text,
      notes: _notesCtrl.text,
    );

    final provider = context.read<AppProvider>();
    if (isEditing) {
      provider.updateInventoryItem(item);
    } else {
      provider.addInventoryItem(item);
    }
    Navigator.pop(context);
  }
}
