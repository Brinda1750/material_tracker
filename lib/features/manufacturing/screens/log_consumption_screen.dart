import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:smartfab_app/core/utils/validators.dart';
import 'package:smartfab_app/features/auth/providers/auth_provider.dart';
import 'package:smartfab_app/features/inventory/models/material_model.dart';
import 'package:smartfab_app/features/inventory/providers/inventory_provider.dart';
import 'package:smartfab_app/features/manufacturing/models/consumption_log_model.dart';
import 'package:smartfab_app/features/manufacturing/providers/manufacturing_provider.dart';

class LogConsumptionScreen extends StatefulWidget {
  final String? materialId;
  
  const LogConsumptionScreen({
    Key? key,
    this.materialId,
  }) : super(key: key);

  @override
  State<LogConsumptionScreen> createState() => _LogConsumptionScreenState();
}

class _LogConsumptionScreenState extends State<LogConsumptionScreen> {
  final _formKey = GlobalKey<FormState>();
  
  late TextEditingController _productNameController;
  late TextEditingController _quantityController;
  
  MaterialModel? _selectedMaterial;
  bool _isLoading = false;
  String? _errorMessage;
  List<MaterialModel> _materials = [];
  
  @override
  void initState() {
    super.initState();
    _productNameController = TextEditingController();
    _quantityController = TextEditingController();
    
    _loadData();
  }
  
  Future<void> _loadData() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });
    
    try {
      final inventoryProvider = Provider.of<InventoryProvider>(context, listen: false);
      _materials = inventoryProvider.materials;
      
      // If materialId is provided, select that material
      if (widget.materialId != null) {
        _selectedMaterial = await inventoryProvider.getMaterialById(widget.materialId!);
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Error loading materials: ${e.toString()}';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }
  
  @override
  void dispose() {
    _productNameController.dispose();
    _quantityController.dispose();
    super.dispose();
  }
  
  Future<void> _logConsumption() async {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedMaterial == null) {
      setState(() {
        _errorMessage = 'Please select a material';
      });
      return;
    }
    
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });
    
    try {
      final quantity = double.parse(_quantityController.text);
      
      // Check if there's enough stock
      if (quantity > _selectedMaterial!.stockQuantity) {
        setState(() {
          _errorMessage = 'Not enough stock. Available: ${_selectedMaterial!.stockQuantity} ${_selectedMaterial!.unitType}';
        });
        return;
      }
      
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final manufacturingProvider = Provider.of<ManufacturingProvider>(context, listen: false);
      
      final log = ConsumptionLogModel(
        materialId: _selectedMaterial!.id,
        productName: _productNameController.text.trim(),
        quantity: quantity,
        userId: authProvider.currentUser!.id,
      );
      
      await manufacturingProvider.logConsumption(log);
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Consumption logged successfully'),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.of(context).pop();
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Error logging consumption: ${e.toString()}';
      });
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
        title: const Text('Log Consumption'),
      ),
      body: _isLoading && _materials.isEmpty
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Error Message
                    if (_errorMessage != null)
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.red[50],
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: Colors.red[300]!),
                        ),
                        child: Text(
                          _errorMessage!,
                          style: TextStyle(color: Colors.red[700]),
                        ),
                      ),
                    
                    if (_errorMessage != null) const SizedBox(height: 16),
                    
                    // Material Selection
                    if (widget.materialId == null) ...[
                      const Text(
                        'Select Material',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      DropdownButtonFormField<MaterialModel>(
                        decoration: const InputDecoration(
                          labelText: 'Material',
                          hintText: 'Select a material',
                        ),
                        value: _selectedMaterial,
                        items: _materials.map((material) {
                          return DropdownMenuItem<MaterialModel>(
                            value: material,
                            child: Text(material.name),
                          );
                        }).toList(),
                        onChanged: (value) {
                          setState(() {
                            _selectedMaterial = value;
                          });
                        },
                        validator: (value) {
                          if (value == null) {
                            return 'Please select a material';
                          }
                          return null;
                        },
                      ),
                    ] else ...[
                      // Display selected material info
                      if (_selectedMaterial != null) ...[
                        const Text(
                          'Selected Material',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Card(
                          child: ListTile(
                            title: Text(_selectedMaterial!.name),
                            subtitle: Text(
                              'Stock: ${_selectedMaterial!.stockQuantity} ${_selectedMaterial!.unitType}',
                            ),
                            trailing: Text(
                              'Unit Cost: \$${_selectedMaterial!.unitCost.toStringAsFixed(2)}',
                            ),
                          ),
                        ),
                      ],
                    ],
                    
                    const SizedBox(height: 24),
                    
                    // Product Name Field
                    TextFormField(
                      controller: _productNameController,
                      decoration: const InputDecoration(
                        labelText: 'Product Name',
                        hintText: 'Enter product name',
                      ),
                      validator: (value) => Validators.validateRequired(value, 'Product name'),
                      enabled: !_isLoading,
                    ),
                    
                    const SizedBox(height: 16),
                    
                    // Quantity Field
                    TextFormField(
                      controller: _quantityController,
                      decoration: InputDecoration(
                        labelText: 'Quantity',
                        hintText: 'Enter quantity used',
                        suffixText: _selectedMaterial?.unitType,
                      ),
                      keyboardType: TextInputType.number,
                      validator: (value) => Validators.validatePositiveNumber(value, 'Quantity'),
                      enabled: !_isLoading,
                    ),
                    
                    const SizedBox(height: 24),
                    
                    // Log Button
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: _isLoading ? null : _logConsumption,
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
                            : const Text('Log Consumption'),
                      ),
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}
