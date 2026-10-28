import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SettingsState extends Equatable {
  final ThemeMode themeMode;
  final bool isBiometricEnabled;
  final bool isPushEnabled;
  final bool isAutoReminderEnabled;
  final String currency;
  final String language;

  const SettingsState({
    this.themeMode = ThemeMode.light,
    this.isBiometricEnabled = true,
    this.isPushEnabled = true,
    this.isAutoReminderEnabled = true,
    this.currency = 'IDR (Rp)',
    this.language = 'Bahasa Indonesia',
  });

  bool get isDarkMode => themeMode == ThemeMode.dark;

  SettingsState copyWith({
    ThemeMode? themeMode,
    bool? isBiometricEnabled,
    bool? isPushEnabled,
    bool? isAutoReminderEnabled,
    String? currency,
    String? language,
  }) {
    return SettingsState(
      themeMode: themeMode ?? this.themeMode,
      isBiometricEnabled: isBiometricEnabled ?? this.isBiometricEnabled,
      isPushEnabled: isPushEnabled ?? this.isPushEnabled,
      isAutoReminderEnabled: isAutoReminderEnabled ?? this.isAutoReminderEnabled,
      currency: currency ?? this.currency,
      language: language ?? this.language,
    );
  }

  @override
  List<Object?> get props => [
        themeMode,
        isBiometricEnabled,
        isPushEnabled,
        isAutoReminderEnabled,
        currency,
        language,
      ];
}

class SettingsCubit extends Cubit<SettingsState> {
  SettingsCubit() : super(const SettingsState()) {
    _loadPreferences();
  }

  static const String _keyTheme = 'pref_theme_mode';
  static const String _keyBiometric = 'pref_biometric';
  static const String _keyPush = 'pref_push';
  static const String _keyAutoReminder = 'pref_auto_reminder';

  Future<void> _loadPreferences() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final isDark = prefs.getBool(_keyTheme) ?? false;
      final biometric = prefs.getBool(_keyBiometric) ?? true;
      final push = prefs.getBool(_keyPush) ?? true;
      final reminder = prefs.getBool(_keyAutoReminder) ?? true;

      emit(state.copyWith(
        themeMode: isDark ? ThemeMode.dark : ThemeMode.light,
        isBiometricEnabled: biometric,
        isPushEnabled: push,
        isAutoReminderEnabled: reminder,
      ));
    } catch (_) {}
  }

  Future<void> toggleTheme(bool isDark) async {
    emit(state.copyWith(themeMode: isDark ? ThemeMode.dark : ThemeMode.light));
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_keyTheme, isDark);
  }

  Future<void> toggleBiometric(bool enabled) async {
    emit(state.copyWith(isBiometricEnabled: enabled));
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_keyBiometric, enabled);
  }

  Future<void> togglePush(bool enabled) async {
    emit(state.copyWith(isPushEnabled: enabled));
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_keyPush, enabled);
  }

  Future<void> toggleAutoReminder(bool enabled) async {
    emit(state.copyWith(isAutoReminderEnabled: enabled));
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_keyAutoReminder, enabled);
  }
}
