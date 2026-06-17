import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/utils/app_color.dart';
import '../../../core/utils/app_const.dart';
import 'providers/login_provider.dart';
import 'providers/login_provider_state.dart';

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
    final authState = ref.watch(authProvider);
    registerListener();
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
                            validator: (value) {
                              if(value == null || value.isEmpty){
                                return "Name should not blank";
                              }return null;
                            },
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
                            validator: (value){
                              if(value == null){
                                return "Email should not blank";
                              }
                              else if(value.isEmpty){
                                  return "Email should not blank";
                                }else if(!value.endsWith("@gmail.com")){
                                  return "Email format is wrong";
                              }return null;
                            },
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
                            validator: (value){
                              if(value == null || value.isEmpty){
                                return "Password should not blank";
                              }return null;
                            },
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
                            validator: (value) {
                              if(value == null || value.isEmpty){
                                return "Password should not blank";
                              }else if(value != passwordC.text){
                                return "Confirm password must same as password";
                              }return null;
                            },
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
                          const SizedBox(height: 24,),
                          ElevatedButton(onPressed: () async{
                            if(formkey.currentState!.validate() == true){
                              await ref.read(authProvider.notifier).register(emailC.text, nameC.text, passwordC.text);
                            }
                          }, child: switch (authState) {
                            LoginFormState() => Text("Register"),
                            LoginLoadingState() => Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text("Registering..."),
                                SizedBox(width: 24,),
                                SizedBox(
                                  width: 25,
                                  height: 25,
                                  child: CircularProgressIndicator(color: AppColor.primaryColor,),
                                )
                            ],),
                            LoginSuccessState() => Text("Register"),
                            LoginErrorState() => Text("Register"),
                          })
                        ],
                      ),
                    )
                ),
                const SizedBox(height: 24,),
                InkWell(
                  onTap: (){
                    context.goNamed(AppConst.login);
                  },
                  child: Text.rich(
                    TextSpan(
                      text: "Already have an account?",
                      style: TextTheme.of(context).labelLarge,
                      children: [
                        TextSpan(
                          text: " Login",
                          style: TextTheme.of(context).labelLarge!.copyWith(
                            color: AppColor.buttonColor
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
  void registerListener()async{
    ref.listen(authProvider, (p,next){
      if(next is LoginSuccessState){
        // SharedPreferencesUtils.setBool(AppConst.isLogined, true);
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content:Text("Successfully Registered")));
        context.goNamed(AppConst.login);
      }else if(next is LoginErrorState){
        String errorMessage = next.errorMessage.replaceAll("Expection ", "");
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content:Text(errorMessage), duration: Duration(seconds: 5),));
      }
    });
  }
}