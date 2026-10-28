import 'package:flutter/material.dart';
import 'package:share_plus/share_plus.dart';
import '../../../../config/theme.dart';
import '../../data/notification_repository.dart';
import '../../domain/models/notification_model.dart';

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  final NotificationRepository _repo = NotificationRepositoryImpl();
  List<NotificationModel> _notifications = [];
  String _selectedFilter = 'Semua';
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadNotifications();
  }

  Future<void> _loadNotifications() async {
    final list = await _repo.getNotifications();
    if (mounted) {
      setState(() {
        _notifications = list;
        _isLoading = false;
      });
    }
  }

  void _markAllAsRead() async {
    final unreadCount = _notifications.where((n) => !n.isRead).length;
    if (unreadCount == 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Semua notifikasi sudah dibaca'),
          duration: Duration(seconds: 2),
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }
    await _repo.markAllAsRead();
    await _loadNotifications();
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Semua notifikasi telah ditandai dibaca'),
          duration: Duration(seconds: 2),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  void _markAsRead(String id) async {
    await _repo.markAsRead(id);
    await _loadNotifications();
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Notifikasi telah ditandai dibaca'),
          duration: Duration(seconds: 1),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  List<NotificationModel> get _filteredNotifications {
    if (_selectedFilter == 'Tagihan') {
      return _notifications.where((n) => n.type == 'EXPENSE' || n.type == 'REMINDER' || n.type == 'SETTLEMENT').toList();
    } else if (_selectedFilter == 'Grup') {
      return _notifications.where((n) => n.type == 'INVITE').toList();
    }
    return _notifications;
  }

  String _formatCurrency(double? amount) {
    if (amount == null) return '';
    final intAmount = amount.round();
    return 'Rp${intAmount.toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (m) => '${m[1]}.')}';
  }

  String _formatTimeAgo(DateTime timestamp) {
    final diff = DateTime.now().difference(timestamp);
    if (diff.inMinutes < 60) {
      return '${diff.inMinutes <= 0 ? 1 : diff.inMinutes} menit lalu';
    } else if (diff.inHours < 24) {
      return '${diff.inHours} jam lalu';
    } else if (diff.inDays == 1) {
      return 'Kemarin, 10:20';
    } else {
      return '${diff.inDays} hari lalu';
    }
  }

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    final isDark = context.isDark;
    final totalUnread = _notifications.where((n) => !n.isRead).length;

    final filtered = _filteredNotifications;
    // Section "HARI INI": notif-1, notif-2
    final todayList = filtered.where((n) => n.id == 'notif-1' || n.id == 'notif-2').toList();
    // Section "KEMARIN & SEBELUMNYA": notif-3, notif-4
    final earlierList = filtered.where((n) => !todayList.contains(n)).toList();

    final todayUnread = todayList.where((n) => !n.isRead).length;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Notifikasi',
          style: AppText.headlineSm.copyWith(
            fontWeight: FontWeight.w800,
            color: palette.onSurface,
          ),
        ),
        actions: [
          TextButton.icon(
            onPressed: _markAllAsRead,
            icon: Icon(
              Icons.done_all_rounded,
              size: 16,
              color: totalUnread > 0
                  ? (isDark ? AppColors.primaryFixed : AppColors.primary)
                  : palette.outline,
            ),
            label: Text(
              'Tandai Semua Dibaca',
              style: AppText.labelSm.copyWith(
                color: totalUnread > 0
                    ? (isDark ? AppColors.primaryFixed : AppColors.primary)
                    : palette.outline,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
      body: SafeArea(
        child: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Filter Chips
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        children: [
                          _buildFilterChip(
                            'Semua (${_notifications.length})',
                            _selectedFilter == 'Semua',
                            () => setState(() => _selectedFilter = 'Semua'),
                          ),
                          const SizedBox(width: 8),
                          _buildFilterChip(
                            'Tagihan & Pembayaran',
                            _selectedFilter == 'Tagihan',
                            () => setState(() => _selectedFilter = 'Tagihan'),
                          ),
                          const SizedBox(width: 8),
                          _buildFilterChip(
                            'Grup',
                            _selectedFilter == 'Grup',
                            () => setState(() => _selectedFilter = 'Grup'),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 20),

                    if (filtered.isEmpty)
                      Center(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(vertical: 48),
                          child: Column(
                            children: [
                              Icon(Icons.notifications_off_outlined, size: 48, color: palette.outline),
                              const SizedBox(height: 12),
                              Text(
                                'Tidak ada notifikasi',
                                style: AppText.bodyMedium.copyWith(color: palette.outline),
                              ),
                            ],
                          ),
                        ),
                      )
                    else ...[
                      // Section HARI INI
                      if (todayList.isNotEmpty) ...[
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'HARI INI',
                              style: AppText.labelSm.copyWith(
                                letterSpacing: 1.1,
                                color: palette.outline,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text(
                              todayUnread > 0 ? '$todayUnread Baru' : 'Semua Dibaca',
                              style: AppText.labelSm.copyWith(
                                color: todayUnread > 0 ? (isDark ? AppColors.primaryFixed : AppColors.primary) : palette.onSurfaceVariant,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 10),
                        for (final notif in todayList) ...[
                          _buildNotificationWidget(notif, palette, isDark),
                          const SizedBox(height: 12),
                        ],
                        const SizedBox(height: 12),
                      ],

                      // Section KEMARIN & SEBELUMNYA
                      if (earlierList.isNotEmpty) ...[
                        Text(
                          'KEMARIN & SEBELUMNYA',
                          style: AppText.labelSm.copyWith(
                            letterSpacing: 1.1,
                            color: palette.outline,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 10),
                        for (final notif in earlierList) ...[
                          _buildNotificationWidget(notif, palette, isDark),
                          const SizedBox(height: 12),
                        ],
                      ],
                    ],

                    const SizedBox(height: 30),
                  ],
                ),
              ),
      ),
    );
  }

  Widget _buildFilterChip(String label, bool isSelected, VoidCallback onTap) {
    final palette = context.palette;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primaryContainer : palette.surfaceLow,
          borderRadius: BorderRadius.circular(AppRadius.pill),
        ),
        child: Text(
          label,
          style: AppText.labelSm.copyWith(
            color: isSelected ? Colors.white : palette.onSurfaceVariant,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
          ),
        ),
      ),
    );
  }

  Widget _buildNotificationWidget(NotificationModel notif, AppPalette palette, bool isDark) {
    if (notif.id == 'notif-1') {
      return _buildNotifCard(
        notification: notif,
        icon: Icons.receipt_long_rounded,
        iconBg: isDark ? const Color(0xFF132F28) : const Color(0xFFD1FAE5),
        iconFg: const Color(0xFF006C49),
        borderColor: const Color(0xFF10B981),
        dotColor: AppColors.primaryContainer,
        title: notif.title,
        subtitle: '${notif.groupName ?? notif.description} • ${_formatCurrency(notif.amount)}',
        time: _formatTimeAgo(notif.timestamp),
        palette: palette,
      );
    } else if (notif.id == 'notif-2') {
      return _buildNotifCard(
        notification: notif,
        icon: Icons.access_time_rounded,
        iconBg: isDark ? const Color(0xFF3B2E12) : const Color(0xFFFEF3C7),
        iconFg: const Color(0xFFD97706),
        borderColor: const Color(0xFFF59E0B),
        dotColor: const Color(0xFFF59E0B),
        title: notif.title,
        subtitle: '${_formatCurrency(notif.amount)} • ${notif.groupName ?? notif.description}',
        time: _formatTimeAgo(notif.timestamp),
        palette: palette,
        action: Container(
          margin: const EdgeInsets.only(top: 12),
          child: OutlinedButton.icon(
            onPressed: () {
              SharePlus.instance.share(
                ShareParams(
                  text: 'Hai Ani, jangan lupa selesaikan tagihan split bill "${notif.groupName ?? "Makan Malam Reuni"}" sebesar ${_formatCurrency(notif.amount)} ya! Terima kasih 🙏',
                ),
              );
            },
            icon: const Icon(Icons.send_rounded, size: 14),
            label: const Text('Kirim Pengingat'),
            style: OutlinedButton.styleFrom(
              minimumSize: const Size.fromHeight(40),
              side: BorderSide(color: palette.cardBorder),
              foregroundColor: palette.onSurface,
            ),
          ),
        ),
      );
    } else if (notif.id == 'notif-3') {
      return _buildNotifCard(
        notification: notif,
        icon: Icons.group_add_rounded,
        iconBg: isDark ? const Color(0xFF1E2838) : const Color(0xFFEFF6FF),
        iconFg: const Color(0xFF2563EB),
        borderColor: const Color(0xFF2563EB),
        dotColor: const Color(0xFF2563EB),
        title: notif.title,
        subtitle: notif.description,
        time: _formatTimeAgo(notif.timestamp),
        palette: palette,
        action: Container(
          margin: const EdgeInsets.only(top: 12),
          child: Row(
            children: [
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () {
                    if (!notif.isRead) _markAsRead(notif.id);
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Berhasil bergabung ke grup Liburan Jogja')),
                    );
                  },
                  icon: const Icon(Icons.check, size: 14),
                  label: const Text('Terima'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primaryContainer,
                    minimumSize: const Size.fromHeight(38),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: OutlinedButton(
                  onPressed: () {
                    if (!notif.isRead) _markAsRead(notif.id);
                  },
                  style: OutlinedButton.styleFrom(
                    minimumSize: const Size.fromHeight(38),
                    side: BorderSide(color: palette.cardBorder),
                  ),
                  child: const Text('Tinjau'),
                ),
              ),
            ],
          ),
        ),
      );
    } else {
      return _buildNotifCard(
        notification: notif,
        icon: Icons.check_circle_outline_rounded,
        iconBg: isDark ? const Color(0xFF132F28) : const Color(0xFFD1FAE5),
        iconFg: const Color(0xFF006C49),
        borderColor: const Color(0xFF10B981),
        dotColor: const Color(0xFF10B981),
        title: notif.title,
        subtitle: '${_formatCurrency(notif.amount)} • ${notif.description}',
        time: _formatTimeAgo(notif.timestamp),
        trailingBadge: 'Lunas',
        palette: palette,
      );
    }
  }

  Widget _buildNotifCard({
    required NotificationModel notification,
    required IconData icon,
    required Color iconBg,
    required Color iconFg,
    required Color borderColor,
    required String title,
    required String subtitle,
    required String time,
    required AppPalette palette,
    Color dotColor = AppColors.primaryContainer,
    String? trailingBadge,
    Widget? action,
  }) {
    final isUnread = !notification.isRead;
    return GestureDetector(
      onTap: () {
        if (isUnread) {
          _markAsRead(notification.id);
        }
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        decoration: BoxDecoration(
          color: palette.card,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isUnread ? borderColor.withValues(alpha: 0.3) : palette.cardBorder,
          ),
          boxShadow: AppShadows.card,
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(20),
          child: Container(
            decoration: BoxDecoration(
              border: Border(
                left: BorderSide(
                  color: isUnread ? borderColor : palette.cardBorder,
                  width: 4,
                ),
              ),
            ),
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        color: isUnread ? iconBg : palette.surfaceLow,
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: Icon(
                        icon,
                        color: isUnread ? iconFg : palette.outline,
                        size: 22,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Expanded(
                                child: Text(
                                  title,
                                  style: AppText.titleMedium.copyWith(
                                    fontWeight: isUnread ? FontWeight.w700 : FontWeight.w600,
                                    color: isUnread ? palette.onSurface : palette.onSurfaceVariant,
                                  ),
                                ),
                              ),
                              if (isUnread)
                                Tooltip(
                                  message: 'Tandai telah dibaca',
                                  child: InkWell(
                                    onTap: () => _markAsRead(notification.id),
                                    borderRadius: BorderRadius.circular(12),
                                    child: Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                      decoration: BoxDecoration(
                                        color: context.isDark ? const Color(0xFF1E2838) : const Color(0xFFEFF6FF),
                                        borderRadius: BorderRadius.circular(12),
                                        border: Border.all(color: const Color(0xFF2563EB).withValues(alpha: 0.2)),
                                      ),
                                      child: Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          const Icon(Icons.check, size: 12, color: Color(0xFF2563EB)),
                                          const SizedBox(width: 2),
                                          Text(
                                            'Tandai dibaca',
                                            style: AppText.labelSm.copyWith(
                                              fontSize: 10,
                                              color: const Color(0xFF2563EB),
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                            ],
                          ),
                          const SizedBox(height: 3),
                          Text(
                            subtitle,
                            style: AppText.bodySm.copyWith(
                              color: palette.onSurfaceVariant,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Row(
                            children: [
                              Icon(Icons.access_time_rounded, size: 12, color: palette.outline),
                              const SizedBox(width: 4),
                              Text(
                                time,
                                style: AppText.bodySm.copyWith(fontSize: 11, color: palette.outline),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    if (isUnread)
                      Container(
                        margin: const EdgeInsets.only(left: 6, top: 4),
                        width: 8,
                        height: 8,
                        decoration: BoxDecoration(
                          color: dotColor,
                          shape: BoxShape.circle,
                        ),
                      ),
                    if (trailingBadge != null)
                      Container(
                        margin: const EdgeInsets.only(left: 6),
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          color: const Color(0xFFD1FAE5),
                          borderRadius: BorderRadius.circular(AppRadius.pill),
                        ),
                        child: Text(
                          trailingBadge,
                          style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Color(0xFF006C49)),
                        ),
                      ),
                  ],
                ),
                ?action,
              ],
            ),
          ),
        ),
      ),
    );
  }
}
