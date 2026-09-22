import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/services/app_preference_helper.dart';
import '../../../../core/services/app_number_formatter.dart';

const String _themeModePreferenceKey = 'themeMode';
const String _currencyPreferenceKey = 'currency';

final themeModeProvider = NotifierProvider<ThemeModeNotifier, ThemeMode>(
  ThemeModeNotifier.new,
);

class ThemeModeNotifier extends Notifier<ThemeMode> {
  @override
  ThemeMode build() {
    final savedMode = SharedPreferencesUtils.getString(
      _themeModePreferenceKey,
      ThemeMode.dark.name,
    );
    return ThemeMode.values.firstWhere(
      (mode) => mode.name == savedMode,
      orElse: () => ThemeMode.dark,
    );
  }

  Future<void> setThemeMode(ThemeMode mode) async {
    if (state == mode) return;
    state = mode;
    await SharedPreferencesUtils.setString(_themeModePreferenceKey, mode.name);
  }
}

final currencyProvider = NotifierProvider<CurrencyNotifier, AppCurrency>(
  CurrencyNotifier.new,
);

class CurrencyNotifier extends Notifier<AppCurrency> {
  @override
  AppCurrency build() {
    final savedCurrency = SharedPreferencesUtils.getString(
      _currencyPreferenceKey,
      AppCurrency.baht.name,
    );
    return AppCurrency.values.firstWhere(
      (currency) => currency.name == savedCurrency,
      orElse: () => AppCurrency.baht,
    );
  }

  Future<void> setCurrency(AppCurrency currency) async {
    if (state == currency) return;
    state = currency;
    await SharedPreferencesUtils.setString(
      _currencyPreferenceKey,
      currency.name,
    );
  }
}
