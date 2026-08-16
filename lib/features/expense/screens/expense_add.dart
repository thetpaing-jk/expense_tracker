import 'package:expense_tracker/features/expense/screens/providers/expense_provider_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/services/app_number_formatter.dart';
import '../../../core/utils/app_color.dart';
import '../../expense_type/data/models/expense_type_model.dart';
import '../../expense_type/screens/providers/expense_type_provider.dart';
import '../../expense_type/screens/providers/expense_type_provider_state.dart';

class AddExpense extends ConsumerStatefulWidget {
  const AddExpense({super.key});
  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _AddExpenseState();
}
class _AddExpenseState extends ConsumerState<AddExpense> {
  TextEditingController titleC = TextEditingController();
  TextEditingController amountC = TextEditingController();
  TextEditingController dateC = TextEditingController();
  TextEditingController noteC = TextEditingController();
  FocusNode titleF = FocusNode();
  FocusNode amountF = FocusNode();
  FocusNode dateF = FocusNode();
  FocusNode noteF = FocusNode();
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_){
      ref.read(expenseTypeProvider.notifier).getAllType();
    });
  }
  @override
  Widget build(BuildContext context) {
    final expenseType = ref.watch(expenseTypeProvider);
    final expenseTypeChoose = ref.watch(expenseTypeChooseProvider);
    return Scaffold(
      appBar: AppBar(
        title: Text("Add Expense"),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: 24,
          vertical: 8
        ),
        child: Form(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text("Title", style: TextTheme.of(context).bodyMedium!.copyWith(
                color: AppColor.secondaryTextColor
              ),),
              const SizedBox(height: 4,),
              TextFormField(
                controller: titleC,
                focusNode: titleF,
                onTapOutside: (event) {
                  titleF.unfocus();
                },
                decoration: InputDecoration(
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(25),
                  ),
                  hint: Text("Enter expense title", style:  TextTheme.of(context).bodyLarge!.copyWith(
                    color: AppColor.secondaryTextColor
                  ),),
                ),
              ),
              const SizedBox(height: 8,),
              Text("Amount", style: TextTheme.of(context).bodyMedium!.copyWith(
                color: AppColor.secondaryTextColor
              ),),
              const SizedBox(height: 4,),
              TextFormField(
                controller: amountC,
                focusNode: amountF,
                onTapUpOutside: (event) {
                  amountF.unfocus();
                },
                decoration: InputDecoration(
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(25),
                  ),
                  hint: Text(NumberFormatService.formatCurrency(0), style:  TextTheme.of(context).bodyLarge!.copyWith(
                    color: AppColor.secondaryTextColor
                  ),),
                ),
              ),
              const SizedBox(height: 8,),
              Text("Expense Type", style: TextTheme.of(context).bodyMedium!.copyWith(
                color: AppColor.secondaryTextColor
              ),),
              const SizedBox(height: 4,),
              Container(
                padding: const EdgeInsets.only(left: 20, right: 28, top: 4, bottom: 4),
                width: MediaQuery.of(context).size.width,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8),
                  color: AppColor.inputBackgroundColor
                ),
                child: expenseType is ExpenseTypeReadyState ? DropdownButton(
                  value: expenseTypeChoose,  
                  borderRadius: BorderRadius.circular(25),
                  underline: SizedBox(),
                  items: [
                    DropdownMenuItem(
                      value : null,
                      child: Text("Select Type",
                        style: TextTheme.of(context).bodyLarge!.copyWith(
                          color: AppColor.secondaryTextColor
                        ),
                    )),
                    for(ExpenseTypeModel type in expenseType.expenseList)...[
                      DropdownMenuItem(
                        value: type,
                        child: Text(type.title,
                        style: TextTheme.of(context).bodyLarge!.copyWith(
                          color: AppColor.secondaryTextColor
                        ),
                      )),
                    ]
                  ], onChanged: (value) {
                    ref.read(expenseTypeChooseProvider.notifier).state = value;
                  },
                ) : const SizedBox(),
              ),
              const SizedBox(height: 8,),
              Text("Date", style: TextTheme.of(context).bodyMedium!.copyWith(
                color: AppColor.secondaryTextColor
              ),),
              const SizedBox(height: 4,),
              TextFormField(
                decoration: InputDecoration(
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(25),
                  ),
                  hint: Text("Enter expense title", style:  TextTheme.of(context).bodyLarge!.copyWith(
                    color: AppColor.secondaryTextColor
                  ),),
                ),
              ),
              const SizedBox(height: 8,),
              Text("Note (Optional)", style: TextTheme.of(context).bodyMedium!.copyWith(
                color: AppColor.secondaryTextColor
              ),),
              const SizedBox(height: 4,),
              TextFormField(
                controller: noteC,
                focusNode: noteF,
                onTapUpOutside: (event){
                  noteF.unfocus();
                },
                decoration: InputDecoration(
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(25),
                  ),
                  hint: Text("Enter note", style:  TextTheme.of(context).bodyLarge!.copyWith(
                    color: AppColor.secondaryTextColor
                  ),),
                ),
              ),
              const SizedBox(height: 16,),
              ElevatedButton(onPressed: (){}, child: Text("Save Expense"))
            ],
          ),
        ),
      ),
    );
  }
}