import 'package:flutter/foundation.dart';
import 'package:smartfab_app/core/services/firebase_service.dart';
import 'package:smartfab_app/core/services/local_storage_service.dart';
import 'package:smartfab_app/core/services/service_locator.dart';
import 'package:smartfab_app/features/inventory/models/material_model.dart';

class InventoryProvider with ChangeNotifier {
  final LocalStorageService _localStorageService = locator<LocalStorageService>();
  final FirebaseService _firebaseService = locator<FirebaseService>();
  
  List<MaterialModel> _materials = [];
  List<MaterialModel> get materials => _materials;
  
  bool _isLoading = false;
  bool get isLoading => _isLoading;
  
  String? _errorMessage;
  String? get errorMessage => _errorMessage;
  
  InventoryProvider() {
    loadMaterials();
  }
  
    get errorMessage => _errorMessage;
  
  InventoryProvider() {
    loadMaterials();
  }
  
  Future<void> loadMaterials() async {
    _setLoading(true);
    
    try {
      _materials = await _localStorageService.getAllMaterials();
      notifyListeners();
    } catch (e) {
      _setError('Failed to load materials: ${e.toString()}');
    } finally {
      _setLoading(false);
    }
  }
  
  Future<void> addMaterial(MaterialModel material) async {
    _setLoading(true);
    
    try {
      await _localStorageService.saveMaterial(material);
      _materials.add(material);
      notifyListeners();
      
      // Try to sync with Firebase if possible
      try {
        await _firebaseService.createMaterial(material);
        await _localStorageService.markAsSynced('materials', material.id);
      } catch (_) {
        // Sync failed, but local operation succeeded
      }
    } catch (e) {
      _setError('Failed to add material: ${e.toString()}');
    } finally {
      _setLoading(false);
    }
  }
  
  Future<void> updateMaterial(MaterialModel material) async {
    _setLoading(true);
    
    try {
      await _localStorageService.saveMaterial(material);
      
      final index = _materials.indexWhere((m) => m.id == material.id);
      if (index != -1) {
        _materials[index] = material;
        notifyListeners();
      }
      
      // Try to sync with Firebase if possible
      try {
        await _firebaseService.updateMaterial(material);
        await _localStorageService.markAsSynced('materials', material.id);
      } catch (_) {
        // Sync failed, but local operation succeeded
      }
    } catch (e) {
      _setError('Failed to update material: ${e.toString()}');
    } finally {
      _setLoading(false);
    }
  }
  
  Future<void> deleteMaterial(String materialId) async {
    _setLoading(true);
    
    try {
      await _localStorageService.deleteMaterial(materialId);
      
      _materials.removeWhere((m) => m.id == materialId);
      notifyListeners();
      
      // Try to sync with Firebase if possible
      try {
        await _firebaseService.deleteMaterial(materialId);
      } catch (_) {
        // Sync failed, but local operation succeeded
      }
    } catch (e) {
      _setError('Failed to delete material: ${e.toString()}');
    } finally {
      _setLoading(false);
    }
  }
  
  Future<MaterialModel?> getMaterialById(String id) async {
    try {
      return await _localStorageService.getMaterialById(id);
    } catch (e) {
      _setError('Failed to get material: ${e.toString()}');
      return null;
    }
  }
  
  List<MaterialModel> getLowStockMaterials() {
    return _materials.where((material) => material.isLowStock).toList();
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
