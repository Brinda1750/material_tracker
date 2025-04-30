import 'package:flutter/foundation.dart';
import 'package:smartfab_app/core/services/firebase_service.dart';
import 'package:smartfab_app/core/services/local_storage_service.dart';
import 'package:smartfab_app/core/services/service_locator.dart';
import 'package:smartfab_app/features/inventory/models/material_model.dart';
import 'package:smartfab_app/features/manufacturing/models/consumption_log_model.dart';
import 'package:smartfab_app/features/manufacturing/models/process_model.dart';

class ManufacturingProvider with ChangeNotifier {
  final LocalStorageService _localStorageService = locator<LocalStorageService>();
  final FirebaseService _firebaseService = locator<FirebaseService>();
  
  List<ProcessModel> _processes = [];
  List<ProcessModel> get processes => _processes;
  
  List<ConsumptionLogModel> _consumptionLogs = [];
  List<ConsumptionLogModel> get consumptionLogs => _consumptionLogs;
  
  bool _isLoading = false;
  bool get isLoading => _isLoading;
  
  String? _errorMessage;
  String? get errorMessage => _errorMessage;
  
  ManufacturingProvider() {
    loadProcesses();
    loadConsumptionLogs();
  }
  
  Future<void> loadProcesses() async {
    _setLoading(true);
    
    try {
      _processes = await _localStorageService.getAllProcesses();
      notifyListeners();
    } catch (e) {
      _setError('Failed to load processes: ${e.toString()}');
    } finally {
      _setLoading(false);
    }
  }
  
  Future<void> loadConsumptionLogs() async {
    _setLoading(true);
    
    try {
      _consumptionLogs = await _localStorageService.getAllConsumptionLogs();
      notifyListeners();
    } catch (e) {
      _setError('Failed to load consumption logs: ${e.toString()}');
    } finally {
      _setLoading(false);
    }
  }
  
  Future<void> addProcess(ProcessModel process) async {
    _setLoading(true);
    
    try {
      await _localStorageService.saveProcess(process);
      _processes.add(process);
      notifyListeners();
      
      // Try to sync with Firebase if possible
      try {
        await _firebaseService.createProcess(process);
        await _localStorageService.markAsSynced('processes', process.id);
      } catch (_) {
        // Sync failed, but local operation succeeded
      }
    } catch (e) {
      _setError('Failed to add process: ${e.toString()}');
    } finally {
      _setLoading(false);
    }
  }
  
  Future<void> updateProcess(ProcessModel process) async {
    _setLoading(true);
    
    try {
      await _localStorageService.saveProcess(process);
      
      final index = _processes.indexWhere((p) => p.id == process.id);
      if (index != -1) {
        _processes[index] = process;
        notifyListeners();
      }
      
      // Try to sync with Firebase if possible
      try {
        await _firebaseService.updateProcess(process);
        await _localStorageService.markAsSynced('processes', process.id);
      } catch (_) {
        // Sync failed, but local operation succeeded
      }
    } catch (e) {
      _setError('Failed to update process: ${e.toString()}');
    } finally {
      _setLoading(false);
    }
  }
  
  Future<void> deleteProcess(String processId) async {
    _setLoading(true);
    
    try {
      await _localStorageService.deleteProcess(processId);
      
      _processes.removeWhere((p) => p.id == processId);
      notifyListeners();
      
      // Try to sync with Firebase if possible
      try {
        await _firebaseService.deleteProcess(processId);
      } catch (_) {
        // Sync failed, but local operation succeeded
      }
    } catch (e) {
      _setError('Failed to delete process: ${e.toString()}');
    } finally {
      _setLoading(false);
    }
  }
  
  Future<ProcessModel?> getProcessById(String id) async {
    try {
      return await _localStorageService.getProcessById(id);
    } catch (e) {
      _setError('Failed to get process: ${e.toString()}');
      return null;
    }
  }
  
  Future<void> logConsumption(ConsumptionLogModel log) async {
    _setLoading(true);
    
    try {
      // Save the consumption log
      await _localStorageService.saveConsumptionLog(log);
      _consumptionLogs.add(log);
      
      // Update material stock
      final material = await _localStorageService.getMaterialById(log.materialId);
      if (material != null) {
        final updatedMaterial = material.copyWith(
          stockQuantity: material.stockQuantity - log.quantity,
          updatedAt: DateTime.now(),
        );
        
        await _localStorageService.saveMaterial(updatedMaterial);
      }
      
      notifyListeners();
      
      // Try to sync with Firebase if possible
      try {
        await _firebaseService.createConsumptionLog(log);
        if (material != null) {
          await _firebaseService.updateMaterial(material);
        }
        await _localStorageService.markAsSynced('consumption_logs', log.id);
      } catch (_) {
        // Sync failed, but local operation succeeded
      }
    } catch (e) {
      _setError('Failed to log consumption: ${e.toString()}');
    } finally {
      _setLoading(false);
    }
  }
  
  Future<List<ConsumptionLogModel>> getConsumptionLogsByMaterialId(String materialId) async {
    try {
      return await _localStorageService.getConsumptionLogsByMaterialId(materialId);
    } catch (e) {
      _setError('Failed to get consumption logs: ${e.toString()}');
      return [];
    }
  }
  
  Future<Map<String, dynamic>> calculateProductCost({
    required List<Map<String, dynamic>> materials,
    required List<Map<String, dynamic>> processes,
    required double desiredMargin,
  }) async {
    double rawMaterialCost = 0;
    double processingCost = 0;
    
    // Calculate raw material cost
    for (var material in materials) {
      final materialId = material['materialId'] as String;
      final quantity = material['quantity'] as double;
      
      final materialModel = await _localStorageService.getMaterialById(materialId);
      if (materialModel != null) {
        rawMaterialCost += materialModel.unitCost * quantity;
      }
    }
    
    // Calculate processing cost
    for (var process in processes) {
      final processId = process['processId'] as String;
      final duration = process['duration'] as double;
      
      final processModel = await _localStorageService.getProcessById(processId);
      if (processModel != null) {
        processingCost += processModel.setupCost + (processModel.costPerHour * duration);
      }
    }
    
    // Calculate manufacturing cost
    final manufacturingCost = rawMaterialCost + processingCost;
    
    // Calculate final product price
    final marginMultiplier = 1 + (desiredMargin / 100);
    final finalProductPrice = manufacturingCost * marginMultiplier;
    
    // Calculate profit
    final profit = finalProductPrice - manufacturingCost;
    
    return {
      'rawMaterialCost': rawMaterialCost,
      'processingCost': processingCost,
      'manufacturingCost': manufacturingCost,
      'finalProductPrice': finalProductPrice,
      'profit': profit,
      'marginPercentage': desiredMargin,
    };
  }
  
  void _setLoading(bool loading) {
    _isLoading = loading;
    if (loading) {
      _errorMessage = null;
    }
    notifyListeners();
  }
  
  void _setError(String error) {
    _errorMessage = error;
    notifyListeners();
  }
}
