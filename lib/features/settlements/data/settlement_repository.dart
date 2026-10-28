import 'package:uuid/uuid.dart';
import '../../../core/database/database_service.dart';
import '../domain/models/settlement_model.dart';

abstract class SettlementRepository {
  Future<List<SettlementModel>> getSettlementsByGroup(String groupId);
  Future<List<SettlementModel>> getAllSettlements();
  Future<SettlementModel> recordSettlement(SettlementModel settlement);
}

class SettlementRepositoryImpl implements SettlementRepository {
  final DatabaseService _db = DatabaseService.instance;
  final Uuid _uuid = const Uuid();

  // Mock settlements matching Stitch design #8 (Split Summary)
  static final List<SettlementModel> _mockSettlements = [
    SettlementModel(
      id: 'stl-1',
      groupId: 'group-makan-malam-reuni',
      debtorId: 'user-budi-03',
      debtorName: 'Budi',
      creditorId: 'user-ani-02',
      creditorName: 'Ani',
      amount: 50000.0,
      status: 'PENDING',
      settledAt: DateTime.now().subtract(const Duration(hours: 2)),
    ),
    SettlementModel(
      id: 'stl-2',
      groupId: 'group-makan-malam-reuni',
      debtorId: 'user-citra-04',
      debtorName: 'Citra',
      creditorId: 'user-ani-02',
      creditorName: 'Ani',
      amount: 75000.0,
      status: 'PENDING',
      settledAt: DateTime.now().subtract(const Duration(hours: 2)),
    ),
    SettlementModel(
      id: 'stl-3',
      groupId: 'group-makan-malam-reuni',
      debtorId: 'user-putri-01',
      debtorName: 'Putri (Anda)',
      creditorId: 'user-budi-03',
      creditorName: 'Budi',
      amount: 25000.0,
      status: 'COMPLETED',
      method: 'QRIS / Transfer BCA',
      settledAt: DateTime.now().subtract(const Duration(minutes: 45)),
    ),
    SettlementModel(
      id: 'stl-4',
      groupId: 'group-liburan-jogja',
      debtorId: 'user-budi-03',
      debtorName: 'Budi',
      creditorId: 'user-putri-01',
      creditorName: 'Putri (Anda)',
      amount: 75000.0,
      status: 'COMPLETED',
      method: 'QRIS Gopay',
      settledAt: DateTime.now().subtract(const Duration(days: 1)),
    ),
  ];

  @override
  Future<List<SettlementModel>> getSettlementsByGroup(String groupId) async {
    if (_db.isConfigured) {
      try {
        final res = await _db.executeParams(
          "SELECT id, group_id, debtor_id, creditor_id, amount, proof_image_url, status, settled_at, method FROM settlements WHERE group_id = \$1 ORDER BY settled_at DESC;",
          [groupId],
        );
        if (res.isNotEmpty) {
          return res.map((r) => SettlementModel(
            id: r[0].toString(),
            groupId: r[1].toString(),
            debtorId: r[2].toString(),
            debtorName: 'Debitur',
            creditorId: r[3].toString(),
            creditorName: 'Kreditur',
            amount: double.tryParse(r[4]?.toString() ?? '0') ?? 0.0,
            proofImageUrl: r[5]?.toString(),
            status: r[6]?.toString() ?? 'COMPLETED',
            settledAt: r[7] != null ? DateTime.tryParse(r[7].toString()) ?? DateTime.now() : DateTime.now(),
            method: r[8]?.toString(),
          )).toList();
        }
      } catch (_) {}
    }
    return _mockSettlements.where((s) => s.groupId == groupId).toList();
  }

  @override
  Future<List<SettlementModel>> getAllSettlements() async {
    return List.from(_mockSettlements);
  }

  @override
  Future<SettlementModel> recordSettlement(SettlementModel settlement) async {
    final newId = settlement.id.isEmpty ? 'stl-${_uuid.v4().substring(0, 8)}' : settlement.id;
    final model = settlement.copyWith(id: newId);

    // Update or insert
    final existingIdx = _mockSettlements.indexWhere((s) => s.id == newId);
    if (existingIdx != -1) {
      _mockSettlements[existingIdx] = model;
    } else {
      _mockSettlements.insert(0, model);
    }

    if (_db.isConfigured) {
      try {
        await _db.executeParams(
          "INSERT INTO settlements (id, group_id, debtor_id, creditor_id, amount, proof_image_url, status, settled_at, method) VALUES (\$1, \$2, \$3, \$4, \$5, \$6, \$7, \$8, \$9);",
          [
            newId,
            model.groupId,
            model.debtorId,
            model.creditorId,
            model.amount,
            model.proofImageUrl,
            model.status,
            model.settledAt,
            model.method,
          ],
        );
      } catch (_) {}
    }

    return model;
  }
}
