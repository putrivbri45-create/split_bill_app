import 'package:flutter_test/flutter_test.dart';
import 'package:patungan/core/algorithm/balance_calculator.dart';
import 'package:patungan/core/database/database_service.dart';
import 'package:patungan/features/expenses/data/expense_repository.dart';
import 'package:patungan/features/expenses/domain/models/expense_model.dart';
import 'package:patungan/features/groups/data/group_repository.dart';
import 'package:patungan/features/groups/domain/models/group_model.dart';
import 'package:patungan/features/settlements/data/settlement_repository.dart';
import 'package:patungan/features/settlements/domain/models/settlement_model.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('Balance Rules & Invariant Tests (User Requirements)', () {
    test('Rule 1: Anggota yang menalangi uang lebih besar dari tanggungannya mendapatkan saldo Uang yang Harus Diterima', () {
      final member = GroupMemberModel(
        id: 'm1',
        groupId: 'g1',
        userId: 'u1',
        userName: 'Alice',
        netBalance: 75000.0,
      );

      expect(member.shouldReceive, isTrue);
      expect(member.shouldPay, isFalse);
      expect(member.isSettled, isFalse);
      expect(member.amountToReceive, 75000.0);
      expect(member.amountToPay, 0.0);
      expect(member.balanceTypeLabel, 'Uang yang Harus Diterima');
    });

    test('Rule 2: Anggota yang tidak menalangi uang dan belum membayar tagihannya mendapatkan saldo Uang yang Harus Dibayar', () {
      final member = GroupMemberModel(
        id: 'm2',
        groupId: 'g1',
        userId: 'u2',
        userName: 'Bob',
        netBalance: -50000.0,
      );

      expect(member.shouldReceive, isFalse);
      expect(member.shouldPay, isTrue);
      expect(member.isSettled, isFalse);
      expect(member.amountToReceive, 0.0);
      expect(member.amountToPay, 50000.0);
      expect(member.balanceTypeLabel, 'Uang yang Harus Dibayar');
    });

    test('Rule 3: Anggota yang membayar tepat sesuai tanggungannya memiliki saldo Rp0 (Lunas)', () {
      final member = GroupMemberModel(
        id: 'm3',
        groupId: 'g1',
        userId: 'u3',
        userName: 'Charlie',
        netBalance: 0.0,
      );

      expect(member.shouldReceive, isFalse);
      expect(member.shouldPay, isFalse);
      expect(member.isSettled, isTrue);
      expect(member.amountToReceive, 0.0);
      expect(member.amountToPay, 0.0);
      expect(member.balanceTypeLabel, 'Lunas');
    });

    test('Rule 4 & 5: Total uang yang harus dibayar sama dengan total uang yang harus diterima', () {
      final group = GroupModel(
        id: 'g1',
        name: 'Trip Bali',
        category: 'Liburan',
        createdBy: 'u1',
        createdAt: DateTime.now(),
        members: const [
          GroupMemberModel(id: 'm1', groupId: 'g1', userId: 'u1', userName: 'Alice', netBalance: 120000.0),
          GroupMemberModel(id: 'm2', groupId: 'g1', userId: 'u2', userName: 'Bob', netBalance: -70000.0),
          GroupMemberModel(id: 'm3', groupId: 'g1', userId: 'u3', userName: 'Charlie', netBalance: -50000.0),
          GroupMemberModel(id: 'm4', groupId: 'g1', userId: 'u4', userName: 'David', netBalance: 0.0),
        ],
      );

      expect(group.totalToReceive, 120000.0);
      expect(group.totalToPay, 120000.0);
      expect(group.totalToReceive, equals(group.totalToPay));
    });

    test('Rule 6: Rumus Saldo = Total pembayaran aktual - Total tanggungan dengan pelunasan', () {
      // 3 members: A, B, C
      // Expense: A pays Rp 300.000 for dinner split equally (A: 100k, B: 100k, C: 100k)
      // Tanggungan: A=100k, B=100k, C=100k
      // Pembayaran aktual: A=300k, B=0, C=0
      // Saldo awal: A = +200k, B = -100k, C = -100k
      //
      // Pelunasan: B pays A Rp 100.000 (status: COMPLETED)
      // Pembayaran aktual baru:
      // A = 300k ditalangi - 100k pelunasan diterima = net 200k - 100k = +100k
      // B = 0 ditalangi + 100k pelunasan dikirim = 100k aktual - 100k tanggungan = 0
      // C = 0 ditalangi + 0 pelunasan = -100k
      final expenses = [
        ExpenseModel(
          id: 'exp1',
          groupId: 'g1',
          payerId: 'uA',
          payerName: 'Alice',
          title: 'Dinner Seafood',
          totalAmount: 300000,
          expenseDate: DateTime.now(),
          createdAt: DateTime.now(),
          splits: const [
            ExpenseSplitModel(id: 's1', expenseId: 'exp1', userId: 'uA', userName: 'Alice', amountOwed: 100000),
            ExpenseSplitModel(id: 's2', expenseId: 'exp1', userId: 'uB', userName: 'Bob', amountOwed: 100000),
            ExpenseSplitModel(id: 's3', expenseId: 'exp1', userId: 'uC', userName: 'Charlie', amountOwed: 100000),
          ],
        ),
      ];

      final settlements = [
        SettlementModel(
          id: 'stl1',
          groupId: 'g1',
          debtorId: 'uB',
          debtorName: 'Bob',
          creditorId: 'uA',
          creditorName: 'Alice',
          amount: 100000,
          status: 'COMPLETED',
          settledAt: DateTime.now(),
        ),
      ];

      final balances = BalanceCalculator.netBalances(
        memberIds: ['uA', 'uB', 'uC'],
        expenses: expenses,
        settlements: settlements,
      );

      // Alice: should receive 100.000
      expect(balances['uA'], 100000.0);
      // Bob: settled (Rp 0)
      expect(balances['uB'], 0.0);
      // Charlie: should pay 100.000 (-100.000)
      expect(balances['uC'], -100000.0);

      // Invariant check: sum of all balances == 0
      final sum = balances.values.fold<double>(0.0, (acc, val) => acc + val);
      expect(sum.abs() < 0.001, isTrue);
    });
  });

  group('Database End-to-End Calculation Test', () {
    late DatabaseService db;
    late GroupRepository groupRepo;
    late ExpenseRepository expenseRepo;
    late SettlementRepository settlementRepo;

    setUp(() async {
      db = DatabaseService.instance;
      await db.init();
      groupRepo = GroupRepositoryImpl();
      expenseRepo = ExpenseRepositoryImpl();
      settlementRepo = SettlementRepositoryImpl();
    });

    test('Accurately computes balances from SQLite database with multiple members and settlements', () async {
      final ts = DateTime.now().microsecondsSinceEpoch;

      // 1. Create a test group
      final group = await groupRepo.createGroup(
        name: 'Uji Saldo Lengkap $ts',
        category: 'Kuliner',
        iconName: 'restaurant',
        createdBy: 'user-putri-01',
        members: const [
          GroupMemberModel(id: 'm1', groupId: '', userId: 'user-putri-01', userName: 'Putri'),
          GroupMemberModel(id: 'm2', groupId: '', userId: 'user-budi-03', userName: 'Budi'),
          GroupMemberModel(id: 'm3', groupId: '', userId: 'user-citra-04', userName: 'Citra'),
        ],
      );

      // 2. Add an expense: Budi pays 300.000, split 100.000 each
      final exp = ExpenseModel(
        id: 'exp-$ts',
        groupId: group.id,
        payerId: 'user-budi-03',
        payerName: 'Budi',
        title: 'Traktir Bakso & Minum',
        totalAmount: 300000,
        expenseDate: DateTime.now(),
        createdAt: DateTime.now(),
        splits: [
          ExpenseSplitModel(id: 'sp1-$ts', expenseId: 'exp-$ts', userId: 'user-putri-01', userName: 'Putri', amountOwed: 100000),
          ExpenseSplitModel(id: 'sp2-$ts', expenseId: 'exp-$ts', userId: 'user-budi-03', userName: 'Budi', amountOwed: 100000),
          ExpenseSplitModel(id: 'sp3-$ts', expenseId: 'exp-$ts', userId: 'user-citra-04', userName: 'Citra', amountOwed: 100000),
        ],
      );
      await expenseRepo.addExpense(exp);

      // Verify balances before settlement
      var updatedGroups = await groupRepo.getGroups();
      var g = updatedGroups.firstWhere((item) => item.id == group.id);

      var putri = g.members.firstWhere((m) => m.userId == 'user-putri-01');
      var budi = g.members.firstWhere((m) => m.userId == 'user-budi-03');
      var citra = g.members.firstWhere((m) => m.userId == 'user-citra-04');

      // Budi paid 300k, owes 100k => +200k (Harus Diterima)
      expect(budi.netBalance, 200000.0);
      expect(budi.shouldReceive, isTrue);
      expect(budi.balanceTypeLabel, 'Uang yang Harus Diterima');

      // Putri paid 0, owes 100k => -100k (Harus Dibayar)
      expect(putri.netBalance, -100000.0);
      expect(putri.shouldPay, isTrue);
      expect(putri.balanceTypeLabel, 'Uang yang Harus Dibayar');

      // Citra paid 0, owes 100k => -100k (Harus Dibayar)
      expect(citra.netBalance, -100000.0);
      expect(citra.shouldPay, isTrue);
      expect(citra.balanceTypeLabel, 'Uang yang Harus Dibayar');

      // Invariant: totalToReceive == totalToPay
      expect(g.totalToReceive, 200000.0);
      expect(g.totalToPay, 200000.0);

      // 3. Putri settles 100.000 to Budi
      final stl = SettlementModel(
        id: 'stl-$ts',
        groupId: group.id,
        debtorId: 'user-putri-01',
        debtorName: 'Putri',
        creditorId: 'user-budi-03',
        creditorName: 'Budi',
        amount: 100000,
        status: 'COMPLETED',
        method: 'QRIS',
        settledAt: DateTime.now(),
      );
      await settlementRepo.recordSettlement(stl);

      // Verify balances after settlement
      updatedGroups = await groupRepo.getGroups();
      g = updatedGroups.firstWhere((item) => item.id == group.id);

      putri = g.members.firstWhere((m) => m.userId == 'user-putri-01');
      budi = g.members.firstWhere((m) => m.userId == 'user-budi-03');
      citra = g.members.firstWhere((m) => m.userId == 'user-citra-04');

      // Putri paid full share => Rp 0 (Lunas)
      expect(putri.netBalance, 0.0);
      expect(putri.isSettled, isTrue);
      expect(putri.balanceTypeLabel, 'Lunas');

      // Budi received 100k => now only needs to receive 100k (+100k)
      expect(budi.netBalance, 100000.0);
      expect(budi.shouldReceive, isTrue);
      expect(budi.amountToReceive, 100000.0);

      // Citra has not settled => still owes 100k (-100k)
      expect(citra.netBalance, -100000.0);
      expect(citra.shouldPay, isTrue);
      expect(citra.amountToPay, 100000.0);

      // Invariant: totalToReceive == totalToPay (100.000 == 100.000)
      expect(g.totalToReceive, 100000.0);
      expect(g.totalToPay, 100000.0);
    });
  });
}

