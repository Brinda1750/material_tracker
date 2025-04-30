import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:smartfab_app/core/utils/date_formatter.dart';
import 'package:smartfab_app/features/auth/providers/auth_provider.dart';
import 'package:smartfab_app/features/inventory/models/material_model.dart';
import 'package:smartfab_app/features/inventory/providers/inventory_provider.dart';
import 'package:smartfab_app/features/manufacturing/models/consumption_log_model.dart';
import 'package:smartfab_app/features/manufacturing/providers/manufacturing_provider.dart';
import 'package:smartfab_app/routes.dart';

class MaterialDetailsScreen extends StatefulWidget {
  final String materialId;
  
  const MaterialDetailsScreen({
    Key? key,
    required this.materialId,
  }) : super(key: key);

  @override
  State<MaterialDetailsScreen> createState() => _MaterialDetailsScreenState();
}

class _MaterialDetailsScreenState extends State<MaterialDetailsScreen> {
  MaterialModel? _material;
  List<ConsumptionLogModel> _consumptionLogs = [];
  bool _isLoading = true;
  String? _errorMessage;
  
  @override
  void initState() {
    super.initState();
    _loadData();
  }
  
  Future<void> _loadData() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });
    
    try {
      final inventoryProvider = Provider.of<InventoryProvider>(context, listen: false);
      final manufacturingProvider = Provider.of<ManufacturingProvider>(context, listen: false);
      
      _material = await inventoryProvider.getMaterialById(widget.materialId);
      
      if (_material != null) {
        _consumptionLogs = await manufacturingProvider.getConsumptionLogsByMaterialId(widget.materialId);
      } else {
        _errorMessage = 'Material not found';
      }
    } catch (e) {
      _errorMessage = 'Error loading material details: ${e.toString()}';
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }
  
  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final isAdmin = authProvider.isAdmin;
    
    return Scaffold(
      appBar: AppBar(
        title: Text(_material?.name ?? 'Material Details'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadData,
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _errorMessage != null
              ? Center(
                  child: Text(
                    _errorMessage!,
                    style: const TextStyle(color: Colors.red),
                  ),
                )
              : _material == null
                  ? const Center(child: Text('Material not found'))
                  : SingleChildScrollView(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Material Info Card
                          Card(
                            child: Padding(
                              padding: const EdgeInsets.all(16.0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    _material!.name,
                                    style: const TextStyle(
                                      fontSize: 24,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    _material!.description,
                                    style: TextStyle(
                                      color: Colors.grey[700],
                                      fontSize: 16,
                                    ),
                                  ),
                                  const SizedBox(height: 16),
                                  _buildInfoRow('Unit Cost', '\$${_material!.unitCost.toStringAsFixed(2)} / ${_material!.unitType}'),
                                  _buildInfoRow('Current Stock', '${_material!.stockQuantity} ${_material!.unitType}'),
                                  _buildInfoRow('Low Stock Threshold', '${_material!.lowStockThreshold} ${_material!.unitType}'),
                                  _buildInfoRow('Stock Status', _getStockStatusText()),
                                  _buildInfoRow('Last Updated', DateFormatter.formatDateTimeForDisplay(_material!.updatedAt)),
                                ],
                              ),
                            ),
                          ),
                          
                          const SizedBox(height: 24),
                          
                          // Action Buttons
                          Row(
                            children: [
                              Expanded(
                                child: ElevatedButton.icon(
                                  onPressed: () {
                                    Navigator.of(context).pushNamed(
                                      AppRoutes.scanMaterial,
                                      arguments: {'materialId': _material!.id},
                                    );
                                  },
                                  icon: const Icon(Icons.qr_code_scanner),
                                  label: const Text('Scan QR Code'),
                                ),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: ElevatedButton.icon(
                                  onPressed: () {
                                    Navigator.of(context).pushNamed(
                                      AppRoutes.logConsumption,
                                      arguments: {'materialId': _material!.id},
                                    );
                                  },
                                  icon: const Icon(Icons.add_shopping_cart),
                                  label: const Text('Log Consumption'),
                                ),
                              ),
                            ],
                          ),
                          
                          if (isAdmin) ...[
                            const SizedBox(height: 16),
                            Row(
                              children: [
                                Expanded(
                                  child: OutlinedButton.icon(
                                    onPressed: () {
                                      Navigator.of(context).pushNamed(
                                        AppRoutes.addMaterial,
                                        arguments: {'material': _material},
                                      );
                                    },
                                    icon: const Icon(Icons.edit),
                                    label: const Text('Edit Material'),
                                  ),
                                ),
                              ],
                            ),
                          ],
                          
                          const SizedBox(height: 24),
                          
                          // Consumption History
                          const Text(
                            'Consumption History',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 8),
                          
                          _consumptionLogs.isEmpty
                              ? Card(
                                  child: Padding(
                                    padding: const EdgeInsets.all(16.0),
                                    child: Center(
                                      child: Text(
                                        'No consumption logs found',
                                        style: TextStyle(color: Colors.grey[600]),
                                      ),
                                    ),
                                  ),
                                )
                              : ListView.builder(
                                  shrinkWrap: true,
                                  physics: const NeverScrollableScrollPhysics(),
                                  itemCount: _consumptionLogs.length,
                                  itemBuilder: (context, index) {
                                    final log = _consumptionLogs[index];
                                    return Card(
                                      margin: const EdgeInsets.only(bottom: 8),
                                      child: ListTile(
                                        title: Text('${log.quantity} ${_material!.unitType} used'),
                                        subtitle: Text(
                                          'Product: ${log.productName}\nCost: \$${(log.quantity * _material!.unitCost).toStringAsFixed(2)}',
                                        ),
                                        trailing: Text(
                                          DateFormatter.formatDateTimeForDisplay(log.timestamp),
                                          style: TextStyle(color: Colors.grey[600]),
                                        ),
                                      ),
                                    );
                                  },
                                ),
                        ],
                      ),
                    ),
    );
  }
  
  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontWeight: FontWeight.w500,
            ),
          ),
          Text(value),
        ],
      ),
    );
  }
  
  String _getStockStatusText() {
    if (_material == null) return '';
    
    final stockPercentage = _material!.lowStockThreshold > 0
        ? (_material!.stockQuantity / _material!.lowStockThreshold)
        : 1.0;
    
    if (stockPercentage <= 1.0) {
      return 'Low Stock';
    } else if (stockPercentage <= 2.0) {
      return 'Medium Stock';
    } else {
      return 'Good Stock';
    }
  }
}
