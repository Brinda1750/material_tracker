import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:smartfab_app/core/constants/app_constants.dart';
import 'package:smartfab_app/core/utils/validators.dart';
import 'package:smartfab_app/features/inventory/models/material_model.dart';
import 'package:smartfab_app/features/inventory/providers/inventory_provider.dart';

class AddMaterialScreen extends StatefulWidget {
  const AddMaterialScreen({Key? key}) : super(key: key);

  @override
  State<AddMaterialScreen> createState() => _AddMaterialScreenState();
}

class _AddMaterialScreenState extends State<AddMaterialScreen> {
  final _formKey = GlobalKey<FormState>();
  
  late TextEditingController _nameController;
  late TextEditingController _descriptionController;
  late TextEditingController _unitCostController;
  late TextEditingController _stockQuantityController;
  late TextEditingController _lowStockThresholdController;
  
  String _selectedUnitType = AppConstants.materialUnits.first;
  bool _isLoading = false;
  bool _isEditing = false;
  String? _materialId;
  
  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController();
    _descriptionController = TextEditingController();
    _unitCostController = TextEditingController();
    _stockQuantityController = TextEditingController();
    _lowStockThresholdController = TextEditingController();
    
    // We'll populate the form in didChangeDependencies if we're editing
  }
  
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    
    final args = ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;
    if (args != null && args.containsKey('material')) {
      final material = args['material'] as MaterialModel;
      _populateForm(material);
    }
  }
  
  void _populateForm(MaterialModel material) {
    if (_isEditing) return; // Avoid re-populating
    
    _isEditing = true;
    _materialId = material.id;
    
    _nameController.text = material.name;
    _descriptionController.text = material.description;
    _unitCostController.text = material.unitCost.toString();
    _stockQuantityController.text = material.stockQuantity.toString();
    _lowStockThresholdController.text = material.lowStockThreshold.toString();
    _selectedUnitType = material.unitType;
  }
  
  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    _unitCostController.dispose();
    _stockQuantityController.dispose();
    _lowStockThresholdController.dispose();
    super.dispose();
  }
  
  Future<void> _saveMaterial() async {
    if (!_formKey.currentState!.validate()) return;
    
    setState(() {
      _isLoading = true;
    });
    
    try {
      final material = MaterialModel(
        id: _materialId,
        name: _nameController.text.trim(),
        description: _descriptionController.text.trim(),
        unitCost: double.parse(_unitCostController.text),
        unitType: _selectedUnitType,
        stockQuantity: double.parse(_stockQuantityController.text),
        lowStockThreshold: double.parse(_lowStockThresholdController.text),
      );
      
      final inventoryProvider = Provider.of<InventoryProvider>(context, listen: false);
      
      if (_isEditing) {
        await inventoryProvider.updateMaterial(material);
      } else {
        await inventoryProvider.addMaterial(material);
      }
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(_isEditing ? 'Material updated' : 'Material added'),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.of(context).pop();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_isEditing ? 'Edit Material' : 'Add Material'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Name Field
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(
                  labelText: 'Material Name',
                  hintText: 'Enter material name',
                ),
                validator: (value) => Validators.validateRequired(value, 'Material name'),
                enabled: !_isLoading,
              ),
              
              const SizedBox(height: 16),
              
              // Description Field
              TextFormField(
                controller: _descriptionController,
                decoration: const InputDecoration(
                  labelText: 'Description',
                  hintText: 'Enter material description',
                ),
                maxLines: 3,
                validator: (value) => Validators.validateRequired(value, 'Description'),
                enabled: !_isLoading,
              ),
              
              const SizedBox(height: 16),
              
              // Unit Cost Field
              TextFormField(
                controller: _unitCostController,
                decoration: const InputDecoration(
                  labelText: 'Unit Cost',
                  hintText: 'Enter cost per unit',
                  prefixText: '\$ ',
                ),
                keyboardType: TextInputType.number,
                validator: (value) => Validators.validatePositiveNumber(value, 'Unit cost'),
                enabled: !_isLoading,
              ),
              
              const SizedBox(height: 16),
              
              // Unit Type Dropdown
              DropdownButtonFormField<String>(
                value: _selectedUnitType,
                decoration: const InputDecoration(
                  labelText: 'Unit Type',
                ),
                items: AppConstants.materialUnits.map((unit) {
                  return DropdownMenuItem<String>(
                    value: unit,
                    child: Text(unit),
                  );
                }).toList(),
                onChanged: _isLoading ? null : (value) {
                  setState(() {
                    _selectedUnitType = value!;
                  });
                },
              ),
              
              const SizedBox(height: 16),
              
              // Stock Quantity Field
              TextFormField(
                controller: _stockQuantityController,
                decoration: InputDecoration(
                  labelText: 'Stock Quantity',
                  hintText: 'Enter current stock',
                  suffixText: _selectedUnitType,
                ),
                keyboardType: TextInputType.number,
                validator: (value) => Validators.validatePositiveNumber(value, 'Stock quantity'),
                enabled: !_isLoading,
              ),
              
              const SizedBox(height: 16),
              
              // Low Stock Threshold Field
              TextFormField(
                controller: _lowStockThresholdController,
                decoration: InputDecoration(
                  labelText: 'Low Stock Threshold',
                  hintText: 'Enter low stock alert threshold',
                  suffixText: _selectedUnitType,
                ),
                keyboardType: TextInputType.number,
                validator: (value) => Validators.validatePositiveNumber(value, 'Low stock threshold'),
                enabled: !_isLoading,
              ),
              
              const SizedBox(height: 24),
              
              // Save Button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _saveMaterial,
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                  child: _isLoading
                      ? const SizedBox(
                          height: 24,
                          width: 24,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : Text(_isEditing ? 'Update Material' : 'Add Material'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
