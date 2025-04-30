import 'package:get_it/get_it.dart';
import 'package:smartfab_app/core/services/local_storage_service.dart';
import 'package:smartfab_app/core/services/firebase_service.dart';
import 'package:smartfab_app/core/services/auth_service.dart';
import 'package:smartfab_app/core/services/sync_service.dart';
import 'package:smartfab_app/core/utils/connectivity_helper.dart';

final GetIt locator = GetIt.instance;

void setupServiceLocator() {
  // Core services
  locator.registerLazySingleton<LocalStorageService>(() => LocalStorageService());
  locator.registerLazySingleton<FirebaseService>(() => FirebaseService());
  locator.registerLazySingleton<AuthService>(() => AuthService());
  locator.registerLazySingleton<SyncService>(() => SyncService());
  
  // Utilities
  locator.registerLazySingleton<ConnectivityHelper>(() => ConnectivityHelper());
}
