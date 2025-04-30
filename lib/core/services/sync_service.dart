import 'dart:async';
import 'package:smartfab_app/core/constants/app_constants.dart';
import 'package:smartfab_app/core/services/firebase_service.dart';
import 'package:smartfab_app/core/services/local_storage_service.dart';
import 'package:smartfab_app/core/services/service_locator.dart';
import 'package:smartfab_app/core/utils/connectivity_helper.dart';
import 'package:smartfab_app/features/inventory/models/material_model.dart';
import 'package:smartfab_app/features/manufacturing/models/consumption_log_model.dart';

class SyncService {
  final FirebaseService _firebaseService = locator<FirebaseService>();
  final LocalStorageService _localStorageService = locator<LocalStorageService>();
  final ConnectivityHelper _connectivityHelper = locator<ConnectivityHelper>();
  
  Timer? _syncTimer;
  bool _isSyncing = false;
  
  final _syncController = StreamController<bool>.broadcast();
  Stream<bool> get syncStream => _syncController.stream;
  
  SyncService() {
    _connectivityHelper.connectivityStream.listen((isConnected) {
      if (isConnected) {
        syncData();
      }
    });
    
    // Start periodic sync
    _startPeriodicSync();
  }
  
  void _startPeriodicSync() {
    _syncTimer?.cancel();
    _syncTimer = Timer.periodic(
      Duration(minutes: AppConstants.syncInterval),
      (_) {
        if (_connectivityHelper.isConnected) {
          syncData();
        }
      },
    );
  }
  
  Future<void> syncData() async {
    if (_isSyncing || !_connectivityHelper.isConnected) return;
    
    _isSyncing = true;
    _syncController.add(true);
    
    try {
      // Sync materials
      await _syncMaterials();
      
      // Sync consumption logs
      await _syncConsumptionLogs();
      
      // Sync other data as needed
      
    } catch (e) {
      print('Sync error: $e');
    } finally {
      _isSyncing = false;
      _syncController.add(false);
    }
  }
  
  Future<void> _syncMaterials() async {
    // Get unsynced materials from local storage
    final unsyncedMaterials = await _localStorageService.getUnsyncedItems('materials');
    
    if (unsyncedMaterials.isNotEmpty) {
      // Convert to MaterialModel objects
      final materials = unsyncedMaterials
          .map((json) => MaterialModel.fromJson(json))
          .toList();
      
      // Upload to Firebase
      await _firebaseService.batchUpdateMaterials(materials);
      
      // Mark as synced in local storage
      for (var material in materials) {
        await _localStorageService.markAsSynced('materials', material.id);
      }
    }
    
    // Download latest materials from Firebase
    final remoteMaterials = await _firebaseService.getAllMaterials();
    
    // Update local storage with remote data
    for (var material in remoteMaterials) {
      await _localStorageService.saveMaterial(material);
    }
  }
  
  Future<void> _syncConsumptionLogs() async {
    // Get unsynced logs from local storage
    final unsyncedLogs = await _localStorageService.getUnsyncedItems('consumption_logs');
    
    if (unsyncedLogs.isNotEmpty) {
      // Convert to ConsumptionLogModel objects
      final logs = unsyncedLogs
          .map((json) => ConsumptionLogModel.fromJson(json))
          .toList();
      
      // Upload to Firebase
      await _firebaseService.batchUpdateConsumptionLogs(logs);
      
      // Mark as synced in local storage
      for (var log in logs) {
        await _localStorageService.markAsSynced('consumption_logs', log.id);
      }
    }
    
    // Download latest logs from Firebase
    final remoteLogs = await _firebaseService.getAllConsumptionLogs();
    
    // Update local storage with remote data
    for (var log in remoteLogs) {
      await _localStorageService.saveConsumptionLog(log);
    }
  }
  
  void dispose() {
    _syncTimer?.cancel();
    _syncController.close();
  }
}
