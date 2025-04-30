import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:smartfab_app/features/auth/providers/auth_provider.dart';
import 'package:smartfab_app/features/manufacturing/providers/manufacturing_provider.dart';
import 'package:smartfab_app/routes.dart';

class OperatorDashboardScreen extends StatefulWidget {
  const OperatorDashboardScreen({Key? key}) : super(key: key);

  @override
  State<OperatorDashboardScreen> createState() => _OperatorDashboardScreenState();
}

class _OperatorDashboardScreenState extends State<OperatorDashboardScreen> {
  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final user = authProvider.currentUser;
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('Operator Dashboard'),
        actions: [
          IconButton(
            icon: const Icon(Icons.person),
            onPressed: () {
              Navigator.of(context).pushNamed(AppRoutes.profile);
            },
          ),
        ],
      ),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            DrawerHeader(
              decoration: BoxDecoration(
                color: Theme.of(context).primaryColor,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  CircleAvatar(
                    radius: 30,
                    backgroundColor: Colors.white,
                    child: Text(
                      user?.name.isNotEmpty == true ? user!.name[0].toUpperCase() : 'O',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).primaryColor,
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    user?.name ?? 'Operator',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                    ),
                  ),
                  Text(
                    user?.email ?? '',
                    style: const TextStyle(
                      color: Colors.white70,
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ),
            ListTile(
              leading: const Icon(Icons.dashboard),
              title: const Text('Dashboard'),
              onTap: () {
                Navigator.pop(context);
              },
            ),
            ListTile(
              leading: const Icon(Icons.inventory),
              title: const Text('View Inventory'),
              onTap: () {
                Navigator.pop(context);
                Navigator.of(context).pushNamed(AppRoutes.inventory);
              },
            ),
            ListTile(
              leading: const Icon(Icons.qr_code_scanner),
              title: const Text('Scan Material'),
              onTap: () {
                Navigator.pop(context);
                Navigator.of(context).pushNamed(AppRoutes.scanMaterial);
              },
            ),
            ListTile(
              leading: const Icon(Icons.add_shopping_cart),
              title: const Text('Log Consumption'),
              onTap: () {
                Navigator.pop(context);
                Navigator.of(context).pushNamed(AppRoutes.logConsumption);
              },
            ),
            const Divider(),
            ListTile(
              leading: const Icon(Icons.person),
              title: const Text('Profile'),
              onTap: () {
                Navigator.pop(context);
                Navigator.of(context).pushNamed(AppRoutes.profile);
              },
            ),
            ListTile(
              leading: const Icon(Icons.logout),
              title: const Text('Logout'),
              onTap: () async {
                await authProvider.signOut();
                if (mounted) {
                  Navigator.of(context).pushReplacementNamed(AppRoutes.login);
                }
              },
            ),
          ],
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Welcome Card
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Welcome, ${user?.name ?? 'Operator'}!',
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Use the quick actions below to scan materials and log consumption.',
                    ),
                  ],
                ),
              ),
            ),
            
            const SizedBox(height: 24),
            
            // Quick Actions
            const Text(
              'Quick Actions',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            
            // Scan Material Button
            _buildActionCard(
              icon: Icons.qr_code_scanner,
              title: 'Scan Material',
              description: 'Scan a QR code to view material details',
              onTap: () {
                Navigator.of(context).pushNamed(AppRoutes.scanMaterial);
              },
            ),
            
            const SizedBox(height: 16),
            
            // Log Consumption Button
            _buildActionCard(
              icon: Icons.add_shopping_cart,
              title: 'Log Consumption',
              description: 'Record material usage for a product',
              onTap: () {
                Navigator.of(context).pushNamed(AppRoutes.logConsumption);
              },
            ),
            
            const SizedBox(height: 16),
            
            // View Inventory Button
            _buildActionCard(
              icon: Icons.inventory_2,
              title: 'View Inventory',
              description: 'Browse all materials and their details',
              onTap: () {
                Navigator.of(context).pushNamed(AppRoutes.inventory);
              },
            ),
            
            const SizedBox(height: 24),
            
            // Recent Activity
            _buildRecentActivity(),
          ],
        ),
      ),
    );
  }
  
  Widget _buildActionCard({
    required IconData icon,
    required String title,
    required String description,
    required VoidCallback onTap,
  }) {
    return Card(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Theme.of(context).primaryColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  icon,
                  size: 32,
                  color: Theme.of(context).primaryColor,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      description,
                      style: TextStyle(
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              ),
              const Icon(Icons.arrow_forward_ios),
            ],
          ),
        ),
      ),
    );
  }
  
  Widget _buildRecentActivity() {
    final manufacturingProvider = Provider.of<ManufacturingProvider>(context);
    final authProvider = Provider.of<AuthProvider>(context);
    final userId = authProvider.currentUser?.id;
    
    // Filter logs by current user and sort by timestamp (newest first)
    final userLogs = manufacturingProvider.consumptionLogs
        .where((log) => log.userId == userId)
        .toList()
      ..sort((a, b) => b.timestamp.compareTo(a.timestamp));
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Your Recent Activity',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        userLogs.isEmpty
            ? const Card(
                child: Padding(
                  padding: EdgeInsets.all(16.0),
                  child: Center(
                    child: Text('No recent activity'),
                  ),
                ),
              )
            : ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: userLogs.length > 5 ? 5 : userLogs
