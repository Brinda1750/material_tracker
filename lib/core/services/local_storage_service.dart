import 'package:hive_flutter/hive_flutter.dart';
import 'package:smartfab_app/features/auth/models/user_model.dart';
import 'package:smartfab_app/features/inventory/models/material_model.dart';
import 'package:smartfab_app/features/manufacturing/models/consumption_log_model.dart';
import 'package:smartfab_app/features/manufacturing/models/process_model.dart';

class LocalStorageService {
  // Materials
  Future<List<MaterialModel>> getAllMaterials() async {
    final box = Hive.box('materials');
    return box.values.map((e) => MaterialModel.fromJson(Map<String, dynamic>.from(e))).toList();
  }
  
  Future<MaterialModel?> getMaterialById(String id) async {
    final box = Hive.box('materials');
    final data = box.get(id);
    if (data == null) return null;
    return MaterialModel.fromJson(Map<String, dynamic>.from(data));
  }
  
  Future<void> saveMaterial(MaterialModel material) async {
    final box = Hive.box('materials');
    await box.put(material.id, material.toJson());
  }
  
  Future<void> deleteMaterial(String id) async {
    final box = Hive.box('materials');
    await box.delete(id);
  }
  
  // Users
  Future<List<UserModel>> getAllUsers() async {
    final box = Hive.box('users');
    return box.values.map((e) => UserModel.fromJson(Map<String, dynamic>.from(e))).toList();
  }
  
  Future<UserModel?> getUserById(String id) async {
    final box = Hive.box('users');
    final data = box.get(id);
    if (data == null) return null;
    return UserModel.fromJson(Map<String, dynamic>.from(data));
  }
  
  Future<void> saveUser(UserModel user) async {
    final box = Hive.box('users');
    await box.put(user.id, user.toJson());
  }
  
  Future<void> deleteUser(String id) async {
    final box = Hive.box('users');
    await box.delete(id);
  }
  
  // Processes
  Future<List<ProcessModel>> getAllProcesses() async {
    final box = Hive.box('processes');
    return box.values.map((e) => ProcessModel.fromJson(Map<String, dynamic>.from(e))).toList();
  }
  
  Future<ProcessModel?> getProcessById(String id) async {
    final box = Hive.box('processes');
    final data = box.get(id);
    if (data == null) return null;
    return ProcessModel.fromJson(Map<String, dynamic>.from(data));
  }
  
  Future<void> saveProcess(ProcessModel process) async {
    final box = Hive.box('processes');
    await box.put(process.id, process.toJson());
  }
  
  Future<void> deleteProcess(String id) async {
    final box = Hive.box('processes');
    await box.delete(id);
  }
  
  // Consumption Logs
  Future<List<ConsumptionLogModel>> getAllConsumptionLogs() async {
    final box = Hive.box('consumption_logs');
    return box.values.map((e) => ConsumptionLogModel.fromJson(Map<String, dynamic>.from(e))).toList();
  }
  
  Future<List<ConsumptionLogModel>> getConsumptionLogsByMaterialId(String materialId) async {
    final box = Hive.box('consumption_logs');
    return box.values
      .map((e) => ConsumptionLogModel.fromJson(Map<String, dynamic>.from(e)))
      .where((log) => log.materialId == materialId)
      .toList();
  }
  
  Future<void> saveConsumptionLog(ConsumptionLogModel log) async {
    final box = Hive.box('consumption_logs');
    await box.put(log.id, log.toJson());
  }
  
  Future<void> deleteConsumptionLog(String id) async {
    final box = Hive.box('consumption_logs');
    await box.delete(id);
  }
  
  // App Settings
  Future<void> saveSettings(Map<String, dynamic> settings) async {
    final box = Hive.box('app_settings');
    await box.putAll(settings);
  }
  
  Future<dynamic> getSetting(String key, {dynamic defaultValue}) async {
    final box = Hive.box('app_settings');
    return box.get(key, defaultValue: defaultValue);
  }
  
  // Sync Status
  Future<void> markAsSynced(String boxName, String id) async {
    final box = Hive.box(boxName);
    final item = box.get(id);
    if (item != null && item is Map) {
      item['synced'] = true;
      await box.put(id, item);
    }
  }
  
  Future<List<Map<String, dynamic>>> getUnsyncedItems(String boxName) async {
    final box = Hive.box(boxName);
    return box.values
      .where((item) => item is Map && (item['synced'] == null || item['synced'] == false))
      .map((e) => Map<String, dynamic>.from(e))
      .toList();
  }
}
