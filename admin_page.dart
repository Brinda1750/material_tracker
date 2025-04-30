import 'package:flutter/material.dart';
import 'material_model.dart';

class AdminPage extends StatefulWidget {
  @override
  State<AdminPage> createState() => _AdminPageState();
}

class _AdminPageState extends State<AdminPage> {
  final nameController = TextEditingController();
  final costController = TextEditingController();
  final stockController = TextEditingController();
  final taskUserController = TextEditingController();
  final taskQtyController = TextEditingController();

  void addMaterial() {
    setState(() {
      materials.add(MaterialItem(
        name: nameController.text,
        unitCost: double.tryParse(costController.text) ?? 0,
        stock: int.tryParse(stockController.text) ?? 0,
      ));
    });
    nameController.clear();
    costController.clear();
    stockController.clear();
  }

  void assignTask() {
    tasks.add(Task(
      nameController.text,
      int.tryParse(taskQtyController.text) ?? 0,
      taskUserController.text,
    ));
    taskUserController.clear();
    taskQtyController.clear();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Admin Dashboard')),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(controller: nameController, decoration: InputDecoration(labelText: 'Material Name')),
            TextField(controller: costController, decoration: InputDecoration(labelText: 'Unit Cost')),
            TextField(controller: stockController, decoration: InputDecoration(labelText: 'Stock Quantity')),
            ElevatedButton(onPressed: addMaterial, child: Text('Add Material')),

            Divider(),
            TextField(controller: taskUserController, decoration: InputDecoration(labelText: 'Assign to Operator')),
            TextField(controller: taskQtyController, decoration: InputDecoration(labelText: 'Task Quantity')),
            ElevatedButton(onPressed: assignTask, child: Text('Assign Task')),

            Divider(),
            ListView.builder(
              shrinkWrap: true,
              itemCount: materials.length,
              itemBuilder: (_, i) {
                final m = materials[i];
                return ListTile(
                  title: Text('${m.name} - ₹${m.unitCost} x ${m.stock}'),
                  subtitle: m.stock < lowStockThreshold
                      ? Text('Low Stock', style: TextStyle(color: Colors.red))
                      : null,
                );
              },
            )
          ],
        ),
      ),
    );
  }
}
