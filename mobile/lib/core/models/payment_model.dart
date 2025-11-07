import 'package:rentara/core/models/unit_model.dart';
import 'package:rentara/core/models/user_model.dart';

enum PaymentStatus { PENDING, COMPLETED, FAILED }

class PaymentModel {
  final String id;
  final String tenantId;
  final String unitId;
  final double amount;
  final int month;
  final int year;
  final String? transactionId;
  final String? mpesaReceipt;
  final PaymentStatus status;
  final DateTime? paidAt;
  final DateTime createdAt;
  final DateTime updatedAt;
  final UserModel? tenant;
  final UnitModel? unit;

  PaymentModel({
    required this.id,
    required this.tenantId,
    required this.unitId,
    required this.amount,
    required this.month,
    required this.year,
    this.transactionId,
    this.mpesaReceipt,
    required this.status,
    this.paidAt,
    required this.createdAt,
    required this.updatedAt,
    this.tenant,
    this.unit,
  });

  factory PaymentModel.fromJson(Map<String, dynamic> json) {
    return PaymentModel(
      id: json['id'] as String,
      tenantId: json['tenantId'] as String,
      unitId: json['unitId'] as String,
      amount: (json['amount'] as num).toDouble(),
      month: json['month'] as int,
      year: json['year'] as int,
      transactionId: json['transactionId'] as String?,
      mpesaReceipt: json['mpesaReceipt'] as String?,
      status: PaymentStatus.values.firstWhere(
        (e) => e.name == json['status'],
        orElse: () => PaymentStatus.PENDING,
      ),
      paidAt: json['paidAt'] != null
          ? DateTime.parse(json['paidAt'] as String)
          : null,
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
      tenant: json['tenant'] != null
          ? UserModel.fromJson(json['tenant'] as Map<String, dynamic>)
          : null,
      unit: json['unit'] != null
          ? UnitModel.fromJson(json['unit'] as Map<String, dynamic>)
          : null,
    );
  }

  String get monthName {
    const months = [
      'January',
      'February',
      'March',
      'April',
      'May',
      'June',
      'July',
      'August',
      'September',
      'October',
      'November',
      'December'
    ];
    return months[month - 1];
  }
}




