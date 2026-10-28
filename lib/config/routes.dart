import 'package:flutter/material.dart';
import '../features/splash/presentation/screens/splash_screen.dart';
import '../features/onboarding/presentation/screens/onboarding_screen.dart';
import '../features/auth/presentation/screens/login_register_screen.dart';
import '../features/dashboard/presentation/screens/main_navigation_screen.dart';
import '../features/groups/presentation/screens/create_group_screen.dart';
import '../features/groups/presentation/screens/group_detail_screen.dart';
import '../features/groups/presentation/screens/groups_list_screen.dart';
import '../features/expenses/presentation/screens/add_expense_screen.dart';
import '../features/settlements/presentation/screens/split_summary_screen.dart';
import '../features/history/presentation/screens/transaction_history_screen.dart';
import '../features/profile/presentation/screens/user_profile_screen.dart';
import '../features/profile/presentation/screens/edit_profile_screen.dart';
import '../features/notifications/presentation/screens/notifications_screen.dart';
import '../features/groups/domain/models/group_model.dart';

class AppRoutes {
  static const String splash = '/';
  static const String onboarding = '/onboarding';
  static const String loginRegister = '/login-register';
  static const String main = '/main';
  static const String createGroup = '/create-group';
  static const String groupDetail = '/group-detail';
  static const String groupsList = '/groups-list';
  static const String addExpense = '/add-expense';
  static const String splitSummary = '/split-summary';
  static const String history = '/history';
  static const String profile = '/profile';
  static const String editProfile = '/edit-profile';
  static const String notifications = '/notifications';

  static Route<dynamic> onGenerateRoute(RouteSettings routeSettings) {
    switch (routeSettings.name) {
      case splash:
        return MaterialPageRoute(builder: (_) => const SplashScreen());
      case onboarding:
        return MaterialPageRoute(builder: (_) => const OnboardingScreen());
      case loginRegister:
        return MaterialPageRoute(builder: (_) => const LoginRegisterScreen());
      case main:
        return MaterialPageRoute(builder: (_) => const MainNavigationScreen());
      case createGroup:
        return MaterialPageRoute(builder: (_) => const CreateGroupScreen());
      case groupsList:
        return MaterialPageRoute(builder: (_) => const GroupsListScreen());
      case groupDetail:
        final group = routeSettings.arguments as GroupModel;
        return MaterialPageRoute(builder: (_) => GroupDetailScreen(group: group));
      case addExpense:
        final group = routeSettings.arguments as GroupModel;
        return MaterialPageRoute(builder: (_) => AddExpenseScreen(group: group));
      case splitSummary:
        final group = routeSettings.arguments as GroupModel;
        return MaterialPageRoute(builder: (_) => SplitSummaryScreen(group: group));
      case history:
        return MaterialPageRoute(builder: (_) => const TransactionHistoryScreen());
      case profile:
        return MaterialPageRoute(builder: (_) => const UserProfileScreen());
      case editProfile:
        return MaterialPageRoute(builder: (_) => const EditProfileScreen());
      case notifications:
        return MaterialPageRoute(builder: (_) => const NotificationsScreen());
      default:
        return MaterialPageRoute(
          builder: (_) => Scaffold(
            body: Center(
              child: Text('Rute tidak ditemukan: ${routeSettings.name}'),
            ),
          ),
        );
    }
  }
}
