import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/utils/app_color.dart';
import 'providers/login_provider.dart';

class RegisterScreen extends ConsumerStatefulWidget {
  const RegisterScreen({super.key});
  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _RegisterScreenState();
}
class _RegisterScreenState extends ConsumerState<RegisterScreen> with SingleTickerProviderStateMixin {
    late final AnimationController _animationController;
  late final Animation<double> _iconGlow;
  final TextEditingController emailC = TextEditingController();
  final TextEditingController passwordC = TextEditingController();
  final TextEditingController nameC = TextEditingController();
  final TextEditingController confirmPwdC = TextEditingController();
  final FocusNode emailF = FocusNode();
  final FocusNode passwordF = FocusNode();
  final FocusNode nameF = FocusNode();
  final FocusNode confirmPwdF = FocusNode();
  final GlobalKey<FormState> formkey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat(reverse: true);

    _iconGlow = Tween<double>(begin: 0.1, end: 0.55).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Curves.easeInOut,
      ),
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }
  @override
  Widget build(BuildContext context) {
    final visibilityState = ref.watch(visibilityProvider);
    final visibilityState1 = ref.watch(visibilityProvider1);
    return Scaffold(
      body: SizedBox(
        width: MediaQuery.of(context).size.width,
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisSize: MainAxisSize.max,
            children: [
              const SizedBox(height: 120),
              AnimatedBuilder(
                animation: _animationController,
                builder: (context, child) {
                  return Container(
                    height: 80,
                    width: 80,
                    padding: const EdgeInsets.all(18),
                    decoration: BoxDecoration(
                      border: Border.all(
                        color: AppColor.borderColor,
                        width: 1.5,
                      ),
                      color: AppColor.cardBackgroundColor,
                      borderRadius: BorderRadius.circular(24),
                      boxShadow: [
                        BoxShadow(
                          offset: Offset.zero,
                          blurRadius: 28,
                          spreadRadius: 2,
                          color: AppColor.buttonColor.withValues(
                            alpha: _iconGlow.value,
                          ),
                        ),
                      ],
                    ),
                    child: child,
                  );
                },
                child: Image.asset(
                  'assets/icon/purse.png',
                  height: 40,
                  width: 40,
                  fit: BoxFit.contain,
                ),
              ),
              const SizedBox(height: 20,),
              const SizedBox(width: 16,),
              Text(
                "Create Account",
                style: TextTheme.of(context).headlineLarge,
              ),
              const SizedBox(height: 8,),
              Text("Register to get started", style: TextTheme.of(context).labelLarge),
              const SizedBox(height: 24,),
              Form(
                  key: formkey,
                  child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 24),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text("Name", style: TextTheme.of(context).labelLarge,),
                          const SizedBox(height: 8,),
                          TextFormField(
                            controller: nameC,
                            focusNode: nameF,
                            onTapOutside: (_){
                              nameF.unfocus();
                            },
                            decoration: InputDecoration(
                              border: OutlineInputBorder(),
                              hint: Text("Enter full name", style: TextTheme.of(context).labelLarge,)
                            ),
                          ),
                          const SizedBox(height: 16,),
                          Text("Email", style: TextTheme.of(context).labelLarge,),
                          const SizedBox(height: 8,),
                          TextFormField(
                            controller: emailC,
                            focusNode: emailF,
                            onTapOutside: (_){
                              emailF.unfocus();
                            },
                            decoration: InputDecoration(
                              border: OutlineInputBorder(),
                              hint: Text("Enter your Email", style: TextTheme.of(context).labelLarge,)
                            ),
                          ),
                          const SizedBox(height: 16,),
                          Text("Password", style: TextTheme.of(context).labelLarge,),
                          const SizedBox(height: 8,),
                          TextFormField(
                            controller: passwordC,
                            focusNode: passwordF,
                            obscureText: !visibilityState,
                            onTapOutside: (_){
                              passwordF.unfocus();
                            },
                            decoration: InputDecoration(
                              border: OutlineInputBorder(),
                              hint: Text("Enter your Password", style: TextTheme.of(context).labelLarge,),
                              suffixIcon: IconButton(
                                style: ButtonStyle(
                                  backgroundColor: WidgetStatePropertyAll(Colors.transparent),
                                  overlayColor: WidgetStatePropertyAll(Colors.transparent)
                                ),
                                onPressed: (){
                                ref.read(visibilityProvider.notifier).state = !visibilityState;
                              }, icon: visibilityState == false ? Icon(Icons.visibility_off) : Icon(Icons.visibility))
                            ),
                          ),
                          const SizedBox(height: 16,),
                          Text("Confirm password", style: TextTheme.of(context).labelLarge,),
                          const SizedBox(height: 8,),
                          TextFormField(
                            controller: confirmPwdC,
                            focusNode: confirmPwdF,
                            obscureText: !visibilityState1,
                            onTapOutside: (_){
                              confirmPwdF.unfocus();
                            },
                            decoration: InputDecoration(
                              border: OutlineInputBorder(),
                              hint: Text("Enter confirm password", style: TextTheme.of(context).labelLarge,),
                              suffixIcon: IconButton(
                                style: ButtonStyle(
                                  backgroundColor: WidgetStatePropertyAll(Colors.transparent),
                                  overlayColor: WidgetStatePropertyAll(Colors.transparent)
                                ),
                                onPressed: (){
                                ref.read(visibilityProvider1.notifier).state = !visibilityState1;
                              }, icon: visibilityState1 == false ? Icon(Icons.visibility_off) : Icon(Icons.visibility))
                            ),
                          ),
                          const SizedBox(height: 16,),
                          ElevatedButton(onPressed: (){}, child: Text("Register"))
                        ],
                      ),
                    )
                ),
            ],
          ),
        ),
      ),
    );
  }
}