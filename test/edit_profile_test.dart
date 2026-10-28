import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:patungan/config/routes.dart';
import 'package:patungan/config/theme.dart';
import 'package:patungan/features/auth/domain/models/user_model.dart';
import 'package:patungan/features/auth/data/auth_repository.dart';
import 'package:patungan/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:patungan/features/groups/data/group_repository.dart';
import 'package:patungan/features/groups/domain/models/group_model.dart';
import 'package:patungan/features/groups/presentation/bloc/group_bloc.dart';
import 'package:patungan/features/profile/presentation/screens/edit_profile_screen.dart';
import 'package:patungan/features/profile/presentation/screens/user_profile_screen.dart';

class MockAuthRepository implements AuthRepository {
  @override
  Future<UserModel> login(String identifier, String password) async {
    throw UnimplementedError();
  }

  @override
  Future<UserModel> register(String fullName, String phone, String email, String password) async {
    throw UnimplementedError();
  }

  @override
  Future<UserModel?> getCurrentUser() async {
    return UserModel(
      id: 'test-user',
      email: 'putrivbri@splitbill.id',
      fullName: 'putrivbri',
      phoneNumber: '081234567890',
      createdAt: DateTime.now(),
    );
  }

  @override
  Future<UserModel> updateProfile({
    required String fullName,
    required String phone,
    required String email,
    String? avatarUrl,
  }) async {
    return UserModel(
      id: 'test-user',
      email: email,
      fullName: fullName,
      phoneNumber: phone,
      avatarUrl: avatarUrl,
      createdAt: DateTime.now(),
    );
  }

  @override
  Future<void> logout() async {}
}

class MockGroupRepository implements GroupRepository {
  @override
  Future<List<GroupModel>> getGroups({String? userId}) async => [];
  @override
  Future<GroupModel> getGroupById(String id) async => throw UnimplementedError();
  @override
  Future<GroupModel> createGroup({
    required String name,
    required String category,
    required String iconName,
    required String createdBy,
    String? description,
    required List<GroupMemberModel> members,
  }) async => throw UnimplementedError();
  @override
  Future<void> addMember(String groupId, GroupMemberModel member) async {}
}

void main() {
  setUp(() {
    AppTheme.useGoogleFonts = false;
  });

  testWidgets('EditProfileScreen renders all form fields and buttons properly', (WidgetTester tester) async {
    final mockRepo = MockAuthRepository();
    final authBloc = AuthBloc(authRepository: mockRepo);
    authBloc.emit(
      Authenticated(
        UserModel(
          id: 'test-user',
          email: 'putrivbri@splitbill.id',
          fullName: 'putrivbri',
          phoneNumber: '081234567890',
          createdAt: DateTime.now(),
        ),
      ),
    );

    await tester.pumpWidget(
      BlocProvider<AuthBloc>.value(
        value: authBloc,
        child: MaterialApp(
          theme: AppTheme.lightTheme,
          home: const EditProfileScreen(),
        ),
      ),
    );

    expect(find.text('Edit Profil'), findsWidgets);
    expect(find.text('Nama Lengkap'), findsOneWidget);
    expect(find.text('Alamat Email'), findsOneWidget);
    expect(find.text('Nomor Handphone / WhatsApp'), findsOneWidget);
    expect(find.text('Simpan Perubahan'), findsOneWidget);
    expect(find.text('Batal'), findsOneWidget);
    expect(find.text('Ganti Avatar'), findsOneWidget);
  });

  testWidgets('UserProfileScreen navigates to EditProfileScreen when Edit Profil is tapped', (WidgetTester tester) async {
    final mockAuthRepo = MockAuthRepository();
    final authBloc = AuthBloc(authRepository: mockAuthRepo);
    authBloc.emit(
      Authenticated(
        UserModel(
          id: 'test-user',
          email: 'putrivbri@splitbill.id',
          fullName: 'putrivbri',
          phoneNumber: '081234567890',
          createdAt: DateTime.now(),
        ),
      ),
    );

    final mockGroupRepo = MockGroupRepository();
    final groupBloc = GroupBloc(groupRepository: mockGroupRepo);

    await tester.pumpWidget(
      MultiBlocProvider(
        providers: [
          BlocProvider<AuthBloc>.value(value: authBloc),
          BlocProvider<GroupBloc>.value(value: groupBloc),
        ],
        child: MaterialApp(
          theme: AppTheme.lightTheme,
          home: const UserProfileScreen(),
          onGenerateRoute: AppRoutes.onGenerateRoute,
        ),
      ),
    );

    expect(find.textContaining('Profil Saya'), findsOneWidget);
    final editButtons = find.text('Edit Profil');
    expect(editButtons, findsWidgets);

    // Tap the first Edit Profil button
    await tester.tap(editButtons.first);
    await tester.pumpAndSettle();

    // Verify EditProfileScreen is now displayed
    expect(find.byType(EditProfileScreen), findsOneWidget);
    expect(find.text('INFORMASI PRIBADI'), findsOneWidget);
    expect(find.text('METODE TERIMA DANA (SETTLEMENT)'), findsOneWidget);
  });
}
