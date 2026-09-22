import 'package:expense_tracker/features/auth/screens/providers/login_provider_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/providers/navigation_provider.dart';
import '../../../core/services/app_number_formatter.dart';
import '../../../core/services/app_preference_helper.dart';
import '../../../core/utils/app_const.dart';
import '../../auth/screens/providers/login_provider.dart';
import '../../lucky_draw/screens/providers/lucky_draw_provider.dart';
import '../../lucky_draw/screens/providers/lucky_draw_provider_state.dart';
import 'providers/setting_provider.dart';

class SettingScreen extends ConsumerStatefulWidget {
  const SettingScreen({super.key});
  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _SettingScreenState();
}

class _SettingScreenState extends ConsumerState<SettingScreen> {
  @override
  Widget build(BuildContext context) {
    final logoutState = ref.watch(authProvider);
    final themeMode = ref.watch(themeModeProvider);
    final currency = ref.watch(currencyProvider);
    final colors = Theme.of(context).colorScheme;
    logout();
    return Stack(
      children: [
        SafeArea(
          child: SingleChildScrollView(
            child: Column(
              children: [
                Text("Settings", style: TextTheme.of(context).titleLarge),
                const SizedBox(height: 16),
                Container(
                  margin: EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: colors.surface,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: colors.outline,
                      // strokeAlign: BorderSide.strokeAlignOutside
                    ),
                  ),
                  child: Column(
                    children: [
                      SettingItems(
                        icon: Icons.person,
                        iconColor: colors.primary,
                        label: "Profile",
                        onTap: () {},
                      ),
                      SettingItems(
                        icon: Icons.currency_exchange,
                        iconColor: colors.primary,
                        trailing: Row(
                          children: [
                            Text(
                              '${currency.label} (${currency.symbol})',
                              style: TextTheme.of(context).labelLarge!.copyWith(
                                fontSize: 14,
                                color: colors.onSurfaceVariant,
                              ),
                            ),
                            const SizedBox(width: 16),
                            Icon(
                              Icons.chevron_right,
                              size: 15,
                              color: colors.onSurfaceVariant,
                            ),
                          ],
                        ),
                        label: "Currency",
                        onTap: () => _showCurrencyPicker(currency),
                      ),
                      // SettingItems(
                      //   icon: Icons.language,
                      //   iconColor: colors.primary,
                      //   trailing: Row(
                      //     children: [
                      //       Text(
                      //         "English",
                      //         style: TextTheme.of(context).labelLarge!.copyWith(
                      //           fontSize: 14,
                      //           color: colors.onSurfaceVariant,
                      //         ),
                      //       ),
                      //       const SizedBox(width: 16),
                      //       Icon(
                      //         Icons.chevron_right,
                      //         size: 15,
                      //         color: colors.onSurfaceVariant,
                      //       ),
                      //     ],
                      //   ),
                      //   label: "Language",
                      //   onTap: () {},
                      // ),
                      SettingItems(
                        icon: Icons.color_lens,
                        iconColor: colors.primary,
                        trailing: Row(
                          children: [
                            Text(
                              _themeModeLabel(themeMode),
                              style: TextTheme.of(context).labelLarge!.copyWith(
                                fontSize: 14,
                                color: colors.onSurfaceVariant,
                              ),
                            ),
                            const SizedBox(width: 16),
                            Icon(
                              Icons.chevron_right,
                              size: 15,
                              color: colors.onSurfaceVariant,
                            ),
                          ],
                        ),
                        label: "Theme",
                        onTap: () => _showThemePicker(themeMode),
                      ),
                      SettingItems(
                        icon: Icons.money_outlined,
                        iconColor: colors.primary,
                        label: "Budget Setting",
                        onTap: () {
                          context.pushNamed(AppConst.budget);
                        },
                      ),
                      SettingItems(
                        icon: Icons.casino_outlined,
                        iconColor: colors.primary,
                        label: "Lucky Draw",
                        onTap: _openLuckyDraw,
                      ),
                      // SettingItems(
                      //   icon: Icons.upload_file,
                      //   iconColor: colors.primary,
                      //   label: "Export Data",
                      //   onTap: () {},
                      // ),
                      // SettingItems(
                      //   icon: Icons.backup,
                      //   iconColor: colors.primary,
                      //   label: "Backup & Restore",
                      //   isLast: true,
                      //   onTap: () {},
                      // ),
                    ],
                  ),
                ),
                Container(
                  margin: const EdgeInsets.symmetric(horizontal: 24),
                  decoration: BoxDecoration(
                    color: colors.surface,
                    border: Border.all(color: colors.outline),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: SettingItems(
                    icon: Icons.logout,
                    iconColor: colors.primary,
                    label: "Logout",
                    onTap: () async {
                      ref.read(navigationProvider.notifier).state = 0;
                      ref.read(authProvider.notifier).logout();
                    },
                    isLast: true,
                    trailing: const SizedBox(),
                  ),
                ),
              ],
            ),
          ),
        ),
        logoutState is LogoutLoadingState
            ? Container(
                height: MediaQuery.of(context).size.height,
                width: MediaQuery.of(context).size.width,
                color: colors.scrim.withValues(alpha: .5),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      "Logging Out...",
                      style: TextTheme.of(context).bodyLarge,
                    ),
                  ],
                ),
              )
            : const SizedBox(),
      ],
    );
  }

  Future<void> logout() async {
    ref.listen(authProvider, (p, next) {
      if (next is LoginErrorState) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(next.errorMessage)));
      } else if (next is LogoutSuccessState) {
        SharedPreferencesUtils.setBool(AppConst.isLogined, false);
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(next.message)));
        context.goNamed(AppConst.login);
      }
    });
  }

  Future<void> _openLuckyDraw() async {
    await ref.read(luckyDrawProvider.notifier).getCurrentDraw();
    if (!mounted) return;

    switch (ref.read(luckyDrawProvider)) {
      case LuckyDrawReadyState():
        context.push('/lucky-draw');
      case LuckyDrawInitialState():
        context.push('/lucky-draw/create');
      case LuckyDrawErrorState(:final errorMessage):
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(errorMessage)));
      case LuckyDrawLoadingState():
        break;
    }
  }

  String _themeModeLabel(ThemeMode mode) {
    return switch (mode) {
      ThemeMode.system => 'System',
      ThemeMode.light => 'Light',
      ThemeMode.dark => 'Dark',
    };
  }

  Future<void> _showThemePicker(ThemeMode currentMode) async {
    final selectedMode = await showModalBottomSheet<ThemeMode>(
      context: context,
      showDragHandle: true,
      builder: (sheetContext) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Choose Theme',
                  style: Theme.of(sheetContext).textTheme.titleMedium,
                ),
                const SizedBox(height: 8),
                for (final mode in ThemeMode.values)
                  ListTile(
                    leading: Icon(switch (mode) {
                      ThemeMode.system => Icons.brightness_auto_outlined,
                      ThemeMode.light => Icons.light_mode_outlined,
                      ThemeMode.dark => Icons.dark_mode_outlined,
                    }),
                    title: Text(_themeModeLabel(mode)),
                    trailing: mode == currentMode
                        ? Icon(
                            Icons.check_circle,
                            color: Theme.of(sheetContext).colorScheme.primary,
                          )
                        : null,
                    onTap: () => Navigator.of(sheetContext).pop(mode),
                  ),
              ],
            ),
          ),
        );
      },
    );
    if (selectedMode != null) {
      await ref.read(themeModeProvider.notifier).setThemeMode(selectedMode);
    }
  }

  Future<void> _showCurrencyPicker(AppCurrency currentCurrency) async {
    final selectedCurrency = await showModalBottomSheet<AppCurrency>(
      context: context,
      showDragHandle: true,
      builder: (sheetContext) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Choose Currency',
                  style: Theme.of(sheetContext).textTheme.titleMedium,
                ),
                const SizedBox(height: 8),
                for (final currency in AppCurrency.values)
                  ListTile(
                    leading: CircleAvatar(
                      child: Text(
                        currency.symbol,
                        style: Theme.of(sheetContext).textTheme.titleMedium,
                      ),
                    ),
                    title: Text(currency.label),
                    subtitle: Text(currency.code),
                    trailing: currency == currentCurrency
                        ? Icon(
                            Icons.check_circle,
                            color: Theme.of(sheetContext).colorScheme.primary,
                          )
                        : null,
                    onTap: () => Navigator.of(sheetContext).pop(currency),
                  ),
              ],
            ),
          ),
        );
      },
    );
    if (selectedCurrency != null) {
      await ref.read(currencyProvider.notifier).setCurrency(selectedCurrency);
    }
  }
}

class SettingItems extends ConsumerWidget {
  final IconData icon;
  final Color iconColor;
  final String label;
  final bool? isLast;
  final VoidCallback onTap;
  final Widget? trailing;
  const SettingItems({
    super.key,
    required this.icon,
    required this.iconColor,
    required this.label,
    this.isLast = false,
    required this.onTap,
    this.trailing,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(12),
      child: Material(
        child: InkWell(
          onTap: onTap,
          child: Column(
            children: [
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 24, vertical: 24),
                child: Row(
                  children: [
                    Icon(icon, color: iconColor),
                    const SizedBox(width: 16),
                    Text(label, style: TextTheme.of(context).bodyLarge),
                    Spacer(),
                    trailing ??
                        Icon(
                          Icons.chevron_right,
                          size: 15,
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                        ),
                  ],
                ),
              ),
              if (!isLast!) Divider(),
            ],
          ),
        ),
      ),
    );
  }
}
