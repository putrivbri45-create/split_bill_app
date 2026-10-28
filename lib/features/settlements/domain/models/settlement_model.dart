import 'package:equatable/equatable.dart';

class SettlementModel extends Equatable {
  final String id;
  final String groupId;
  final String debtorId;
  final String debtorName;
  final String creditorId;
  final String creditorName;
  final double amount;
  final String? proofImageUrl;
  final String status; // 'PENDING' | 'COMPLETED' | 'REJECTED'
  final DateTime settledAt;
  final String? method;

  const SettlementModel({
    required this.id,
    required this.groupId,
    required this.debtorId,
    required this.debtorName,
    required this.creditorId,
    required this.creditorName,
    required this.amount,
    this.proofImageUrl,
    this.status = 'COMPLETED',
    required this.settledAt,
    this.method,
  });

  SettlementModel copyWith({
    String? id,
    String? groupId,
    String? debtorId,
    String? debtorName,
    String? creditorId,
    String? creditorName,
    double? amount,
    String? proofImageUrl,
    String? status,
    DateTime? settledAt,
    String? method,
  }) {
    return SettlementModel(
      id: id ?? this.id,
      groupId: groupId ?? this.groupId,
      debtorId: debtorId ?? this.debtorId,
      debtorName: debtorName ?? this.debtorName,
      creditorId: creditorId ?? this.creditorId,
      creditorName: creditorName ?? this.creditorName,
      amount: amount ?? this.amount,
      proofImageUrl: proofImageUrl ?? this.proofImageUrl,
      status: status ?? this.status,
      settledAt: settledAt ?? this.settledAt,
      method: method ?? this.method,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'group_id': groupId,
      'debtor_id': debtorId,
      'debtor_name': debtorName,
      'creditor_id': creditorId,
      'creditor_name': creditorName,
      'amount': amount,
      'proof_image_url': proofImageUrl,
      'status': status,
      'settled_at': settledAt.toIso8601String(),
      'method': method,
    };
  }

  factory SettlementModel.fromJson(Map<String, dynamic> json) {
    return SettlementModel(
      id: json['id'] as String,
      groupId: json['group_id'] as String,
      debtorId: json['debtor_id'] as String,
      debtorName: json['debtor_name'] as String? ?? 'Debitur',
      creditorId: json['creditor_id'] as String,
      creditorName: json['creditor_name'] as String? ?? 'Kreditur',
      amount: double.tryParse(json['amount']?.toString() ?? '0') ?? 0.0,
      proofImageUrl: json['proof_image_url'] as String?,
      status: json['status'] as String? ?? 'COMPLETED',
      settledAt: json['settled_at'] != null
          ? DateTime.tryParse(json['settled_at'].toString()) ?? DateTime.now()
          : DateTime.now(),
      method: json['method'] as String?,
    );
  }

  @override
  List<Object?> get props => [
        id,
        groupId,
        debtorId,
        debtorName,
        creditorId,
        creditorName,
        amount,
        proofImageUrl,
        status,
        settledAt,
        method,
      ];
}
