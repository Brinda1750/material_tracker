import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:smartfab_app/features/auth/providers/auth_provider.dart';
import 'package:smartfab_app/features/inventory/models/material_model.dart';
import 'package:smartfab_app/features/inventory/providers/inventory_provider.dart';
import 'package:smartfab_app/routes.dart';

class InventoryScreen extends StatefulWidget {
  const InventoryScreen({Key? key}) : super(key: key);

  @override
  State<InventoryScreen> createState() => _InventoryScreenState();
}

class _InventoryScreenState extends State<InventoryScreen> {
  String _searchQuery = '';
  
  @override
  Widget build(BuildContext context) {
    final inventoryProvider = Provider.of<InventoryProvider>(context);
    final authProvider = Provider.of<AuthProvider>(context);
    final isAdmin = authProvider.isAdmin;
    
    // Filter materials based on search query
    final filteredMaterials = inventoryProvider.materials
        .where((material) => 
            material.name.toLowerCase().contains(_searchQuery.toLowerCase()) ||
            material.description.toLowerCase().contains(_searchQuery.toLowerCase()))
        .toList();
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('Inventory'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => inventoryProvider.loadMaterials(),
          ),
        ],
      ),
      body: Column(
        children: [
          // Search Bar
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              decoration: InputDecoration(
                hintText: 'Search materials...',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                contentPadding: const EdgeInsets.symmetric(vertical: 0),
              ),
              onChanged: (value) {
                setState(() {
                  _searchQuery = value;
                });
              },
            ),
          ),
          
          // Materials List
          Expanded(
            child: inventoryProvider.isLoading
                ? const Center(child: CircularProgressIndicator())
                : filteredMaterials.isEmpty
                    ? Center(
                        child: Text(
                          _searchQuery.isEmpty
                              ? 'No materials found. Add some materials!'
                              : 'No materials match your search.',
                          style: TextStyle(color: Colors.grey[600]),
                        ),
                      )
                    : ListView.builder(
                        itemCount: filteredMaterials.length,
                        padding: const EdgeInsets.all(16),
                        itemBuilder: (context, index) {
                          final material = filteredMaterials[index];
                          return _buildMaterialCard(context, material, isAdmin);
                        },
                      ),
          ),
        ],
      ),
      floatingActionButton: isAdmin
          ? FloatingActionButton(
              onPressed: () {
                Navigator.of(context).pushNamed(AppRoutes.addMaterial);
              },
              child: const Icon(Icons.add),
            )
          : null,
    );
  }
  
  Widget _buildMaterialCard(BuildContext context, MaterialModel material, bool isAdmin) {
    final stockPercentage = material.lowStockThreshold > 0
        ? (material.stockQuantity / material.lowStockThreshold)
        : 1.0;
    
    Color stockColor;
    if (stockPercentage <= 1.0) {
      stockColor = Colors.red;
    } else if (stockPercentage <= 2.0) {
      stockColor = Colors.orange;
    } else {
      stockColor = Colors.green;
    }
    
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: InkWell(
        onTap: () {
          Navigator.of(context).pushNamed(
            AppRoutes.materialDetails,
            arguments: {'materialId': material.id},
          );
        },
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      material.name,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  if (isAdmin)
                    IconButton(
                      icon: const Icon(Icons.edit),
                      onPressed: () {
                        Navigator.of(context).pushNamed(
                          AppRoutes.addMaterial,
                          arguments: {'material': material},
                        );
                      },
                    ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                material.description,
                style: TextStyle(color: Colors.grey[600]),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Unit Cost: \$${material.unitCost.toStringAsFixed(2)} / ${material.unitType}',
                    style: const TextStyle(fontWeight: FontWeight.w500),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: stockColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(4),
                      border: Border.all(color: stockColor),
                    ),
                    child: Text(
                      'Stock: ${material.stockQuantity} ${material.unitType}',
                      style: TextStyle(
                        color: stockColor,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
