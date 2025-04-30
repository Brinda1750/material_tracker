import 'package:uuid/uuid.dart';

class ConsumptionLogModel {
  final String id;
  final String materialId;
  final String productName;
  final double quantity;
  final DateTime timestamp;
  final String userId;
  final String? processId;
  final double? processDuration;
  final bool synced;
  
  ConsumptionLogModel({
    String? id,
    required this.materialId,
    required this.productName,
    required this.quantity,
    DateTime? timestamp,
    required this.userId,
    this.processId,
    this.processDuration,
    this.synced = false,
  }) : 
    id = id ?? const Uuid().v4(),
    timestamp = timestamp ?? DateTime.now();
  
  factory ConsumptionLogModel.fromJson(Map<String, dynamic> json) {
    return ConsumptionLogModel(
      id: json['id'],
      materialId: json['materialId'],
      productName: json['productName'],
      quantity: json['quantity'].toDouble(),
      timestamp: json['timestamp'] is DateTime 
        ? json['timestamp'] 
        : DateTime.parse(json['timestamp']),
      userId: json['userId'],
      processId: json['processId'],
      processDuration: json['processDuration']?.toDouble(),
      synced: json['synced'] ?? false,
    );
  }
  
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'materialId': materialId,
      'productName': productName,
      'quantity': quantity,
      'timestamp': timestamp.toIso8601String(),
      'userId': userId,
      'processId': processId,
      'processDuration': processDuration,
      'synced': synced,
    };
  }
    processId,
      'processDuration': processDuration,
      'synced': synced,
    };
  }
  
  ConsumptionLogModel copyWith({
    String? id,
    String? materialId,
    String? productName,
    double? quantity,
    DateTime? timestamp,
    String? userId,
    String? processId,
    double? processDuration,
    bool? synced,
  }) {
    return ConsumptionLogModel(
      id: id ?? this.id,
      materialId: materialId ?? this.materialId,
      productName: productName ?? this.productName,
      quantity: quantity ?? this.quantity,
      timestamp: timestamp ?? this.timestamp,
      userId: userId ?? this.userId,
      processId: processId ?? this.processId,
      processDuration: processDuration ?? this.processDuration,
      synced: synced ?? this.synced,
    );
  }
}
