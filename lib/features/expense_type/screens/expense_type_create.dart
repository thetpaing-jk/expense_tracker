import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/utils/app_const.dart';
import '../data/models/expense_type_model.dart';
import 'providers/expense_type_provider.dart';
import 'providers/expense_type_provider_state.dart';

class ExpenseTypeCreateScreen extends ConsumerStatefulWidget {
  final ExpenseTypeModel? type;
  const ExpenseTypeCreateScreen({super.key, this.type});
  @override
  ConsumerState<ConsumerStatefulWidget> createState() =>
      _ExpenseTypeCreateScreenState();
}

class _ExpenseTypeCreateScreenState
    extends ConsumerState<ExpenseTypeCreateScreen> {
  TextEditingController typeNameC = TextEditingController();
  FocusNode typeNameF = FocusNode();
  GlobalKey<FormState> formKey = GlobalKey();
  @override
  @override
  void initState() { 
    super.initState();
    typeNameC.text = widget.type?.title ?? "";
  }
  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final expenseTypeState = ref.watch(expenseTypeProvider);
    final iconProvider = ref.watch(expneseIconProvider);
    final iconColorProvider = ref.watch(expneseIconColor);
    createType();
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text(
          "Expense Type Create",
          style: TextTheme.of(context).titleLarge,
        ),
        actions: [
          TextButton(
            onPressed: () {},
            child: Text(
              "Save",
              style: TextTheme.of(
                context,
              ).titleMedium!.copyWith(color: colors.primary),
            ),
          ),
        ],
      ),
      body: SafeArea(
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 0),
          width: MediaQuery.of(context).size.width,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.max,
              children: [
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 16,
                  ),
                  decoration: BoxDecoration(
                    color: iconColorProvider.withValues(alpha: .3),
                    border: Border.all(color: iconColorProvider, width: 2),
                    borderRadius: BorderRadius.circular(24),
                  ),
                  child: Image.asset(
                    "${AppConst.expneseTypeUrl}$iconProvider.png",
                    width: 60,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  "Tap icon to change",
                  style: TextTheme.of(context).labelLarge,
                ),
                const SizedBox(height: 16),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Type Name",
                      style: TextTheme.of(context).titleSmall!.copyWith(
                        color: colors.onSurfaceVariant,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Form(
                      key: formKey,
                      child: TextFormField(
                        controller: typeNameC,
                        focusNode: typeNameF,
                        onTapOutside: (event) => typeNameF.unfocus(),
                        validator: (value) {
                          if(typeNameC.text == ""){
                            return "Type Name must include";
                          }
                          return null;
                        },
                        decoration: InputDecoration(
                          hint: Text("Enter type name"),
                          hintStyle: TextTheme.of(context).labelLarge!.copyWith(
                            color: colors.onSurfaceVariant,
                          ),
                          border: OutlineInputBorder(
                            borderSide: BorderSide(color: colors.outline),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      "Choose Icon",
                      style: TextTheme.of(context).titleSmall!.copyWith(
                        color: colors.onSurfaceVariant,
                      ),
                    ),
                    const SizedBox(height: 8),
                    SizedBox(
                      height: 100,
                      child: GridView.builder(
                        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 8,
                          mainAxisSpacing: 4,
                          crossAxisSpacing: 4,
                        ),
                        itemCount: AppConst.iconList.length,
                        itemBuilder: (context, index) {
                          return ClipRRect(
                            borderRadius: BorderRadius.circular(16),
                            child: Material(
                              child: InkWell(
                                onTap: () {
                                  ref.read(expneseIconProvider.notifier).state =
                                      AppConst.iconList[index];
                                },
                                child: Container(
                                  padding: const EdgeInsets.all(8),
                                  decoration: BoxDecoration(
                                    color: colors.surface,
                                    border: Border.all(
                                      color: iconProvider == AppConst.iconList[index]
                                          ? iconColorProvider
                                          : Colors.transparent,
                                      width: iconProvider == AppConst.iconList[index]
                                          ? 2
                                          : 0,
                                    ),
                                    borderRadius: BorderRadius.circular(16),
                                  ),
                                  child: Image.asset(
                                    "${AppConst.expneseTypeUrl}${AppConst.iconList[index]}.png",
                                    width: 15,
                                  ),
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      "Choose Color",
                      style: TextTheme.of(context).titleSmall!.copyWith(
                        color: colors.onSurfaceVariant,
                      ),
                    ),
                    const SizedBox(height: 8),
                    SizedBox(
                      height: 100,
                      child: GridView.builder(
                        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 8,
                          crossAxisSpacing: 4,
                          mainAxisSpacing: 4,
                        ),
                        itemCount: AppConst.colorList.length,
                        itemBuilder: (context, index) {
                          return InkWell(
                            overlayColor: WidgetStatePropertyAll(
                              Colors.transparent,
                            ),
                            onTap: () {
                              ref.read(expneseIconColor.notifier).state =
                                  AppConst.colorList[index];
                            },
                            child: Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: AppConst.colorList[index].withValues(alpha: .2),
                                border: Border.all(
                                  color: iconColorProvider == AppConst.colorList[index]
                                      ? AppConst.colorList[index]
                                      : Colors.transparent,
                                  width: iconColorProvider == AppConst.colorList[index]
                                      ? 2
                                      : 0,
                                ),
                                borderRadius: BorderRadius.circular(90),
                              ),
                              child: Container(
                                width: 20,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(90),
                                  color: AppConst.colorList[index],
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                    const SizedBox(height: 16),
                    Hero(
                      tag: 'expense-type-add-fab${widget.type?.id ?? ""}',
                      child: ElevatedButton(
                        onPressed: () async{
                          if(formKey.currentState!.validate()){
                            if(widget.type != null){
                              ExpenseTypeModel type = ExpenseTypeModel(
                                id: widget.type!.id,
                                title: typeNameC.text,
                                subtitle: "0",
                                iconColor: AppConst.colorList.indexWhere(
                                  (color) => color == iconColorProvider,
                                ),
                                icon: AppConst.iconList.indexOf(iconProvider),
                              );
                              await ref.read(expenseTypeProvider.notifier).editType(type);
                            }else{
                              ExpenseTypeModel type = ExpenseTypeModel(
                                title: typeNameC.text,
                                subtitle: "0",
                                iconColor: AppConst.colorList.indexWhere(
                                  (color) => color == iconColorProvider,
                                ),
                                icon: AppConst.iconList.indexOf(iconProvider),
                              );
                              await ref.read(expenseTypeProvider.notifier).createType(type);
                            }
                            if(context.mounted){
                              context.pop();
                            }
                          }
                        },
                        child:
                        expenseTypeState is ExpenseTypeLoadingState ?
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              widget.type?.title != null ? "Type Editing..." : "Type Creating...",
                              style: TextTheme.of(context).bodyLarge!.copyWith(
                                color: colors.onPrimary,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(width: 8,),
                            SizedBox(
                              width: 25,
                              height: 25,
                              child: CircularProgressIndicator.adaptive(
                                backgroundColor: colors.onPrimary,
                              ),
                            )
                          ],
                        )
                        : Text(
                          widget.type?.title != null ? "Edit Type" : "Create Type",
                          style: TextTheme.of(context).bodyLarge!.copyWith(
                            color: colors.onPrimary,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
  void createType() async{
    ref.listen(expenseTypeProvider, (p,next){
      if(next is ExpenseTypeSuccessState){
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(next.message)));
      }
    });
  }
}
