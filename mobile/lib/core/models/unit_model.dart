import 'package:rentara/core/models/user_model.dart';

enum UnitStatus { VACANT, OCCUPIED, MAINTENANCE }

class UnitModel {
  final String id;
  final String propertyId;
  final String name;
  final double rentAmount;
  final UnitStatus status;
  final String? tenantId;
  final String? description;
  final List<String> images;
  final DateTime createdAt;
  final DateTime updatedAt;
  final PropertyModel? property;
  final UserModel? tenant;

  UnitModel({
    required this.id,
    required this.propertyId,
    required this.name,
    required this.rentAmount,
    required this.status,
    this.tenantId,
    this.description,
    required this.images,
    required this.createdAt,
    required this.updatedAt,
    this.property,
    this.tenant,
  });

  factory UnitModel.fromJson(Map<String, dynamic> json) {
    return UnitModel(
      id: json['id'] as String,
      propertyId: json['propertyId'] as String,
      name: json['name'] as String,
      rentAmount: (json['rentAmount'] as num).toDouble(),
      status: UnitStatus.values.firstWhere(
        (e) => e.name == json['status'],
        orElse: () => UnitStatus.VACANT,
      ),
      tenantId: json['tenantId'] as String?,
      description: json['description'] as String?,
      images: List<String>.from(json['images'] as List? ?? []),
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
      property: json['property'] != null
          ? PropertyModel.fromJson(json['property'] as Map<String, dynamic>)
          : null,
      tenant: json['tenant'] != null
          ? UserModel.fromJson(json['tenant'] as Map<String, dynamic>)
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'propertyId': propertyId,
      'name': name,
      'rentAmount': rentAmount,
      'status': status.name,
      'tenantId': tenantId,
      'description': description,
      'images': images,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }
}

class PropertyModel {
  final String id;
  final String name;
  final String location;
  final String type;
  final String? description;

  PropertyModel({
    required this.id,
    required this.name,
    required this.location,
    required this.type,
    this.description,
  });

  factory PropertyModel.fromJson(Map<String, dynamic> json) {
    return PropertyModel(
      id: json['id'] as String,
      name: json['name'] as String,
      location: json['location'] as String,
      type: json['type'] as String,
      description: json['description'] as String?,
    );
  }
}




