import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:smartfab_app/features/auth/providers/auth_provider.dart';
import 'package:smartfab_app/features/inventory/models/material_model.dart';
import 'package:smartfab_app/features/inventory/providers/inventory_provider.dart';
import 'package:smartfab_app/features/manufacturing/providers/manufacturing_provider.dart';
import 'package:smartfab_app/routes.dart';

class AdminDashboardScreen extends StatefulWidget {
  const AdminDashboardScreen({Key? key}) : super(key: key);

  @override
  State<AdminDashboardScreen> createState() => _AdminDashboardScreenState();
}

class _AdminDashboardScreenState extends State<AdminDashboardScreen> {
  int _selectedIndex = 0;
  
  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final user = authProvider.currentUser;
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('Admin Dashboard'),
        actions: [
          IconButton(
            icon: const Icon(Icons.person),
            onPressed: () {
              Navigator.of(context).pushNamed(AppRoutes.profile);
            },
          ),
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () {
              Navigator.of(context).pushNamed(AppRoutes.settings);
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
                      user?.name.isNotEmpty == true ? user!.name[0].toUpperCase() : 'A',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).primaryColor,
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    user?.name ?? 'Admin',
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
              selected: _selectedIndex == 0,
              onTap: () {
                setState(() {
                  _selectedIndex = 0;
                });
                Navigator.pop(context);
              },
            ),
            ListTile(
              leading: const Icon(Icons.inventory),
              title: const Text('Inventory'),
              onTap: () {
                Navigator.pop(context);
                Navigator.of(context).pushNamed(AppRoutes.inventory);
              },
            ),
            ListTile(
              leading: const Icon(Icons.precision_manufacturing),
              title: const Text('Manufacturing'),
              onTap: () {
                Navigator.pop(context);
                Navigator.of(context).pushNamed(AppRoutes.manufacturing);
              },
            ),
            ListTile(
              leading: const Icon(Icons.bar_chart),
              title: const Text('Reports'),
              onTap: () {
                Navigator.pop(context);
                Navigator.of(context).pushNamed(AppRoutes.reports);
              },
            ),
            ListTile(
              leading: const Icon(Icons.people),
              title: const Text('Users'),
              onTap: () {
                Navigator.pop(context);
                Navigator.of(context).pushNamed(AppRoutes.users);
              },
            ),
            const Divider(),
            ListTile(
              leading: const Icon(Icons.settings),
              title: const Text('Settings'),
              onTap: () {
                Navigator.pop(context);
                Navigator.of(context).pushNamed(AppRoutes.settings);
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
      body: _buildBody(),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: (index) {
          setState(() {
            _selectedIndex = index;
          });
        },
        items: const [
          BottomNavigationBar.item(
            icon: Icon(Icons.dashboard),
            label: 'Overview',
          ),
          BottomNavigationBar.item(
            icon: Icon(Icons.warning),
            label: 'Alerts',
          ),
          BottomNavigationBar.item(
            icon: Icon(Icons.history),
            label: 'Recent',
          ),
        ],
      ),
    );
  }
  
  Widget _buildBody() {
    switch (_selectedIndex) {
      case 0:
        return _buildOverviewTab();
      case 1:
        return _buildAlertsTab();
      case 2:
        return _buildRecentTab();
      default:
        return _buildOverviewTab();
    }
  }
  
  Widget _buildOverviewTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Stats Cards
          _buildStatsCards(),
          
          const SizedBox(height: 24),
          
          // Low Stock Materials
          _buildLowStockMaterials(),
          
          const SizedBox(height: 24),
          
          // Quick Actions
          _buildQuickActions(),
        ],
      ),
    );
  }
  
  Widget _buildStatsCards() {
    final inventoryProvider = Provider.of<InventoryProvider>(context);
    final manufacturingProvider = Provider.of<ManufacturingProvider>(context);
    
    final totalMaterials = inventoryProvider.materials.length;
    final lowStockCount = inventoryProvider.getLowStockMaterials().length;
    final totalConsumptionLogs = manufacturingProvider.consumptionLogs.length;
    
    return GridView.count(
      crossAxisCount: 2,
      crossAxisSpacing: 16,
      mainAxisSpacing: 16,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      children: [
        _buildStatCard(
          title: 'Materials',
          value: totalMaterials.toString(),
          icon: Icons.inventory_2,
          color: Colors.blue,
        ),
        _buildStatCard(
          title: 'Low Stock',
          value: lowStockCount.toString(),
          icon: Icons.warning,
          color: Colors.orange,
        ),
        _buildStatCard(
          title: 'Consumption Logs',
          value: totalConsumptionLogs.toString(),
          icon: Icons.history,
          color: Colors.green,
        ),
        _buildStatCard(
          title: 'Processes',
          value: manufacturingProvider.processes.length.toString(),
          icon: Icons.precision_manufacturing,
          color: Colors.purple,
        ),
      ],
    );
  }
  
  Widget _buildStatCard({
    required String title,
    required String value,
    required IconData icon,
    required Color color,
  }) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 40,
              color: color,
            ),
            const SizedBox(height: 8),
            Text(
              value,
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              title,
              style: TextStyle(
                color: Colors.grey[600],
                fontSize: 14,
              ),
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildLowStockMaterials() {
    final inventoryProvider = Provider.of<InventoryProvider>(context);
    final lowStockMaterials = inventoryProvider.getLowStockMaterials();
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Low Stock Materials',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pushNamed(AppRoutes.inventory);
              },
              child: const Text('View All'),
            ),
          ],
        ),
        const SizedBox(height: 8),
        lowStockMaterials.isEmpty
            ? const Card(
                child: Padding(
                  padding: EdgeInsets.all(16.0),
                  child: Center(
                    child: Text('No low stock materials'),
                  ),
                ),
              )
            : ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: lowStockMaterials.length > 3 ? 3 : lowStockMaterials.length,
                itemBuilder: (context, index) {
                  return _buildLowStockItem(lowStockMaterials[index]);
                },
              ),
      ],
    );
  }
  
  Widget _buildLowStockItem(MaterialModel material) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        title: Text(material.name),
        subtitle: Text('${material.stockQuantity} ${material.unitType} remaining'),
        trailing: ElevatedButton(
          onPressed: () {
            Navigator.of(context).pushNamed(
              AppRoutes.materialDetails,
              arguments: {'materialId': material.id},
            );
          },
          child: const Text('View'),
        ),
        onTap: () {
          Navigator.of(context).pushNamed(
            AppRoutes.materialDetails,
            arguments: {'materialId': material.id},
          );
        },
      ),
    );
  }
  
  Widget _buildQuickActions() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Quick Actions',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: _buildActionButton(
                icon: Icons.add,
                label: 'Add Material',
                onPressed: () {
                  Navigator.of(context).pushNamed(AppRoutes.addMaterial);
                },
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: _buildActionButton(
                icon: Icons.qr_code_scanner,
                label: 'Scan Material',
                onPressed: () {
                  Navigator.of(context).pushNamed(AppRoutes.scanMaterial);
                },
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: _buildActionButton(
                icon: Icons.add_shopping_cart,
                label: 'Log Consumption',
                onPressed: () {
                  Navigator.of(context).pushNamed(AppRoutes.logConsumption);
                },
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: _buildActionButton(
                icon: Icons.bar_chart,
                label: 'View Reports',
                onPressed: () {
                  Navigator.of(context).pushNamed(AppRoutes.reports);
                },
              ),
            ),
          ],
        ),
      ],
    );
  }
  
  Widget _buildActionButton({
    required IconData icon,
    required String label,
    required VoidCallback onPressed,
  }) {
    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        padding: const EdgeInsets.symmetric(vertical: 16),
      ),
      child: Column(
        children: [
          Icon(icon),
          const SizedBox(height: 8),
          Text(label),
        ],
      ),
    );
  }
  
  Widget _buildAlertsTab() {
    final inventoryProvider = Provider.of<InventoryProvider>(context);
    final lowStockMaterials = inventoryProvider.getLowStockMaterials();
    
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Alerts',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          Expanded(
            child: lowStockMaterials.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.check_circle,
                          size: 64,
                          color: Colors.green[300],
                        ),
                        const SizedBox(height: 16),
                        const Text(
                          'No alerts at this time',
                          style: TextStyle(fontSize: 18),
                        ),
                      ],
                    ),
                  )
                : ListView.builder(
                    itemCount: lowStockMaterials.length,
                    itemBuilder: (context, index) {
                      final material = lowStockMaterials[index];
                      return Card(
                        margin: const EdgeInsets.only(bottom: 8),
                        child: ListTile(
                          leading: const Icon(
                            Icons.warning,
                            color: Colors.orange,
                          ),
                          title: Text(material.name),
                          subtitle: Text(
                            'Low stock: ${material.stockQuantity} ${material.unitType} remaining',
                          ),
                          trailing: ElevatedButton(
                            onPressed: () {
                              Navigator.of(context).pushNamed(
                                AppRoutes.materialDetails,
                                arguments: {'materialId': material.id},
                              );
                            },
                            child: const Text('View'),
                          ),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildRecentTab() {
    final manufacturingProvider = Provider.of<ManufacturingProvider>(context);
    final recentLogs = manufacturingProvider.consumptionLogs;
    
    // Sort logs by timestamp (newest first)
    recentLogs.sort((a, b) => b.timestamp.compareTo(a.timestamp));
    
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Recent Activity',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          Expanded(
            child: recentLogs.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.history,
                          size: 64,
                          color: Colors.grey[400],
                        ),
                        const SizedBox(height: 16),
                        const Text(
                          'No recent activity',
                          style: TextStyle(fontSize: 18),
                        ),
                      ],
                    ),
                  )
                : ListView.builder(
                    itemCount: recentLogs.length > 20 ? 20 : recentLogs.length,
                    itemBuilder: (context, index) {
                      final log = recentLogs[index];
                      return Card(
                        margin: const EdgeInsets.only(bottom: 8),
                        child: ListTile(
                          leading: const Icon(
                            Icons.shopping_cart,
                            color: Colors.blue,
                          ),
                          title: Text('${log.quantity} units used for ${log.productName}'),
                          subtitle: Text(
                            'Material ID: ${log.materialId}',
                          ),
                          trailing: Text(
                            '${log.timestamp.day}/${log.timestamp.month}/${log.timestamp.year}',
                            style: TextStyle(color: Colors.grey[600]),
                          ),
                          onTap: () {
                            Navigator.of(context).pushNamed(
                              AppRoutes.materialDetails,
                              arguments: {'materialId': log.materialId},
                            );
                          },
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}
