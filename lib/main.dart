import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'config/routes.dart';
import 'config/theme.dart';
import 'features/auth/data/auth_repository.dart';
import 'features/auth/presentation/bloc/auth_bloc.dart';
import 'features/groups/data/group_repository.dart';
import 'features/groups/presentation/bloc/group_bloc.dart';
import 'features/expenses/data/expense_repository.dart';
import 'features/expenses/presentation/bloc/expense_bloc.dart';
import 'features/settlements/data/settlement_repository.dart';
import 'features/settlements/presentation/bloc/settlement_bloc.dart';
import 'features/settings/presentation/cubit/settings_cubit.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Load environment variables gracefully
  try {
    await dotenv.load(fileName: '.env');
  } catch (_) {
    // If .env is missing or unreadable, default safe fallback is handled in services
  }

  runApp(const SplitBillApp());
}

class SplitBillApp extends StatelessWidget {
  const SplitBillApp({super.key});

  @override
  Widget build(BuildContext context) {
    // Repositories
    final authRepository = AuthRepositoryImpl();
    final groupRepository = GroupRepositoryImpl();
    final expenseRepository = ExpenseRepositoryImpl();
    final settlementRepository = SettlementRepositoryImpl();

    return MultiRepositoryProvider(
      providers: [
        RepositoryProvider<AuthRepository>.value(value: authRepository),
        RepositoryProvider<GroupRepository>.value(value: groupRepository),
        RepositoryProvider<ExpenseRepository>.value(value: expenseRepository),
        RepositoryProvider<SettlementRepository>.value(value: settlementRepository),
      ],
      child: MultiBlocProvider(
        providers: [
          BlocProvider<SettingsCubit>(
            create: (_) => SettingsCubit(),
          ),
          BlocProvider<AuthBloc>(
            create: (_) => AuthBloc(authRepository: authRepository),
          ),
          BlocProvider<GroupBloc>(
            create: (_) => GroupBloc(groupRepository: groupRepository),
          ),
          BlocProvider<ExpenseBloc>(
            create: (_) => ExpenseBloc(expenseRepository: expenseRepository),
          ),
          BlocProvider<SettlementBloc>(
            create: (_) => SettlementBloc(settlementRepository: settlementRepository),
          ),
        ],
        child: BlocBuilder<SettingsCubit, SettingsState>(
          builder: (context, settingsState) {
            return MaterialApp(
              title: 'Split Bill',
              debugShowCheckedModeBanner: false,
              themeMode: settingsState.themeMode,
              theme: AppTheme.lightTheme,
              darkTheme: AppTheme.darkTheme,
              initialRoute: AppRoutes.splash,
              onGenerateRoute: AppRoutes.onGenerateRoute,
            );
          },
        ),
      ),
    );
  }
}
