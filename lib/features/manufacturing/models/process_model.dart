import 'package:uuid/uuid.dart';

class ProcessModel {
  final String id;
  final String name;
  final String description;
  final double costPerHour;
  final double setupCost;
  final bool synced;
  
  ProcessModel({
    String? id,
    required this.name,
    required this.description,
    required this.costPerHour,
    required this.setupCost,
    this.synced = false,
  }) : id = id ?? const Uuid().v4();
  
  factory ProcessModel.fromJson(Map<String, dynamic> json) {
    return ProcessModel(
      id: json['id'],
      name: json['name'],
      description: json['description'],
      costPerHour: json['costPerHour'].toDouble(),
      setupCost: json['setupCost'].toDouble(),
      synced: json['synced'] ?? false,
    );
  }
  
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'costPerHour': costPerHour,
      'setupCost': setupCost,
      'synced': synced,
    };
  }
  
  ProcessModel copyWith({
    String? id,
    String? name,
    String? description,
    double? costPerHour,
    double? setupCost,
    bool? synced,
  }) {
    return ProcessModel(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      costPerHour: costPerHour ?? this.costPerHour,
      setupCost: setupCost ?? this.setupCost,
      synced: synced ?? this.synced,
    );
  }
}
