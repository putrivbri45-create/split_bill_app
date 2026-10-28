import 'package:equatable/equatable.dart';

class GroupMemberModel extends Equatable {
  final String id;
  final String groupId;
  final String userId;
  final String role; // 'admin' | 'member'
  final String userName;
  final String? avatarUrl;
  final double netBalance;
  final String? phoneNumber;

  const GroupMemberModel({
    required this.id,
    required this.groupId,
    required this.userId,
    this.role = 'member',
    required this.userName,
    this.avatarUrl,
    this.netBalance = 0.0,
    this.phoneNumber,
  });

  GroupMemberModel copyWith({
    String? id,
    String? groupId,
    String? userId,
    String? role,
    String? userName,
    String? avatarUrl,
    double? netBalance,
    String? phoneNumber,
  }) {
    return GroupMemberModel(
      id: id ?? this.id,
      groupId: groupId ?? this.groupId,
      userId: userId ?? this.userId,
      role: role ?? this.role,
      userName: userName ?? this.userName,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      netBalance: netBalance ?? this.netBalance,
      phoneNumber: phoneNumber ?? this.phoneNumber,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'group_id': groupId,
      'user_id': userId,
      'role': role,
      'user_name': userName,
      'avatar_url': avatarUrl,
      'net_balance': netBalance,
      'phone_number': phoneNumber,
    };
  }

  factory GroupMemberModel.fromJson(Map<String, dynamic> json) {
    return GroupMemberModel(
      id: json['id'] as String,
      groupId: json['group_id'] as String,
      userId: json['user_id'] as String,
      role: json['role'] as String? ?? 'member',
      userName: json['user_name'] as String? ?? 'Member',
      avatarUrl: json['avatar_url'] as String?,
      netBalance: double.tryParse(json['net_balance']?.toString() ?? '0') ?? 0.0,
      phoneNumber: json['phone_number'] as String?,
    );
  }

  @override
  List<Object?> get props => [id, groupId, userId, role, userName, avatarUrl, netBalance, phoneNumber];
}

class GroupModel extends Equatable {
  final String id;
  final String name;
  final String category; // 'Liburan', 'Makanan', 'Rumah Tangga', 'Kantor', etc.
  final String iconName; // 'restaurant', 'flight', 'home', 'work', etc.
  final String createdBy;
  final DateTime createdAt;
  final int memberCount;
  final int expenseCount;
  final double totalSpending;
  final double userDebt; // Amount current user owes
  final double userCredit; // Amount current user is owed
  final List<GroupMemberModel> members;
  final String? description;

  const GroupModel({
    required this.id,
    required this.name,
    this.category = 'Makanan',
    this.iconName = 'restaurant',
    required this.createdBy,
    required this.createdAt,
    this.memberCount = 1,
    this.expenseCount = 0,
    this.totalSpending = 0.0,
    this.userDebt = 0.0,
    this.userCredit = 0.0,
    this.members = const [],
    this.description,
  });

  GroupModel copyWith({
    String? id,
    String? name,
    String? category,
    String? iconName,
    String? createdBy,
    DateTime? createdAt,
    int? memberCount,
    int? expenseCount,
    double? totalSpending,
    double? userDebt,
    double? userCredit,
    List<GroupMemberModel>? members,
    String? description,
  }) {
    return GroupModel(
      id: id ?? this.id,
      name: name ?? this.name,
      category: category ?? this.category,
      iconName: iconName ?? this.iconName,
      createdBy: createdBy ?? this.createdBy,
      createdAt: createdAt ?? this.createdAt,
      memberCount: memberCount ?? this.memberCount,
      expenseCount: expenseCount ?? this.expenseCount,
      totalSpending: totalSpending ?? this.totalSpending,
      userDebt: userDebt ?? this.userDebt,
      userCredit: userCredit ?? this.userCredit,
      members: members ?? this.members,
      description: description ?? this.description,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'category': category,
      'icon_name': iconName,
      'created_by': createdBy,
      'created_at': createdAt.toIso8601String(),
      'member_count': memberCount,
      'expense_count': expenseCount,
      'total_spending': totalSpending,
      'user_debt': userDebt,
      'user_credit': userCredit,
      'members': members.map((m) => m.toJson()).toList(),
      'description': description,
    };
  }

  factory GroupModel.fromJson(Map<String, dynamic> json) {
    return GroupModel(
      id: json['id'] as String,
      name: json['name'] as String,
      category: json['category'] as String? ?? 'Makanan',
      iconName: json['icon_name'] as String? ?? 'restaurant',
      createdBy: json['created_by'] as String? ?? '',
      createdAt: json['created_at'] != null
          ? DateTime.tryParse(json['created_at'].toString()) ?? DateTime.now()
          : DateTime.now(),
      memberCount: json['member_count'] as int? ?? 1,
      expenseCount: json['expense_count'] as int? ?? 0,
      totalSpending: double.tryParse(json['total_spending']?.toString() ?? '0') ?? 0.0,
      userDebt: double.tryParse(json['user_debt']?.toString() ?? '0') ?? 0.0,
      userCredit: double.tryParse(json['user_credit']?.toString() ?? '0') ?? 0.0,
      members: (json['members'] as List<dynamic>?)
              ?.map((m) => GroupMemberModel.fromJson(m as Map<String, dynamic>))
              .toList() ??
          [],
      description: json['description'] as String?,
    );
  }

  @override
  List<Object?> get props => [
        id,
        name,
        category,
        iconName,
        createdBy,
        createdAt,
        memberCount,
        expenseCount,
        totalSpending,
        userDebt,
        userCredit,
        members,
        description,
      ];
}
