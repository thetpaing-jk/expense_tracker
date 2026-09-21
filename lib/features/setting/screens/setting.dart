import 'package:expense_tracker/features/auth/screens/providers/login_provider_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/providers/navigation_provider.dart';
import '../../../core/services/app_preference_helper.dart';
import '../../../core/utils/app_color.dart';
import '../../../core/utils/app_const.dart';
import '../../auth/screens/providers/login_provider.dart';
import '../../lucky_draw/screens/providers/lucky_draw_provider.dart';
import '../../lucky_draw/screens/providers/lucky_draw_provider_state.dart';

class SettingScreen extends ConsumerStatefulWidget {
  const SettingScreen({super.key});
  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _SettingScreenState();
}

class _SettingScreenState extends ConsumerState<SettingScreen> {
  @override
  Widget build(BuildContext context) {
    final logoutState = ref.watch(authProvider);
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
                    color: AppColor.cardBackgroundColor,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: AppColor.borderColor,
                      // strokeAlign: BorderSide.strokeAlignOutside
                    ),
                  ),
                  child: Column(
                    children: [
                      SettingItems(
                        icon: Icons.person,
                        iconColor: AppColor.buttonColor,
                        label: "Profile",
                        onTap: () {},
                      ),
                      // SettingItems(
                      //   icon: Icons.currency_bitcoin,
                      //   iconColor: AppColor.buttonColor,
                      //   label: "Currency",
                      //   onTap: () {},
                      // ),
                      SettingItems(
                        icon: Icons.language,
                        iconColor: AppColor.buttonColor,
                        trailing: Row(
                          children: [
                            Text(
                              "English",
                              style: TextTheme.of(context).labelLarge!.copyWith(
                                fontSize: 14,
                                color: AppColor.secondaryTextColor,
                              ),
                            ),
                            const SizedBox(width: 16),
                            Icon(
                              Icons.chevron_right,
                              size: 15,
                              color: AppColor.placeholderColor,
                            ),
                          ],
                        ),
                        label: "Language",
                        onTap: () {},
                      ),
                      SettingItems(
                        icon: Icons.color_lens,
                        iconColor: AppColor.buttonColor,
                        trailing: Row(
                          children: [
                            Text(
                              "Dark",
                              style: TextTheme.of(context).labelLarge!.copyWith(
                                fontSize: 14,
                                color: AppColor.secondaryTextColor,
                              ),
                            ),
                            const SizedBox(width: 16),
                            Icon(
                              Icons.chevron_right,
                              size: 15,
                              color: AppColor.placeholderColor,
                            ),
                          ],
                        ),
                        label: "Theme",
                        onTap: () {},
                      ),
                      SettingItems(
                        icon: Icons.money_outlined,
                        iconColor: AppColor.buttonColor,
                        label: "Budget Setting",
                        onTap: () {
                          context.pushNamed(AppConst.budget);
                        },
                      ),
                      SettingItems(
                        icon: Icons.casino_outlined,
                        iconColor: AppColor.buttonColor,
                        label: "Lucky Draw",
                        onTap: _openLuckyDraw,
                      ),
                      SettingItems(
                        icon: Icons.upload_file,
                        iconColor: AppColor.buttonColor,
                        label: "Export Data",
                        onTap: () {},
                      ),
                      SettingItems(
                        icon: Icons.backup,
                        iconColor: AppColor.buttonColor,
                        label: "Backup & Restore",
                        isLast: true,
                        onTap: () {},
                      ),
                    ],
                  ),
                ),
                Container(
                  margin: const EdgeInsets.symmetric(horizontal: 24),
                  decoration: BoxDecoration(
                    color: AppColor.cardBackgroundColor,
                    border: Border.all(color: AppColor.borderColor),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: SettingItems(
                    icon: Icons.logout,
                    iconColor: AppColor.buttonColor,
                    label: "Logout",
                    onTap: () async{
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
        logoutState is LogoutLoadingState ? Container(
          height: MediaQuery.of(context).size.height,
          width: MediaQuery.of(context).size.width,
          color: AppColor.borderColor.withValues(alpha: .5),
          child: 
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SizedBox(
                height: 20,
                width: 20,
                child: CircularProgressIndicator(),
              ),
              const SizedBox(height: 8,),
              Text("Logging Out...",
                style: TextTheme.of(context).bodyLarge,
              )
            ],
          ),
        ) : const SizedBox()
      ],
    );
  }
  Future<void> logout() async{
    ref.listen(authProvider, (p,next){
      if(next is LoginErrorState){
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(next.errorMessage)));
      }else if(next is LogoutSuccessState){
        SharedPreferencesUtils.setBool(AppConst.isLogined, false);
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(next.message)));
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
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(errorMessage)),
        );
      case LuckyDrawLoadingState():
        break;
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
                          color: AppColor.placeholderColor,
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
