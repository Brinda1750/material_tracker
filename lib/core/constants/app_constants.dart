class AppConstants {
  // App info
  static const String appName = 'SmartFab';
  static const String appVersion = '1.0.0';
  
  // User roles
  static const String roleAdmin = 'admin';
  static const String roleOperator = 'operator';
  
  // Material units
  static const List<String> materialUnits = [
    'kg', 'g', 'mg',
    'l', 'ml',
    'm', 'cm', 'mm',
    'pcs', 'box', 'roll',
    'sheet', 'pair'
  ];
  
  // Default margins
  static const double defaultMargin = 0.3; // 30%
  
  // Low stock threshold percentage
  static const double lowStockThreshold = 0.2; // 20%
  
  // Sync intervals in minutes
  static const int syncInterval = 15;
  
  // Date formats
  static const String dateFormat = 'yyyy-MM-dd';
  static const String dateTimeFormat = 'yyyy-MM-dd HH:mm:ss';
}
