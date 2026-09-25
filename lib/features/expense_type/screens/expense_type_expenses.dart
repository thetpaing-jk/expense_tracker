import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../core/services/app_number_formatter.dart';
import '../../../core/utils/app_const.dart';
import '../../expense/data/models/expense_model.dart';
import '../../expense/domain/usecases/expense_date_filter.dart';
import '../../expense/screens/providers/expense_provider.dart';
import '../data/models/expense_type_model.dart';

class ExpenseTypeExpensesScreen extends ConsumerWidget {
  final ExpenseTypeModel expenseType;

  const ExpenseTypeExpensesScreen({super.key, required this.expenseType});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final expensesState = ref.watch(expenseListProvider);
    return Scaffold(
      appBar: AppBar(title: Text(expenseType.title)),
      body: SafeArea(
        child: expensesState.when(
          loading: () =>
              const Center(child: CircularProgressIndicator.adaptive()),
          error: (error, _) => Center(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Text(
                'Unable to load expenses.\n$error',
                textAlign: TextAlign.center,
              ),
            ),
          ),
          data: (expenses) => _ExpenseTypeExpenseList(
            expenseType: expenseType,
            expenses: ExpenseDateFilterService.expensesForType(
              expenses,
              expenseType.id!,
            ),
          ),
        ),
      ),
    );
  }
}

class _ExpenseTypeExpenseList extends StatelessWidget {
  final ExpenseTypeModel expenseType;
  final List<ExpenseModel> expenses;

  const _ExpenseTypeExpenseList({
    required this.expenseType,
    required this.expenses,
  });

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final total = expenses.fold<double>(
      0,
      (sum, expense) => sum + expense.amount,
    );

    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 12, 24, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: colors.primaryContainer,
              borderRadius: BorderRadius.circular(14),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppConst.colorList[expenseType.iconColor].withValues(
                      alpha: .3,
                    ),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Image.asset(
                    '${AppConst.expneseTypeUrl}${AppConst.iconList[expenseType.icon]}.png',
                    width: 28,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '${expenses.length} Expense${expenses.length == 1 ? '' : 's'}',
                        style: Theme.of(context).textTheme.labelLarge,
                      ),
                      const SizedBox(height: 3),
                      Text(
                        NumberFormatService.formatCurrency(context, total),
                        style: Theme.of(context).textTheme.titleLarge!.copyWith(
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 18),
          Text('Expenses', style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 8),
          if (expenses.isEmpty)
            Expanded(
              child: Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.receipt_long_outlined,
                      size: 52,
                      color: colors.onSurfaceVariant,
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'No expenses use this type yet.',
                      style: Theme.of(context).textTheme.bodyLarge,
                    ),
                  ],
                ),
              ),
            )
          else
            Expanded(
              child: ListView.separated(
                padding: const EdgeInsets.only(bottom: 24),
                itemCount: expenses.length,
                separatorBuilder: (_, _) => const SizedBox(height: 8),
                itemBuilder: (context, index) {
                  final expense = expenses[index];
                  return Card(
                    margin: EdgeInsets.zero,
                    child: ListTile(
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 6,
                      ),
                      title: Text(
                        expense.title,
                        style: const TextStyle(fontWeight: FontWeight.w700),
                      ),
                      subtitle: Text(
                        [
                          DateFormat('MMM d, yyyy').format(
                            ExpenseDateFilterService.parseExpenseDate(
                                  expense.date,
                                ) ??
                                DateTime.now(),
                          ),
                          if (expense.note.trim().isNotEmpty) expense.note,
                        ].join(' · '),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      trailing: Text(
                        NumberFormatService.formatCurrency(
                          context,
                          expense.amount,
                        ),
                        style: Theme.of(context).textTheme.titleSmall!.copyWith(
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
        ],
      ),
    );
  }
}
