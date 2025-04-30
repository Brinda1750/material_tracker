import 'package:flutter/material.dart';
import 'material_model.dart';
import 'log_page.dart';

class OperatorPage extends StatefulWidget {
  @override
  State<OperatorPage> createState() => _OperatorPageState();
}

class _OperatorPageState extends State<OperatorPage> {
  int selectedIndex = 0;
  final quantityController = TextEditingController();
  final processingCostController = TextEditingController();
  final marginController = TextEditingController();
  String result = '';
  String operatorId = 'operator1';

  void calculate() {
    final material = materials[selectedIndex];
    final qty = int.tryParse(quantityController.text) ?? 0;
    final procCost = double.tryParse(processingCostController.text) ?? 0;
    final margin = double.tryParse(marginController.text) ?? 0;

    if (qty > material.stock) {
      setState(() => result = 'Not enough stock!');
      return;
    }

    double rawCost = qty * material.unitCost;
    double mfgCost = rawCost + procCost;
    double finalPrice = mfgCost + margin;

    setState(() {
      material.stock -= qty;
      usageLogs.add(UsageLog(material.name, qty, rawCost, DateTime.now()));
      result = 'Raw Cost: ₹${rawCost.toStringAsFixed(2)}\n'
               'Mfg Cost: ₹${mfgCost.toStringAsFixed(2)}\n'
               'Selling Price: ₹${finalPrice.toStringAsFixed(2)}\n'
               'Remaining Stock: ${material.stock}';
    });
  }

  @override
  Widget build(BuildContext context) {
    final myTasks = tasks.where((task) => task.assignedTo == operatorId).toList();

    return Scaffold(
      appBar: AppBar(title: Text('Operator Dashboard')),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16),
        child: Column(
          children: [
            DropdownButton<int>(
              value: selectedIndex,
              items: List.generate(materials.length, (i) {
                return DropdownMenuItem(value: i, child: Text(materials[i].name));
              }),
              onChanged: (i) => setState(() => selectedIndex = i!),
            ),
            TextField(controller: quantityController, decoration: InputDecoration(labelText: 'Quantity Used')),
            TextField(controller: processingCostController, decoration: InputDecoration(labelText: 'Processing Cost')),
            TextField(controller: marginController, decoration: InputDecoration(labelText: 'Desired Margin')),
            ElevatedButton(onPressed: calculate, child: Text('Calculate')),
            SizedBox(height: 10),
            Text(result, style: TextStyle(fontSize: 16)),
            ElevatedButton(
              onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => LogPage())),
              child: Text('View Usage Logs'),
            ),
            Divider(),
            Text('Assigned Tasks:', style: TextStyle(fontWeight: FontWeight.bold)),
            ...myTasks.map((task) => ListTile(
              title: Text('${task.material} - Qty: ${task.quantity}'),
            )),
          ],
        ),
      ),
    );
  }
}
