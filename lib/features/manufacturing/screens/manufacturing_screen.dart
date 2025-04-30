import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:smartfab_app/features/auth/providers/auth_provider.dart';
import 'package:smartfab_app/features/manufacturing/models/process_model.dart';
import 'package:smartfab_app/features/manufacturing/providers/manufacturing_provider.dart';
import 'package:smartfab_app/routes.dart';

class ManufacturingScreen extends StatefulWidget {
  const ManufacturingScreen({Key? key}) : super(key: key);

  @override
  State<ManufacturingScreen> createState() => _ManufacturingScreenState();
}

class _ManufacturingScreenState extends State<ManufacturingScreen> {
  String _searchQuery = '';
  
  @override
  Widget build(BuildContext context) {
    final manufacturingProvider = Provider.of<ManufacturingProvider>(context);
    final authProvider = Provider.of<AuthProvider>(context);
    final isAdmin = authProvider.isAdmin;
    
    // Filter processes based on search query
    final filteredProcesses = manufacturingProvider.processes
        .where((process) => 
            process.name.toLowerCase().contains(_searchQuery.toLowerCase()) ||
            process.description.toLowerCase().contains(_searchQuery.toLowerCase()))
        .toList();
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('Manufacturing'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => manufacturingProvider.loadProcesses(),
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
                hintText: 'Search processes...',
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
          
          // Quick Actions
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () {
                      Navigator.of(context).pushNamed(AppRoutes.scanMaterial);
                    },
                    icon: const Icon(Icons.qr_code_scanner),
                    label: const Text('Scan Material'),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () {
                      Navigator.of(context).pushNamed(AppRoutes.logConsumption);
                    },
                    icon: const Icon(Icons.add_shopping_cart),
                    label: const Text('Log Consumption'),
                  ),
                ),
              ],
            ),
          ),
          
          const SizedBox(height: 16),
          
          // Processes List
          Expanded(
            child: manufacturingProvider.isLoading
                ? const Center(child: CircularProgressIndicator())
                : filteredProcesses.isEmpty
                    ? Center(
                        child: Text(
                          _searchQuery.isEmpty
                              ? 'No processes found. Add some processes!'
                              : 'No processes match your search.',
                          style: TextStyle(color: Colors.grey[600]),
                        ),
                      )
                    : ListView.builder(
                        itemCount: filteredProcesses.length,
                        padding: const EdgeInsets.all(16),
                        itemBuilder: (context, index) {
                          final process = filteredProcesses[index];
                          return _buildProcessCard(context, process, isAdmin);
                        },
                      ),
          ),
        ],
      ),
      floatingActionButton: isAdmin
          ? FloatingActionButton(
              onPressed: () {
                _showAddProcessDialog(context);
              },
              child: const Icon(Icons.add),
            )
          : null,
    );
  }
  
  Widget _buildProcessCard(BuildContext context, ProcessModel process, bool isAdmin) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    process.name,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                if (isAdmin)
                  Row(
                    children: [
                      IconButton(
                        icon: const Icon(Icons.edit),
                        onPressed: () {
                          _showAddProcessDialog(context, process: process);
                        },
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete),
                        onPressed: () {
                          _showDeleteProcessDialog(context, process);
                        },
                      ),
                    ],
                  ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              process.description,
              style: TextStyle(color: Colors.grey[600]),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Cost per Hour: \$${process.costPerHour.toStringAsFixed(2)}',
                  style: const TextStyle(fontWeight: FontWeight.w500),
                ),
                Text(
                  'Setup Cost: \$${process.setupCost.toStringAsFixed(2)}',
                  style: const TextStyle(fontWeight: FontWeight.w500),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
  
  void _showAddProcessDialog(BuildContext context, {ProcessModel? process}) {
    final _formKey = GlobalKey<FormState>();
    final _nameController = TextEditingController(text: process?.name ?? '');
    final _descriptionController = TextEditingController(text: process?.description ?? '');
    final _costPerHourController = TextEditingController(text: process?.costPerHour.toString() ?? '');
    final _setupCostController = TextEditingController(text: process?.setupCost.toString() ?? '');
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(process == null ? 'Add Process' : 'Edit Process'),
        content: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  controller: _nameController,
                  decoration: const InputDecoration(
                    labelText: 'Process Name',
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter a name';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _descriptionController,
                  decoration: const InputDecoration(
                    labelText: 'Description',
                  ),
                  maxLines: 3,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter a description';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _costPerHourController,
                  decoration: const InputDecoration(
                    labelText: 'Cost per Hour (\$)',
                  ),
                  keyboardType: TextInputType.number,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter cost per hour';
                    }
                    if (double.tryParse(value) == null || double.parse(value) <= 0) {
                      return 'Please enter a valid positive number';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _setupCostController,
                  decoration: const InputDecoration(
                    labelText: 'Setup Cost (\$)',
                  ),
                  keyboardType: TextInputType.number,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter setup cost';
                    }
                    if (double.tryParse(value) == null || double.parse(value) < 0) {
                      return 'Please enter a valid non-negative number';
                    }
                    return null;
                  },
                ),
              ],
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              if (_formKey.currentState!.validate()) {
                final manufacturingProvider = Provider.of<ManufacturingProvider>(context, listen: false);
                
                final newProcess = ProcessModel(
                  id: process?.id,
                  name: _nameController.text.trim(),
                  description: _descriptionController.text.trim(),
                  costPerHour: double.parse(_costPerHourController.text),
                  setupCost: double.parse(_setupCostController.text),
                );
                
                if (process == null) {
                  await manufacturingProvider.addProcess(newProcess);
                } else {
                  await manufacturingProvider.updateProcess(newProcess);
                }
                
                if (context.mounted) {
                  Navigator.of(context).pop();
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(process == null ? 'Process added' : 'Process updated'),
                      backgroundColor: Colors.green,
                    ),
                  );
                }
              }
            },
            child: Text(process == null ? 'Add' : 'Update'),
          ),
        ],
      ),
    );
  }
  
  void _showDeleteProcessDialog(BuildContext context, ProcessModel process) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Process'),
        content: Text('Are you sure you want to delete "${process.name}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              final manufacturingProvider = Provider.of<ManufacturingProvider>(context, listen: false);
              await manufacturingProvider.deleteProcess(process.id);
              
              if (context.mounted) {
                Navigator.of(context).pop();
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Process deleted'),
                    backgroundColor: Colors.green,
                  ),
                );
              }
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }
}
