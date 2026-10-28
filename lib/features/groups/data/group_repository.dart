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
    if (_db.isConfigured) {
      try {
        final res = await _db.query(
          "SELECT id, name, category, icon_name, created_by, created_at, description FROM groups ORDER BY created_at DESC;",
        );
        if (res.isNotEmpty) {
          final List<GroupModel> groups = [];
          for (final row in res) {
            final gid = row[0].toString();
            // Fetch members
            final memRes = await _db.executeParams(
              "SELECT id, group_id, user_id, role, display_name, phone_number FROM group_members WHERE group_id = \$1;",
              [gid],
            );
            final members = memRes.map((m) => GroupMemberModel(
              id: m[0].toString(),
              groupId: m[1].toString(),
              userId: m[2].toString(),
              role: m[3]?.toString() ?? 'member',
              userName: m[4]?.toString() ?? 'Member',
              phoneNumber: m[5]?.toString(),
            )).toList();

            groups.add(GroupModel(
              id: gid,
              name: row[1].toString(),
              category: row[2]?.toString() ?? 'Makanan',
              iconName: row[3]?.toString() ?? 'restaurant',
              createdBy: row[4]?.toString() ?? '',
              createdAt: row[5] != null ? DateTime.tryParse(row[5].toString()) ?? DateTime.now() : DateTime.now(),
              description: row[6]?.toString(),
              memberCount: members.length,
              members: members,
            ));
          }
          return groups;
        }
      } catch (_) {
        // Fallback to local
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
}
