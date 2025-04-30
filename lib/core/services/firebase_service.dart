import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:smartfab_app/features/auth/models/user_model.dart';
import 'package:smartfab_app/features/inventory/models/material_model.dart';
import 'package:smartfab_app/features/manufacturing/models/consumption_log_model.dart';
import 'package:smartfab_app/features/manufacturing/models/process_model.dart';

class FirebaseService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  
  // Authentication
  Future<UserCredential> signInWithEmailAndPassword(String email, String password) async {
    return await _auth.signInWithEmailAndPassword(
      email: email,
      password: password,
    );
  }
  
  Future<void> signOut() async {
    await _auth.signOut();
  }
  
  Future<UserCredential> createUserWithEmailAndPassword(String email, String password) async {
    return await _auth.createUserWithEmailAndPassword(
      email: email,
      password: password,
    );
  }
  
  // Users
  Future<void> createUserProfile(UserModel user) async {
    await _firestore.collection('users').doc(user.id).set(user.toJson());
  }
  
  Future<UserModel?> getUserProfile(String userId) async {
    final doc = await _firestore.collection('users').doc(userId).get();
    if (!doc.exists) return null;
    return UserModel.fromJson(doc.data()!);
  }
  
  Future<List<UserModel>> getAllUsers() async {
    final snapshot = await _firestore.collection('users').get();
    return snapshot.docs.map((doc) => UserModel.fromJson(doc.data())).toList();
  }
  
  Future<void> updateUserProfile(UserModel user) async {
    await _firestore.collection('users').doc(user.id).update(user.toJson());
  }
  
  Future<void> deleteUser(String userId) async {
    await _firestore.collection('users').doc(userId).delete();
  }
  
  // Materials
  Future<void> createMaterial(MaterialModel material) async {
    await _firestore.collection('materials').doc(material.id).set(material.toJson());
  }
  
  Future<MaterialModel?> getMaterial(String materialId) async {
    final doc = await _firestore.collection('materials').doc(materialId).get();
    if (!doc.exists) return null;
    return MaterialModel.fromJson(doc.data()!);
  }
  
  Future<List<MaterialModel>> getAllMaterials() async {
    final snapshot = await _firestore.collection('materials').get();
    return snapshot.docs.map((doc) => MaterialModel.fromJson(doc.data())).toList();
  }
  
  Future<void> updateMaterial(MaterialModel material) async {
    await _firestore.collection('materials').doc(material.id).update(material.toJson());
  }
  
  Future<void> deleteMaterial(String materialId) async {
    await _firestore.collection('materials').doc(materialId).delete();
  }
  
  // Processes
  Future<void> createProcess(ProcessModel process) async {
    await _firestore.collection('processes').doc(process.id).set(process.toJson());
  }
  
  Future<ProcessModel?> getProcess(String processId) async {
    final doc = await _firestore.collection('processes').doc(processId).get();
    if (!doc.exists) return null;
    return ProcessModel.fromJson(doc.data()!);
  }
  
  Future<List<ProcessModel>> getAllProcesses() async {
    final snapshot = await _firestore.collection('processes').get();
    return snapshot.docs.map((doc) => ProcessModel.fromJson(doc.data())).toList();
  }
  
  Future<void> updateProcess(ProcessModel process) async {
    await _firestore.collection('processes').doc(process.id).update(process.toJson());
  }
  
  Future<void> deleteProcess(String processId) async {
    await _firestore.collection('processes').doc(processId).delete();
  }
  
  // Consumption Logs
  Future<void> createConsumptionLog(ConsumptionLogModel log) async {
    await _firestore.collection('consumption_logs').doc(log.id).set(log.toJson());
  }
  
  Future<ConsumptionLogModel?> getConsumptionLog(String logId) async {
    final doc = await _firestore.collection('consumption_logs').doc(logId).get();
    if (!doc.exists) return null;
    return ConsumptionLogModel.fromJson(doc.data()!);
  }
  
  Future<List<ConsumptionLogModel>> getAllConsumptionLogs() async {
    final snapshot = await _firestore.collection('consumption_logs').get();
    return snapshot.docs.map((doc) => ConsumptionLogModel.fromJson(doc.data())).toList();
  }
  
  Future<List<ConsumptionLogModel>> getConsumptionLogsByMaterialId(String materialId) async {
    final snapshot = await _firestore
      .collection('consumption_logs')
      .where('materialId', isEqualTo: materialId)
      .get();
    return snapshot.docs.map((doc) => ConsumptionLogModel.fromJson(doc.data())).toList();
  }
  
  Future<void> updateConsumptionLog(ConsumptionLogModel log) async {
    await _firestore.collection('consumption_logs').doc(log.id).update(log.toJson());
  }
  
  Future<void> deleteConsumptionLog(String logId) async {
    await _firestore.collection('consumption_logs').doc(logId).delete();
  }
  
  // Batch operations for syncing
  Future<void> batchUpdateMaterials(List<MaterialModel> materials) async {
    final batch = _firestore.batch();
    
    for (var material in materials) {
      final docRef = _firestore.collection('materials').doc(material.id);
      batch.set(docRef, material.toJson(), SetOptions(merge: true));
    }
    
    await batch.commit();
  }
  
  Future<void> batchUpdateConsumptionLogs(List<ConsumptionLogModel> logs) async {
    final batch = _firestore.batch();
    
    for (var log in logs) {
      final docRef = _firestore.collection('consumption_logs').doc(log.id);
      batch.set(docRef, log.toJson(), SetOptions(merge: true));
    }
    
    await batch.commit();
  }
}
