import 'package:uuid/uuid.dart';

class MaterialModel {
  final String id;
  final String name;
  final String description;
  final double unitCost;
  final String unitType;
  final double stockQuantity;
  final double lowStockThreshold;
  final DateTime createdAt;
  final DateTime updatedAt;
  final bool synced;
  
  MaterialModel({
    String? id,
    required this.name,
    required this.description,
    required this.unitCost,
    required this.unitType,
    required this.stockQuantity,
    required this.lowStockThreshold,
    DateTime? createdAt,
    DateTime? updatedAt,
    this.synced = false,
  }) : 
    id = id ?? const Uuid().v4(),
    createdAt = createdAt ?? DateTime.now(),
    updatedAt = updatedAt ?? DateTime.now();
  
  factory MaterialModel.fromJson(Map<String, dynamic> json) {
    return MaterialModel(
      id: json['id'],
      name: json['name'],
      description: json['description'],
      unitCost: json['unitCost'].toDouble(),
      unitType: json['unitType'],
      stockQuantity: json['stockQuantity'].toDouble(),
      lowStockThreshold: json['lowStockThreshold'].toDouble(),
      createdAt: json['createdAt'] is DateTime 
        ? json['createdAt'] 
        : DateTime.parse(json['createdAt']),
      updatedAt: json['updatedAt'] is DateTime 
        ? json['updatedAt'] 
        : DateTime.parse(json['updatedAt']),
      synced: json['synced'] ?? false,
    );
  }
  
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'unitCost': unitCost,
      'unitType': unitType,
      'stockQuantity': stockQuantity,
      'lowStockThreshold': lowStockThreshold,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
      'synced': synced,
    };
  }
  
  MaterialModel copyWith({
    String? id,
    String? name,
    String? description,
    double? unitCost,
    String? unitType,
    double? stockQuantity,
    double? lowStockThreshold,
    DateTime? createdAt,
    DateTime? updatedAt,
    bool? synced,
  }) {
    return MaterialModel(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      unitCost: unitCost ?? this.unitCost,
      unitType: unitType ?? this.unitType,
      stockQuantity: stockQuantity ?? this.stockQuantity,
      lowStockThreshold: lowStockThreshold ?? this.lowStockThreshold,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      synced: synced ?? this.synced,
    );
  }
  
  bool get isLowStock => stockQuantity <= lowStockThreshold;
}
