import 'package:equatable/equatable.dart';

class NotificationModel extends Equatable {
  final String id;
  final String title;
  final String description;
  final String type; // 'EXPENSE' | 'REMINDER' | 'INVITE' | 'SETTLEMENT'
  final DateTime timestamp;
  final bool isRead;
  final double? amount;
  final String? groupName;

  const NotificationModel({
    required this.id,
    required this.title,
    required this.description,
    required this.type,
    required this.timestamp,
    this.isRead = false,
    this.amount,
    this.groupName,
  });

  NotificationModel copyWith({
    String? id,
    String? title,
    String? description,
    String? type,
    DateTime? timestamp,
    bool? isRead,
    double? amount,
    String? groupName,
  }) {
    return NotificationModel(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      type: type ?? this.type,
      timestamp: timestamp ?? this.timestamp,
      isRead: isRead ?? this.isRead,
      amount: amount ?? this.amount,
      groupName: groupName ?? this.groupName,
    );
  }

  @override
  List<Object?> get props => [id, title, description, type, timestamp, isRead, amount, groupName];
}
