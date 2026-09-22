import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/services/app_preference_helper.dart';
import '../../../core/utils/app_const.dart';
import 'providers/login_provider.dart';
import 'providers/login_provider_state.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen>
    with SingleTickerProviderStateMixin {

  late final AnimationController _animationController;
  late final Animation<double> _iconGlow;
  final TextEditingController emailC = TextEditingController();
  final TextEditingController passwordC = TextEditingController();
  final FocusNode emailF = FocusNode();
  final FocusNode passwordF = FocusNode();
  final GlobalKey<FormState> formkey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat(reverse: true);

    _iconGlow = Tween<double>(begin: 0.1, end: .6).animate(
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
    final colors = Theme.of(context).colorScheme;
    final visibilityState = ref.watch(visibilityProvider);
    final authState = ref.watch(authProvider);
    loginListener();
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: SizedBox(
        width: MediaQuery.of(context).size.width,
        child: SingleChildScrollView(
          child: Column(
            children: [
              const SizedBox(height: 120),
              AnimatedBuilder(
                animation: _animationController,
                builder: (context, child) {
                  return Hero(
                    tag: "icon",
                    child: Container(
                      height: 80,
                      width: 80,
                      padding: const EdgeInsets.all(18),
                      decoration: BoxDecoration(
                        border: Border.all(
                          color: colors.outline,
                          width: 1.5,
                        ),
                        color: colors.surface,
                        borderRadius: BorderRadius.circular(24),
                        boxShadow: [
                          BoxShadow(
                            offset: Offset.zero,
                            blurRadius: 28,
                            spreadRadius: 2,
                            color: colors.primary.withValues(
                              alpha: _iconGlow.value,
                            ),
                          ),
                        ],
                      ),
                      child: child,
                    ),
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
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    width: 8,
                    height: 8,
                    decoration: BoxDecoration(
                      color: colors.primary,
                      borderRadius: BorderRadius.circular(90)
                    ),
                  ),
                  const SizedBox(width: 16,),
                  Text(
                    "Welcome Back",
                    style: TextTheme.of(context).headlineLarge,
                  ),
                ],
              ),
              const SizedBox(height: 8,),
              Text("Login to continue", style: TextTheme.of(context).labelLarge),
              const SizedBox(height: 24,),
              Form(
                key: formkey,
                child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text("Email", style: TextTheme.of(context).labelLarge,),
                        const SizedBox(height: 8,),
                        TextFormField(
                          controller: emailC,
                          focusNode: emailF,
                          onTapOutside: (_){
                            emailF.unfocus();
                          },
                          validator: (value){
                            if(value == null || value.isEmpty){
                              return "Email must not empty";
                            }return null;
                          },
                          onEditingComplete: () {
                            passwordF.requestFocus();
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
                          validator: (value){
                            if(value == null || value.isEmpty){
                              return "Password must not empty";
                            }return null;
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
                        Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            TextButton(onPressed: (){
                              ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Not implement yet")));
                            }, child: Text("Forgot Password?",
                              style: TextTheme.of(context).bodyMedium!.copyWith(
                                color: colors.primary
                              ),
                            ))
                          ],
                        ),
                        const SizedBox(height: 16,),
                        ElevatedButton(onPressed: () async{
                          if(formkey.currentState!.validate() == true){
                            await ref.read(authProvider.notifier).login(emailC.text, passwordC.text);
                          }
                        }, child: switch (authState) {
                            LoginFormState() => Text("Login"),
                            LoginLoadingState() => Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text("Logging In..."),
                                SizedBox(width: 24,),
                                SizedBox(
                                  width: 25,
                                  height: 25,
                                  child: CircularProgressIndicator(color: colors.onPrimary,),
                                )
                            ],),
                            LoginSuccessState() => Text("Login"),
                            LoginErrorState() => Text("Login"),
                          LogoutLoadingState() => const SizedBox(),
                          LogoutSuccessState() => Text("Login"),
                          })
                      ],
                    ),
                  )
              ),
              const SizedBox(height: 26,),
              InkWell(
                onTap: (){
                  context.goNamed(AppConst.register);
                },
                child: Text.rich(
                  TextSpan(
                    text: "Don't have an account?",
                    style: TextTheme.of(context).labelLarge,
                    children: [
                      TextSpan(
                        text: " Register",
                        style: TextTheme.of(context).labelLarge!.copyWith(
                          color: colors.primary
                        )
                      )
                    ]
                  ),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }

  void loginListener() async{
    ref.listen(authProvider, (p,next){
      if(next is LoginSuccessState){
        SharedPreferencesUtils.setBool(AppConst.isLogined, true);
        // ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
        context.goNamed(AppConst.home);
      }else if(next is LoginErrorState){
        String errorMessage = next.errorMessage.replaceAll("Exception ", "");
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(errorMessage)));
      }
    });
  }
}
