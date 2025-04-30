import 'package:flutter/material.dart';
import 'material_model.dart';

class LogPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Usage Logs")),
      body: ListView.builder(
        itemCount: usageLogs.length,
        itemBuilder: (_, i) {
          final log = usageLogs[i];
          return ListTile(
            title: Text('${log.materialName} - Qty: ${log.quantity}'),
            subtitle: Text('Cost: ₹${log.totalCost} on ${log.date.toLocal()}'),
          );
        },
      ),
    );
  }
}
