import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:patungan/config/theme.dart';
import 'package:patungan/shared/widgets/balance_card.dart';
import 'package:patungan/shared/widgets/group_card.dart';
import 'package:patungan/shared/widgets/custom_button.dart';
import 'package:patungan/features/groups/domain/models/group_model.dart';

void main() {
  setUp(() {
    AppTheme.useGoogleFonts = false;
  });

  Widget createTestWidget(Widget child) {
    return MaterialApp(
      theme: AppTheme.lightTheme,
      home: Scaffold(body: Center(child: child)),
    );
  }

  testWidgets('BalanceCard renders amount and positive balance correctly', (WidgetTester tester) async {
    await tester.pumpWidget(
      createTestWidget(
        const Row(
          children: [
            BalanceCard(
              type: BalanceCardType.credit,
              amount: 150000.0,
              count: 2,
            ),
          ],
        ),
      ),
    );

    expect(find.text('Kamu harus terima'), findsOneWidget);
    expect(find.text('Rp150.000'), findsOneWidget);
    expect(find.text('2 piutang'), findsOneWidget);
  });

  testWidgets('BalanceCard renders negative debt balance correctly', (WidgetTester tester) async {
    await tester.pumpWidget(
      createTestWidget(
        const Row(
          children: [
            BalanceCard(
              type: BalanceCardType.debt,
              amount: 75000.0,
              count: 1,
            ),
          ],
        ),
      ),
    );

    expect(find.text('Kamu harus bayar'), findsOneWidget);
    expect(find.text('Rp75.000'), findsOneWidget);
    expect(find.text('1 tagihan'), findsOneWidget);
  });

  testWidgets('CustomButton renders label and responds to tap', (WidgetTester tester) async {
    bool tapped = false;
    await tester.pumpWidget(
      createTestWidget(
        CustomButton(
          text: 'Hitung Split Bill',
          onPressed: () {
            tapped = true;
          },
        ),
      ),
    );

    expect(find.text('Hitung Split Bill'), findsOneWidget);
    await tester.tap(find.byType(CustomButton));
    expect(tapped, isTrue);
  });

  testWidgets('GroupCard displays group title, members count, and status badge', (WidgetTester tester) async {
    final mockGroup = GroupModel(
      id: 'grp-test',
      name: 'Liburan Bali 2026',
      description: 'Trip akhir pekan',
      category: 'Liburan',
      createdBy: 'user-1',
      createdAt: DateTime.now(),
      memberCount: 2,
      members: const [
        GroupMemberModel(id: 'm-1', groupId: 'grp-test', userId: 'user-1', userName: 'Budi'),
        GroupMemberModel(id: 'm-2', groupId: 'grp-test', userId: 'user-2', userName: 'Ani'),
      ],
      totalSpending: 450000.0,
      userCredit: 150000.0,
    );

    await tester.pumpWidget(
      createTestWidget(
        GroupCard(
          group: mockGroup,
          onTap: () {},
        ),
      ),
    );

    expect(find.text('Liburan Bali 2026'), findsOneWidget);
    expect(find.text('Rp150.000 harus diterima'), findsOneWidget);
    expect(find.textContaining('2 anggota'), findsOneWidget);
  });
}
