import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:provider/provider.dart';
import 'package:smartfab_app/core/services/service_locator.dart';
import 'package:smartfab_app/core/utils/app_theme.dart';
import 'package:smartfab_app/features/auth/providers/auth_provider.dart';
import 'package:smartfab_app/features/inventory/providers/inventory_provider.dart';
import 'package:smartfab_app/features/manufacturing/providers/manufacturing_provider.dart';
import 'package:smartfab_app/features/reports/providers/reports_provider.dart';
import 'package:smartfab_app/firebase_options.dart';
import 'package:smartfab_app/routes.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize Firebase
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  
  // Initialize Hive for local storage
  await Hive.initFlutter();
  await initHiveBoxes();
  
  // Setup service locator
  setupServiceLocator();
  
  runApp(const MyApp());
}

Future<void> initHiveBoxes() async {
  await Hive.openBox('materials');
  await Hive.openBox('users');
  await Hive.openBox('processes');
  await Hive.openBox('consumption_logs');
  await Hive.openBox('app_settings');
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => InventoryProvider()),
        ChangeNotifierProvider(create: (_) => ManufacturingProvider()),
        ChangeNotifierProvider(create: (_) => ReportsProvider()),
      ],
      child: Consumer<AuthProvider>(
        builder: (context, authProvider, _) {
          return MaterialApp(
            title: 'SmartFab',
            theme: AppTheme.lightTheme,
            darkTheme: AppTheme.darkTheme,
            themeMode: ThemeMode.system,
            initialRoute: authProvider.isAuthenticated ? AppRoutes.home : AppRoutes.login,
            onGenerateRoute: AppRouter.generateRoute,
          );
        },
      ),
    );
  }
}
