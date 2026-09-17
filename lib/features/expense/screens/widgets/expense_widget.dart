import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../../core/services/app_number_formatter.dart';
import '../../../../core/utils/app_color.dart';
import '../../../../core/utils/app_const.dart';
import '../../../expense_type/screens/providers/expense_type_provider.dart';
import '../../data/models/expense_model.dart';
import '../providers/expense_provider.dart';
import '../providers/expense_provider_state.dart';

class ExpenseWidget extends ConsumerStatefulWidget {
  final ExpenseModel expense;
  const ExpenseWidget({super.key, required this.expense});

  @override
  ConsumerState<ExpenseWidget> createState() => _ExpenseWidgetState();
}

class _ExpenseWidgetState extends ConsumerState<ExpenseWidget> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final expenseTypeState = ref.watch(expenseTypeByIdProvider(widget.expense.type));
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 8),
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: AppColor.cardBackgroundColor,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          expenseTypeState.when(data: (expense) => expense == null ?
            const SizedBox()
            :Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
              decoration: BoxDecoration(
                color: AppConst.colorList[expense.iconColor].withValues(alpha: .4),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Image.asset(
                "${AppConst.expneseTypeUrl}${AppConst.iconList[expense.icon]}.png",
                width: 25,
              ),
            ),
            error: (_,_) =>  Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
              decoration: BoxDecoration(
                color: AppColor.primaryColor,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(Icons.error, color: AppColor.dangerColor,)
            ), loading: ()=> Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
              decoration: BoxDecoration(
                color: AppColor.primaryColor,
                borderRadius: BorderRadius.circular(12),
              ),
              child: CircularProgressIndicator.adaptive()
            ),),
          const SizedBox(width: 8),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                widget.expense.title,
                style: TextTheme.of(
                  context,
                ).bodyLarge!.copyWith(fontWeight: FontWeight.bold),
              ),
              Text(
                widget.expense.note,
                style: TextTheme.of(
                  context,
                ).bodyMedium!.copyWith(color: AppColor.secondaryTextColor),
              ),
              Text(
                DateFormat(
                  "MMM dd - yyyy",
                ).format(DateFormat("MM-dd-yyyy").parse(widget.expense.date)),
                style: TextTheme.of(context).bodySmall,
              ),
            ],
          ),
          Spacer(),
          Column(
            children: [
              Text(
                NumberFormatService.formatCurrency(widget.expense.amount),
                style: TextTheme.of(
                  context,
                ).bodyLarge!.copyWith(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 4),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  IconButton(
                    onPressed: () {
                      context.goNamed(
                        AppConst.addExpenseScreen,
                        extra: widget.expense,
                      );
                    },
                    icon: Icon(Icons.edit),
                    color: AppColor.warrningColor,
                    // constraints: const BoxConstraints(
                    //   minWidth: 36,
                    //   minHeight: 36,
                    // ),
                    padding: const EdgeInsets.all(6),
                  ),
                  const SizedBox(width: 6),
                  IconButton(
                    onPressed: () => _deleteExpense(context, ref),
                    icon: Icon(Icons.delete),
                    color: AppColor.dangerColor,
                    // constraints: const BoxConstraints(
                    //   minWidth: 36,
                    //   minHeight: 36,
                    // ),
                    padding: const EdgeInsets.all(6),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  Future<void> _deleteExpense(BuildContext context, WidgetRef ref) async {
    final expenseId = widget.expense.id;
    if (expenseId == null) return;

    final shouldDelete = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text("Delete Expense"),
          content: Text(
            "Are you sure you want to delete ${widget.expense.title}?",
          ),
          actions: [
            TextButton(
              onPressed: () => context.pop(false),
              child: Text("Cancel"),
            ),
            TextButton(
              onPressed: () => context.pop(true),
              child: Text(
                "Delete",
                style: TextStyle(color: AppColor.dangerColor),
              ),
            ),
          ],
        );
      },
    );

    if (shouldDelete != true) return;

    await ref.read(expenseProvider.notifier).deleteExpense(expenseId);
    if (!context.mounted) return;

    final expenseState = ref.read(expenseProvider);
    final message = switch (expenseState) {
      ExpenseSuccessState() => expenseState.message,
      ExpenseErrorState() => expenseState.errorMessage,
      _ => "",
    };

    if (message.isNotEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(message)));
    }
  }
}
