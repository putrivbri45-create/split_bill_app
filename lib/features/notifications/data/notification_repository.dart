import '../domain/models/notification_model.dart';

abstract class NotificationRepository {
  Future<List<NotificationModel>> getNotifications();
  Future<void> markAllAsRead();
  Future<void> markAsRead(String id);
  int getUnreadCount();
}

class NotificationRepositoryImpl implements NotificationRepository {

  // Mock notifications matching Stitch design #11 (Notifications)
  static final List<NotificationModel> _mockNotifications = [
    NotificationModel(
      id: 'notif-1',
      title: 'Budi menambahkan pengeluaran baru',
      description: 'Makan Malam Reuni',
      type: 'EXPENSE',
      amount: 200000.0,
      groupName: 'Makan Malam Reuni',
      timestamp: DateTime.now().subtract(const Duration(minutes: 10)),
      isRead: false,
    ),
    NotificationModel(
      id: 'notif-2',
      title: 'Ani belum menyelesaikan pembayaran',
      description: 'Makan Malam Reuni',
      type: 'REMINDER',
      amount: 50000.0,
      groupName: 'Makan Malam Reuni',
      timestamp: DateTime.now().subtract(const Duration(hours: 2)),
      isRead: false,
    ),
    NotificationModel(
      id: 'notif-3',
      title: 'Citra menambahkan Anda ke grup',
      description: 'Grup "Liburan Jogja" (5 anggota)',
      type: 'INVITE',
      groupName: 'Liburan Jogja',
      timestamp: DateTime.now().subtract(const Duration(hours: 5)),
      isRead: false,
    ),
    NotificationModel(
      id: 'notif-4',
      title: 'Dimas melakukan pembayaran',
      description: 'Liburan Jogja via QRIS',
      type: 'SETTLEMENT',
      amount: 75000.0,
      groupName: 'Liburan Jogja',
      timestamp: DateTime.now().subtract(const Duration(days: 1)),
      isRead: true,
    ),
  ];

  @override
  Future<List<NotificationModel>> getNotifications() async {
    return List.from(_mockNotifications);
  }

  @override
  Future<void> markAllAsRead() async {
    for (int i = 0; i < _mockNotifications.length; i++) {
      _mockNotifications[i] = _mockNotifications[i].copyWith(isRead: true);
    }
  }

  @override
  Future<void> markAsRead(String id) async {
    final idx = _mockNotifications.indexWhere((n) => n.id == id);
    if (idx != -1) {
      _mockNotifications[idx] = _mockNotifications[idx].copyWith(isRead: true);
    }
  }

  @override
  int getUnreadCount() {
    return _mockNotifications.where((n) => !n.isRead).length;
  }
}
