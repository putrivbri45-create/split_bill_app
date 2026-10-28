import 'package:flutter/foundation.dart';
import 'package:uuid/uuid.dart';
import '../../../core/database/database_service.dart';
import '../domain/models/group_model.dart';

abstract class GroupRepository {
  Future<List<GroupModel>> getGroups({String? userId});
  Future<GroupModel> getGroupById(String id);
  Future<GroupModel> createGroup({
    required String name,
    required String category,
    required String iconName,
    required String createdBy,
    String? description,
    required List<GroupMemberModel> members,
  });
  Future<void> addMember(String groupId, GroupMemberModel member);
  Future<void> deleteGroup(String id);
}

class GroupRepositoryImpl implements GroupRepository {
  final DatabaseService _db = DatabaseService.instance;
  final Uuid _uuid = const Uuid();

  // In-memory persistent seed matching stitch design mockups
  static final List<GroupModel> _mockGroups = [
    GroupModel(
      id: 'group-makan-malam-reuni',
      name: 'Makan Malam Reuni',
      category: 'Makanan',
      iconName: 'restaurant',
      createdBy: 'user-putri-01',
      createdAt: DateTime.now().subtract(const Duration(hours: 4)),
      memberCount: 4,
      expenseCount: 6,
      totalSpending: 400000.0,
      userDebt: 125000.0,
      userCredit: 0.0,
      description: 'Split bill makan bersama setelah reuni angkatan.',
      members: const [
        GroupMemberModel(
          id: 'mem-1',
          groupId: 'group-makan-malam-reuni',
          userId: 'user-ani-02',
          role: 'admin',
          userName: 'Ani',
          avatarUrl: 'https://images.unsplash.com/photo-1544005313-94ddf0286df2?auto=format&fit=crop&w=200&q=80',
          phoneNumber: '0812-9988-7766',
          netBalance: 125000.0,
        ),
        GroupMemberModel(
          id: 'mem-2',
          groupId: 'group-makan-malam-reuni',
          userId: 'user-budi-03',
          role: 'member',
          userName: 'Budi',
          avatarUrl: 'https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?auto=format&fit=crop&w=200&q=80',
          phoneNumber: '0813-1122-3344',
          netBalance: -50000.0,
        ),
        GroupMemberModel(
          id: 'mem-3',
          groupId: 'group-makan-malam-reuni',
          userId: 'user-citra-04',
          role: 'member',
          userName: 'Citra',
          avatarUrl: 'https://images.unsplash.com/photo-1517841905240-472988babdf9?auto=format&fit=crop&w=200&q=80',
          phoneNumber: '0815-5566-7788',
          netBalance: -75000.0,
        ),
        GroupMemberModel(
          id: 'mem-4',
          groupId: 'group-makan-malam-reuni',
          userId: 'user-putri-01',
          role: 'member',
          userName: 'Putri (Anda)',
          avatarUrl: 'https://images.unsplash.com/photo-1534528741775-53994a69daeb?auto=format&fit=crop&w=200&q=80',
          phoneNumber: '0812-3456-7890',
          netBalance: 0.0,
        ),
      ],
    ),
    GroupModel(
      id: 'group-liburan-jogja',
      name: 'Liburan Jogja',
      category: 'Liburan',
      iconName: 'flight',
      createdBy: 'user-putri-01',
      createdAt: DateTime.now().subtract(const Duration(days: 2)),
      memberCount: 5,
      expenseCount: 12,
      totalSpending: 1250000.0,
      userDebt: 0.0,
      userCredit: 75000.0,
      description: 'Trip akhir pekan ke Malioboro dan pantai Selatan.',
      members: const [
        GroupMemberModel(
          id: 'mem-j1',
          groupId: 'group-liburan-jogja',
          userId: 'user-putri-01',
          role: 'admin',
          userName: 'Putri (Anda)',
          avatarUrl: 'https://images.unsplash.com/photo-1534528741775-53994a69daeb?auto=format&fit=crop&w=200&q=80',
          phoneNumber: '0812-3456-7890',
          netBalance: 75000.0,
        ),
        GroupMemberModel(
          id: 'mem-j2',
          groupId: 'group-liburan-jogja',
          userId: 'user-budi-03',
          role: 'member',
          userName: 'Budi',
          avatarUrl: 'https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?auto=format&fit=crop&w=200&q=80',
          phoneNumber: '0813-1122-3344',
          netBalance: -75000.0,
        ),
        GroupMemberModel(
          id: 'mem-j3',
          groupId: 'group-liburan-jogja',
          userId: 'user-citra-04',
          role: 'member',
          userName: 'Citra',
          avatarUrl: 'https://images.unsplash.com/photo-1517841905240-472988babdf9?auto=format&fit=crop&w=200&q=80',
          phoneNumber: '0815-5566-7788',
          netBalance: 0.0,
        ),
      ],
    ),
    GroupModel(
      id: 'group-kost-bulanan',
      name: 'Kost Bulanan & Wifi',
      category: 'Rumah Tangga',
      iconName: 'home',
      createdBy: 'user-citra-04',
      createdAt: DateTime.now().subtract(const Duration(days: 15)),
      memberCount: 3,
      expenseCount: 4,
      totalSpending: 850000.0,
      userDebt: 0.0,
      userCredit: 0.0,
      description: 'Split bill iuran wifi indihome & air galon bulanan kost.',
      members: const [
        GroupMemberModel(
          id: 'mem-k1',
          groupId: 'group-kost-bulanan',
          userId: 'user-putri-01',
          role: 'member',
          userName: 'Putri (Anda)',
          avatarUrl: 'https://images.unsplash.com/photo-1534528741775-53994a69daeb?auto=format&fit=crop&w=200&q=80',
          phoneNumber: '0812-3456-7890',
          netBalance: 0.0,
        ),
        GroupMemberModel(
          id: 'mem-k2',
          groupId: 'group-kost-bulanan',
          userId: 'user-citra-04',
          role: 'admin',
          userName: 'Citra',
          avatarUrl: 'https://images.unsplash.com/photo-1517841905240-472988babdf9?auto=format&fit=crop&w=200&q=80',
          phoneNumber: '0815-5566-7788',
          netBalance: 0.0,
        ),
      ],
    ),
  ];

  @override
  Future<List<GroupModel>> getGroups({String? userId}) async {
    final currentUserId = userId ?? 'user-putri-01';
    if (_db.isConfigured) {
      try {
        final res = await _db.query(
          "SELECT id, name, category, icon_name, created_by, created_at, description FROM groups ORDER BY created_at DESC;",
        );
        if (res.isNotEmpty) {
          final List<GroupModel> groups = [];
          for (final row in res) {
            final gid = row[0].toString();

            // 1. Fetch members with display name and avatar
            final memRes = await _db.executeParams(
              '''
              SELECT 
                gm.id, gm.group_id, gm.user_id, gm.role, 
                COALESCE(gm.display_name, u.full_name, 'Member') AS name, 
                COALESCE(gm.phone_number, u.phone_number),
                u.avatar_url
              FROM group_members gm
              LEFT JOIN users u ON gm.user_id = u.id
              WHERE gm.group_id = \$1;
              ''',
              [gid],
            );

            // 2. Fetch total spending and expense count from expenses table
            final expStats = await _db.executeParams(
              "SELECT COUNT(*), COALESCE(SUM(total_amount), 0.0) FROM expenses WHERE group_id = \$1;",
              [gid],
            );
            final int expCount = expStats.isNotEmpty ? int.tryParse(expStats.first[0]?.toString() ?? '0') ?? 0 : 0;
            final double totalSpending = expStats.isNotEmpty ? double.tryParse(expStats.first[1]?.toString() ?? '0') ?? 0.0 : 0.0;

            // 3. Compute net balances for members:
            final paidRes = await _db.executeParams(
              "SELECT payer_id, COALESCE(SUM(total_amount), 0.0) FROM expenses WHERE group_id = \$1 GROUP BY payer_id;",
              [gid],
            );
            final Map<String, double> paidMap = {
              for (final r in paidRes) r[0].toString(): double.tryParse(r[1]?.toString() ?? '0') ?? 0.0
            };

            final owedRes = await _db.executeParams(
              '''
              SELECT s.user_id, COALESCE(SUM(s.amount_owed), 0.0) 
              FROM expense_splits s 
              JOIN expenses e ON s.expense_id = e.id 
              WHERE e.group_id = \$1 AND (s.is_settled = 0 OR s.is_settled IS NULL)
              GROUP BY s.user_id;
              ''',
              [gid],
            );
            final Map<String, double> owedMap = {
              for (final r in owedRes) r[0].toString(): double.tryParse(r[1]?.toString() ?? '0') ?? 0.0
            };

            final members = memRes.map((m) {
              final uid = m[2].toString();
              final paid = paidMap[uid] ?? 0.0;
              final owed = owedMap[uid] ?? 0.0;
              final net = paid - owed;

              return GroupMemberModel(
                id: m[0].toString(),
                groupId: m[1].toString(),
                userId: uid,
                role: m[3]?.toString() ?? 'member',
                userName: m[4]?.toString() ?? 'Member',
                phoneNumber: m[5]?.toString(),
                avatarUrl: m[6]?.toString(),
                netBalance: net,
              );
            }).toList();

            // 4. Current user debt and credit for this group
            final userPaid = paidMap[currentUserId] ?? 0.0;
            final userOwed = owedMap[currentUserId] ?? 0.0;
            final userNet = userPaid - userOwed;
            final double userCredit = userNet > 0 ? userNet : 0.0;
            final double userDebt = userNet < 0 ? -userNet : 0.0;

            groups.add(GroupModel(
              id: gid,
              name: row[1].toString(),
              category: row[2]?.toString() ?? 'Makanan',
              iconName: row[3]?.toString() ?? 'restaurant',
              createdBy: row[4]?.toString() ?? '',
              createdAt: row[5] != null ? DateTime.tryParse(row[5].toString()) ?? DateTime.now() : DateTime.now(),
              description: row[6]?.toString(),
              memberCount: members.length,
              expenseCount: expCount,
              totalSpending: totalSpending,
              userDebt: userDebt,
              userCredit: userCredit,
              members: members,
            ));
          }
          return groups;
        } else {
          return [];
        }
      } catch (e) {
        debugPrint('Error getting groups from SQLite: $e');
      }
    }
    return List.from(_mockGroups);
  }

  @override
  Future<GroupModel> getGroupById(String id) async {
    final groups = await getGroups();
    return groups.firstWhere(
      (g) => g.id == id,
      orElse: () => _mockGroups.first,
    );
  }

  @override
  Future<GroupModel> createGroup({
    required String name,
    required String category,
    required String iconName,
    required String createdBy,
    String? description,
    required List<GroupMemberModel> members,
  }) async {
    final newId = 'group-${_uuid.v4().substring(0, 8)}';
    final now = DateTime.now();

    final populatedMembers = members.map((m) {
      return m.copyWith(
        id: m.id.isEmpty ? 'mem-${_uuid.v4().substring(0, 6)}' : m.id,
        groupId: newId,
      );
    }).toList();

    final newGroup = GroupModel(
      id: newId,
      name: name,
      category: category,
      iconName: iconName,
      createdBy: createdBy,
      createdAt: now,
      memberCount: populatedMembers.length,
      expenseCount: 0,
      totalSpending: 0.0,
      userDebt: 0.0,
      userCredit: 0.0,
      description: description,
      members: populatedMembers,
    );

    _mockGroups.insert(0, newGroup);

    if (_db.isConfigured) {
      try {
        await _db.executeParams(
          "INSERT INTO groups (id, name, category, icon_name, created_by, created_at, description) VALUES (\$1, \$2, \$3, \$4, \$5, \$6, \$7);",
          [newId, name, category, iconName, createdBy, now, description],
        );
        for (final m in populatedMembers) {
          await _db.executeParams(
            "INSERT INTO group_members (id, group_id, user_id, role, display_name, phone_number) VALUES (\$1, \$2, \$3, \$4, \$5, \$6);",
            [m.id, newId, m.userId, m.role, m.userName, m.phoneNumber],
          );
        }
      } catch (_) {}
    }

    return newGroup;
  }

  @override
  Future<void> addMember(String groupId, GroupMemberModel member) async {
    final idx = _mockGroups.indexWhere((g) => g.id == groupId);
    if (idx != -1) {
      final existing = _mockGroups[idx];
      final updatedList = List<GroupMemberModel>.from(existing.members)..add(member);
      _mockGroups[idx] = existing.copyWith(
        members: updatedList,
        memberCount: updatedList.length,
      );
    }
  }

  @override
  Future<void> deleteGroup(String id) async {
    _mockGroups.removeWhere((g) => g.id == id);

    if (_db.isConfigured) {
      try {
        await _db.executeParams("DELETE FROM groups WHERE id = \$1;", [id]);
      } catch (_) {}
    }
  }
}
