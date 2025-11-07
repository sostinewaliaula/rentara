import 'package:rentara/core/models/unit_model.dart';
import 'package:rentara/core/models/user_model.dart';

enum MaintenanceStatus { PENDING, IN_PROGRESS, RESOLVED, CANCELLED }

class MaintenanceModel {
  final String id;
  final String unitId;
  final String description;
  final MaintenanceStatus status;
  final String createdById;
  final String? assignedToId;
  final List<String> images;
  final DateTime? resolvedAt;
  final String? notes;
  final DateTime createdAt;
  final DateTime updatedAt;
  final UnitModel? unit;
  final UserModel? createdBy;
  final UserModel? assignedTo;

  MaintenanceModel({
    required this.id,
    required this.unitId,
    required this.description,
    required this.status,
    required this.createdById,
    this.assignedToId,
    required this.images,
    this.resolvedAt,
    this.notes,
    required this.createdAt,
    required this.updatedAt,
    this.unit,
    this.createdBy,
    this.assignedTo,
  });

  factory MaintenanceModel.fromJson(Map<String, dynamic> json) {
    return MaintenanceModel(
      id: json['id'] as String,
      unitId: json['unitId'] as String,
      description: json['description'] as String,
      status: MaintenanceStatus.values.firstWhere(
        (e) => e.name == json['status'],
        orElse: () => MaintenanceStatus.PENDING,
      ),
      createdById: json['createdById'] as String,
      assignedToId: json['assignedToId'] as String?,
      images: List<String>.from(json['images'] as List? ?? []),
      resolvedAt: json['resolvedAt'] != null
          ? DateTime.parse(json['resolvedAt'] as String)
          : null,
      notes: json['notes'] as String?,
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
      unit: json['unit'] != null
          ? UnitModel.fromJson(json['unit'] as Map<String, dynamic>)
          : null,
      createdBy: json['createdBy'] != null
          ? UserModel.fromJson(json['createdBy'] as Map<String, dynamic>)
          : null,
      assignedTo: json['assignedTo'] != null
          ? UserModel.fromJson(json['assignedTo'] as Map<String, dynamic>)
          : null,
    );
  }
}




