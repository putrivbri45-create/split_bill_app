import 'package:equatable/equatable.dart';

class ExpenseSplitModel extends Equatable {
  final String id;
  final String expenseId;
  final String userId;
  final String userName;
  final double amountOwed;
  final bool isSettled;
  final DateTime? settledAt;

  const ExpenseSplitModel({
    required this.id,
    required this.expenseId,
    required this.userId,
    required this.userName,
    required this.amountOwed,
    this.isSettled = false,
    this.settledAt,
  });

  ExpenseSplitModel copyWith({
    String? id,
    String? expenseId,
    String? userId,
    String? userName,
    double? amountOwed,
    bool? isSettled,
    DateTime? settledAt,
  }) {
    return ExpenseSplitModel(
      id: id ?? this.id,
      expenseId: expenseId ?? this.expenseId,
      userId: userId ?? this.userId,
      userName: userName ?? this.userName,
      amountOwed: amountOwed ?? this.amountOwed,
      isSettled: isSettled ?? this.isSettled,
      settledAt: settledAt ?? this.settledAt,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'expense_id': expenseId,
      'user_id': userId,
      'user_name': userName,
      'amount_owed': amountOwed,
      'is_settled': isSettled,
      'settled_at': settledAt?.toIso8601String(),
    };
  }

  factory ExpenseSplitModel.fromJson(Map<String, dynamic> json) {
    return ExpenseSplitModel(
      id: json['id'] as String,
      expenseId: json['expense_id'] as String,
      userId: json['user_id'] as String,
      userName: json['user_name'] as String? ?? 'Member',
      amountOwed: double.tryParse(json['amount_owed']?.toString() ?? '0') ?? 0.0,
      isSettled: json['is_settled'] as bool? ?? false,
      settledAt: json['settled_at'] != null ? DateTime.tryParse(json['settled_at'].toString()) : null,
    );
  }

  @override
  List<Object?> get props => [id, expenseId, userId, userName, amountOwed, isSettled, settledAt];
}

class ExpenseModel extends Equatable {
  final String id;
  final String groupId;
  final String? payerId;
  final String payerName;
  final String title;
  final double totalAmount;
  final String splitType; // 'EQUAL', 'PERCENTAGE', 'CUSTOM', 'EXACT'
  final double taxAmount;
  final double serviceCharge;
  final String? billImageUrl;
  final DateTime expenseDate;
  final DateTime createdAt;
  final List<ExpenseSplitModel> splits;
  final String category;
  final String? note;

  const ExpenseModel({
    required this.id,
    required this.groupId,
    this.payerId,
    this.payerName = 'Anda',
    required this.title,
    required this.totalAmount,
    this.splitType = 'EQUAL',
    this.taxAmount = 0.0,
    this.serviceCharge = 0.0,
    this.billImageUrl,
    required this.expenseDate,
    required this.createdAt,
    this.splits = const [],
    this.category = 'Makanan & Minuman',
    this.note,
  });

  ExpenseModel copyWith({
    String? id,
    String? groupId,
    String? payerId,
    String? payerName,
    String? title,
    double? totalAmount,
    String? splitType,
    double? taxAmount,
    double? serviceCharge,
    String? billImageUrl,
    DateTime? expenseDate,
    DateTime? createdAt,
    List<ExpenseSplitModel>? splits,
    String? category,
    String? note,
  }) {
    return ExpenseModel(
      id: id ?? this.id,
      groupId: groupId ?? this.groupId,
      payerId: payerId ?? this.payerId,
      payerName: payerName ?? this.payerName,
      title: title ?? this.title,
      totalAmount: totalAmount ?? this.totalAmount,
      splitType: splitType ?? this.splitType,
      taxAmount: taxAmount ?? this.taxAmount,
      serviceCharge: serviceCharge ?? this.serviceCharge,
      billImageUrl: billImageUrl ?? this.billImageUrl,
      expenseDate: expenseDate ?? this.expenseDate,
      createdAt: createdAt ?? this.createdAt,
      splits: splits ?? this.splits,
      category: category ?? this.category,
      note: note ?? this.note,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'group_id': groupId,
      'payer_id': payerId,
      'payer_name': payerName,
      'title': title,
      'total_amount': totalAmount,
      'split_type': splitType,
      'tax_amount': taxAmount,
      'service_charge': serviceCharge,
      'bill_image_url': billImageUrl,
      'expense_date': expenseDate.toIso8601String(),
      'created_at': createdAt.toIso8601String(),
      'splits': splits.map((s) => s.toJson()).toList(),
      'category': category,
      'note': note,
    };
  }

  factory ExpenseModel.fromJson(Map<String, dynamic> json) {
    return ExpenseModel(
      id: json['id'] as String,
      groupId: json['group_id'] as String,
      payerId: json['payer_id'] as String?,
      payerName: json['payer_name'] as String? ?? 'Anda',
      title: json['title'] as String,
      totalAmount: double.tryParse(json['total_amount']?.toString() ?? '0') ?? 0.0,
      splitType: json['split_type'] as String? ?? 'EQUAL',
      taxAmount: double.tryParse(json['tax_amount']?.toString() ?? '0') ?? 0.0,
      serviceCharge: double.tryParse(json['service_charge']?.toString() ?? '0') ?? 0.0,
      billImageUrl: json['bill_image_url'] as String?,
      expenseDate: json['expense_date'] != null
          ? DateTime.tryParse(json['expense_date'].toString()) ?? DateTime.now()
          : DateTime.now(),
      createdAt: json['created_at'] != null
          ? DateTime.tryParse(json['created_at'].toString()) ?? DateTime.now()
          : DateTime.now(),
      splits: (json['splits'] as List<dynamic>?)
              ?.map((s) => ExpenseSplitModel.fromJson(s as Map<String, dynamic>))
              .toList() ??
          [],
      category: json['category'] as String? ?? 'Makanan & Minuman',
      note: json['note'] as String?,
    );
  }

  @override
  List<Object?> get props => [
        id,
        groupId,
        payerId,
        payerName,
        title,
        totalAmount,
        splitType,
        taxAmount,
        serviceCharge,
        billImageUrl,
        expenseDate,
        createdAt,
        splits,
        category,
        note,
      ];
}
