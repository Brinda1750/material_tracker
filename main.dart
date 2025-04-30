import 'package:flutter/material.dart';
import 'admin_page.dart';
import 'operator_page.dart';

void main() {
  runApp(MaterialApp(
    debugShowCheckedModeBanner: false,
    title: 'Material Tracker',
    theme: ThemeData(primarySwatch: Colors.teal),
    home: LoginPage(),
  ));
}

class LoginPage extends StatelessWidget {
  final TextEditingController roleController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Login')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TextField(
              controller: roleController,
              decoration: InputDecoration(
                labelText: 'Enter role (admin/operator)',
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                String role = roleController.text.trim().toLowerCase();
                if (role == 'admin') {
                  Navigator.push(context, MaterialPageRoute(builder: (_) => AdminPage()));
                } else if (role == 'operator') {
                  Navigator.push(context, MaterialPageRoute(builder: (_) => OperatorPage()));
                }
              },
              child: Text('Login'),
            ),
          ],
        ),
      ),
    );
  }
}
