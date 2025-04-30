import 'package:flutter/material.dart';
import 'package:smartfab_app/features/auth/screens/login_screen.dart';
import 'package:smartfab_app/features/auth/screens/profile_screen.dart';
import 'package:smartfab_app/features/dashboard/screens/admin_dashboard_screen.dart';
import 'package:smartfab_app/features/dashboard/screens/operator_dashboard_screen.dart';
import 'package:smartfab_app/features/inventory/screens/add_material_screen.dart';
import 'package:smartfab_app/features/inventory/screens/inventory_screen.dart';
import 'package:smartfab_app/features/inventory/screens/material_details_screen.dart';
import 'package:smartfab_app/features/manufacturing/screens/log_consumption_screen.dart';
import 'package:smartfab_app/features/manufacturing/screens/manufacturing_screen.dart';
import 'package:smartfab_app/features/manufacturing/screens/scan_material_screen.dart';
import 'package:smartfab_app/features/reports/screens/cost_breakdown_screen.dart';
import 'package:smartfab_app/features/reports/screens/export_reports_screen.dart';
import 'package:smartfab_app/features/reports/screens/reports_screen.dart';
import 'package:smartfab_app/features/settings/screens/settings_screen.dart';
import 'package:smartfab_app/features/users/screens/add_user_screen.dart';
import 'package:smartfab_app/features/users/screens/users_screen.dart';

class AppRoutes {
  static const String login = '/login';
  static const String home = '/home';
  static const String adminDashboard = '/admin-dashboard';
  static const String operatorDashboard = '/operator-dashboard';
  static const String inventory = '/inventory';
  static const String addMaterial = '/add-material';
  static const String materialDetails = '/material-details';
  static const String manufacturing = '/manufacturing';
  static const String scanMaterial = '/scan-material';
  static const String logConsumption = '/log-consumption';
  static const String reports = '/reports';
  static const String costBreakdown = '/cost-breakdown';
  static const String exportReports = '/export-reports';
  static const String users = '/users';
  static const String addUser = '/add-user';
  static const String profile = '/profile';
  static const String settings = '/settings';
}

class AppRouter {
  static Route<dynamic> generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case AppRoutes.login:
        return MaterialPageRoute(builder: (_) => const LoginScreen());
      
      case AppRoutes.adminDashboard:
        return MaterialPageRoute(builder: (_) => const AdminDashboardScreen());
      
      case AppRoutes.operatorDashboard:
        return MaterialPageRoute(builder: (_) => const OperatorDashboardScreen());
      
      case AppRoutes.inventory:
        return MaterialPageRoute(builder: (_) => const InventoryScreen());
      
      case AppRoutes.addMaterial:
        return MaterialPageRoute(builder: (_) => const AddMaterialScreen());
      
      case AppRoutes.materialDetails:
        final args = settings.arguments as Map<String, dynamic>;
        return MaterialPageRoute(
          builder: (_) => MaterialDetailsScreen(materialId: args['materialId']),
        );
      
      case AppRoutes.manufacturing:
        return MaterialPageRoute(builder: (_) => const ManufacturingScreen());
      
      case AppRoutes.scanMaterial:
        return MaterialPageRoute(builder: (_) => const ScanMaterialScreen());
      
      case AppRoutes.logConsumption:
        final args = settings.arguments as Map<String, dynamic>;
        return MaterialPageRoute(
          builder: (_) => LogConsumptionScreen(materialId: args['materialId']),
        );
      
      case AppRoutes.reports:
        return MaterialPageRoute(builder: (_) => const ReportsScreen());
      
      case AppRoutes.costBreakdown:
        final args = settings.arguments as Map<String, dynamic>;
        return MaterialPageRoute(
          builder: (_) => CostBreakdownScreen(productId: args['productId']),
        );
      
      case AppRoutes.exportReports:
        return MaterialPageRoute(builder: (_) => const ExportReportsScreen());
      
      case AppRoutes.users:
        return MaterialPageRoute(builder: (_) => const UsersScreen());
      
      case AppRoutes.addUser:
        return MaterialPageRoute(builder: (_) => const AddUserScreen());
      
      case AppRoutes.profile:
        return MaterialPageRoute(builder: (_) => const ProfileScreen());
      
      case AppRoutes.settings:
        return MaterialPageRoute(builder: (_) => const SettingsScreen());
      
      default:
        return MaterialPageRoute(
          builder: (_) => Scaffold(
            body: Center(
              child: Text('No route defined for ${settings.name}'),
            ),
          ),
        );
    }
  }
}
