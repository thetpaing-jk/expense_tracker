import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../core/services/app_number_formatter.dart';
import '../../../core/utils/app_color.dart';
import '../../expense_type/data/models/expense_type_model.dart';
import '../../expense_type/screens/providers/expense_type_provider.dart';
import '../../expense_type/screens/providers/expense_type_provider_state.dart';
import '../data/models/expense_model.dart';
import 'providers/expense_provider.dart';
import 'providers/expense_provider_state.dart';

class AddExpense extends ConsumerStatefulWidget {
  final ExpenseModel? expense;
  const AddExpense({super.key, this.expense});
  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _AddExpenseState();
}

class _AddExpenseState extends ConsumerState<AddExpense> {
  TextEditingController titleC = TextEditingController();
  TextEditingController amountC = TextEditingController();
  TextEditingController noteC = TextEditingController();
  FocusNode titleF = FocusNode();
  FocusNode amountF = FocusNode();
  FocusNode noteF = FocusNode();
  FocusNode typeF = FocusNode();
  GlobalKey<FormState> formKey = GlobalKey<FormState>();
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _prepareForm();
    });
  }

  Future<void> _prepareForm() async {
    final expense = widget.expense;
    final initialDate = expense?.date ?? DateFormat("MM-dd-yyyy").format(DateTime.now());

    titleC.text = expense?.title ?? "";
    amountC.text = expense == null ? "" : expense.amount.toString();
    noteC.text = expense?.note ?? "";
    ref.read(expenseDateTime.notifier).state = initialDate;
    ref.read(expenseTypeChooseProvider.notifier).state = null;

    await ref.read(expenseTypeProvider.notifier).getAllType();
    if (!mounted) return;

    if (expense == null) return;
 
    final expenseTypeState = ref.read(expenseTypeProvider);
    if (expenseTypeState is ExpenseTypeReadyState) {
      for (final type in expenseTypeState.expenseList) {
        if (type.id == expense.type) {
          ref.read(expenseTypeChooseProvider.notifier).state = type;
          break;
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final expenseType = ref.watch(expenseTypeProvider);
    final expenseTypeChoose = ref.watch(expenseTypeChooseProvider);
    final selectedExpenseType = expenseType is ExpenseTypeReadyState
        ? _typeFromList(expenseType.expenseList, expenseTypeChoose)
        : null;
    final date = ref.watch(expenseDateTime);
    final expenseState = ref.watch(expenseProvider);
    saveListener();
    return Scaffold(
      appBar: AppBar(title: Text(widget.expense == null ? "Add Expense" : "Edit Expense")),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
        child: Form(
          key: formKey,
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Title",
                  style: TextTheme.of(
                    context,
                  ).bodyMedium!.copyWith(color: AppColor.secondaryTextColor),
                ),
                const SizedBox(height: 4),
                TextFormField(
                  controller: titleC,
                  focusNode: titleF,
                  onTapOutside: (event) {
                    titleF.unfocus();
                  },
                  validator: (value) {
                    if(value == null || value.isEmpty){
                      return "title is required";
                    }else{
                      return null;
                    }
                  },
                  decoration: InputDecoration(
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(25),
                    ),
                    hint: Text(
                      "Enter expense title",
                      style: TextTheme.of(
                        context,
                      ).bodyLarge!.copyWith(color: AppColor.secondaryTextColor),
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  "Amount",
                  style: TextTheme.of(
                    context,
                  ).bodyMedium!.copyWith(color: AppColor.secondaryTextColor),
                ),
                const SizedBox(height: 4),
                TextFormField(
                  controller: amountC,
                  focusNode: amountF,
                  keyboardType: TextInputType.numberWithOptions(decimal: true),
                  onTapUpOutside: (event) {
                    amountF.unfocus();
                  },
                  validator: (value) {
                    if(value == null || value.isEmpty){
                      return "amount is required";
                    }else if(double.tryParse(value) == null){
                      return "amount must be a number";
                    }
                    return null;
                  },
                  decoration: InputDecoration(
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(25),
                    ),
                    hint: Text(
                      NumberFormatService.formatCurrency(0),
                      style: TextTheme.of(
                        context,
                      ).bodyLarge!.copyWith(color: AppColor.secondaryTextColor),
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  "Expense Type",
                  style: TextTheme.of(
                    context,
                  ).bodyMedium!.copyWith(color: AppColor.secondaryTextColor),
                ),
                const SizedBox(height: 4),
                expenseType is ExpenseTypeReadyState
                    ? DropdownButtonFormField<ExpenseTypeModel?>(
                        initialValue: selectedExpenseType,
                        focusNode: typeF,
                        borderRadius: BorderRadius.circular(25),
                        // underline: SizedBox(),
                        validator: (value) {
                          if(value == null){
                            return "choose the expense type";
                          }else{
                            return null;
                          }
                        },
                        items: [
                          DropdownMenuItem(
                            value: null,
                            child: Text(
                              "Select Type",
                              style: TextTheme.of(context).bodyLarge!.copyWith(
                                color: AppColor.secondaryTextColor,
                              ),
                            ),
                          ),
                          for (ExpenseTypeModel type
                              in expenseType.expenseList) ...[
                            DropdownMenuItem(
                              value: type,
                              child: Text(
                                type.title,
                                style: TextTheme.of(context).bodyLarge!
                                    .copyWith(
                                      color: AppColor.secondaryTextColor,
                                    ),
                              ),
                            ),
                          ],
                        ],
                        onChanged: (value) {
                          ref.read(expenseTypeChooseProvider.notifier).state =
                              value;
                        },
                      )
                    : const SizedBox(),
                const SizedBox(height: 8),
                Text(
                  "Date",
                  style: TextTheme.of(
                    context,
                  ).bodyMedium!.copyWith(color: AppColor.secondaryTextColor),
                ),
                const SizedBox(height: 4),
                ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Material(
                    child: InkWell(
                      onTap: () async {
                        ref.read(expenseDateTime.notifier)
                          .state = DateFormat("MM-dd-yyyy").format(
                          await showDatePicker(
                                context: context,
                                initialDate: DateTime.now(),
                                firstDate: DateTime(1900),
                                lastDate: DateTime.now(),
                              ) ??
                              DateTime.now(),
                        );
                      },
                      child: Container(
                        width: MediaQuery.of(context).size.width,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 24,
                          vertical: 16,
                        ),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(12),
                          color: AppColor.inputBackgroundColor,
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              date,
                              style: TextTheme.of(context).bodyLarge!.copyWith(
                                color: AppColor.secondaryTextColor,
                              ),
                            ),
                            Icon(
                              Icons.calendar_month,
                              color: AppColor.secondaryTextColor,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  "Note (Optional)",
                  style: TextTheme.of(
                    context,
                  ).bodyMedium!.copyWith(color: AppColor.secondaryTextColor),
                ),
                const SizedBox(height: 4),
                TextFormField(
                  controller: noteC,
                  focusNode: noteF,
                  onTapUpOutside: (event) {
                    noteF.unfocus();
                  },
                  decoration: InputDecoration(
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(25),
                    ),
                    hint: Text(
                      "Enter note",
                      style: TextTheme.of(
                        context,
                      ).bodyLarge!.copyWith(color: AppColor.secondaryTextColor),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () {
                    if(formKey.currentState!.validate()){
                      int type = expenseTypeChoose!.id!;
                      ExpenseModel expenseModel = ExpenseModel(
                        id: widget.expense?.id,
                        title: titleC.text,
                        amount: double.parse(amountC.text),
                        type: type,
                        date: date,
                        note: noteC.text,
                      );
                      if (widget.expense == null) {
                        ref.read(expenseProvider.notifier).addExpense(expenseModel);
                      } else {
                        ref.read(expenseProvider.notifier).editExpense(expenseModel);
                      }
                    }
                  }, child: switch (expenseState) {
                    ExpenseFormState() => Text(widget.expense == null ? "Save Expense" : "Update Expense"),
                    ExpenseLoadingState() => Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(widget.expense == null ? "Saving Expense" : "Updating Expense"),
                        const SizedBox(
                          width: 20,
                        ),
                        const SizedBox(
                          height: 25,
                          width: 25,
                          child: CircularProgressIndicator.adaptive(
                            backgroundColor: AppColor.onButton,
                          ),
                        )
                      ],
                    ),
                    ExpenseSuccessState() => Text(widget.expense == null ? "Save Expense" : "Update Expense"),
                    ExpenseErrorState() => Text(widget.expense == null ? "Save Expense" : "Update Expense"),
                  }),
              ],
            ),
          ),
        ),
      ),
    );
  }
  void saveListener() async{
    ref.listen(expenseProvider, (p,n){
      if (n is ExpenseSuccessState){
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(n.message)));
        context.pop();
      }else if(n is ExpenseErrorState){
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(n.errorMessage)));
      }
    });
  }

  ExpenseTypeModel? _typeFromList(
    List<ExpenseTypeModel> types,
    ExpenseTypeModel? selectedType,
  ) {
    if (selectedType == null) return null;
    for (final type in types) {
      if (type.id == selectedType.id) return type;
    }
    return null;
  }

  @override
  void dispose() {
    titleC.dispose();
    amountC.dispose();
    noteC.dispose();
    titleF.dispose();
    amountF.dispose();
    noteF.dispose();
    typeF.dispose();
    super.dispose();
  }
}
