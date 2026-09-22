import 'package:expense_tracker/core/services/app_preference_helper.dart';
import 'package:expense_tracker/core/services/app_number_formatter.dart';
import 'package:expense_tracker/core/utils/app_theme.dart';
import 'package:expense_tracker/features/setting/screens/providers/setting_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('light theme uses the configured palette', () {
    final theme = AppTheme.lightTheme;
    final colors = theme.colorScheme;

    expect(colors.primary, const Color(0xFF1A9E6E));
    expect(theme.scaffoldBackgroundColor, const Color(0xFFF4F6FA));
    expect(colors.surface, const Color(0xFFFFFFFF));
    expect(colors.surfaceContainerHigh, const Color(0xFFF1F5F9));
    expect(colors.surfaceContainerHighest, const Color(0xFFE8EDF5));
    expect(colors.outline, const Color(0xFFDDE3EE));
    expect(colors.onSurface, const Color(0xFF0F172A));
    expect(colors.onSurfaceVariant, const Color(0xFF475569));
    expect(
      theme.inputDecorationTheme.hintStyle?.color,
      const Color(0xFF94A3B8),
    );
    expect(colors.secondaryContainer, const Color(0xFFF0FAF6));
    expect(colors.outlineVariant, const Color(0xFFD1EEE4));
    expect(colors.error, const Color(0xFFDC2626));
    expect(colors.tertiary, const Color(0xFFD97706));
  });

  test('selected theme mode is persisted', () async {
    SharedPreferences.setMockInitialValues({});
    await SharedPreferencesUtils.intiSharePreference();
    final container = ProviderContainer();
    addTearDown(container.dispose);

    expect(container.read(themeModeProvider), ThemeMode.dark);
    await container
        .read(themeModeProvider.notifier)
        .setThemeMode(ThemeMode.light);

    expect(container.read(themeModeProvider), ThemeMode.light);
    final preferences = await SharedPreferences.getInstance();
    expect(preferences.getString('themeMode'), 'light');
  });

  test('selected currency is persisted', () async {
    SharedPreferences.setMockInitialValues({});
    await SharedPreferencesUtils.intiSharePreference();
    final container = ProviderContainer();
    addTearDown(container.dispose);

    expect(container.read(currencyProvider), AppCurrency.baht);
    await container
        .read(currencyProvider.notifier)
        .setCurrency(AppCurrency.mmk);

    expect(container.read(currencyProvider), AppCurrency.mmk);
    final preferences = await SharedPreferences.getInstance();
    expect(preferences.getString('currency'), 'mmk');
  });

  testWidgets('currency scope changes the formatted symbol', (tester) async {
    late BuildContext scopedContext;
    await tester.pumpWidget(
      AppCurrencyScope(
        currency: AppCurrency.dollar,
        child: Builder(
          builder: (context) {
            scopedContext = context;
            return const SizedBox();
          },
        ),
      ),
    );

    expect(
      NumberFormatService.formatCurrency(scopedContext, 1234.5),
      r'$ 1,234.50',
    );
  });
}
