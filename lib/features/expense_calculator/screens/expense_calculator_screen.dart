import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/services/app_number_formatter.dart';
import '../../expense/data/models/expense_model.dart';
import '../../expense/screens/providers/expense_provider.dart';
import '../domain/models/expense_calculator_models.dart';
import 'providers/expense_calculator_provider.dart';

class ExpenseCalculatorScreen extends ConsumerWidget {
  const ExpenseCalculatorScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(expenseCalculatorProvider);
    final expenseHistory = ref.watch(expenseListProvider);
    final colors = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          tooltip: 'Back',
          onPressed: () => context.pop(),
          icon: const Icon(Icons.arrow_back),
        ),
        title: const Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.calculate_outlined, size: 22),
            SizedBox(width: 8),
            Text('Calculator'),
          ],
        ),
        actions: [
          if (state.status == ExpenseCalculatorStatus.result)
            TextButton(
              onPressed: () =>
                  ref.read(expenseCalculatorProvider.notifier).reset(),
              child: const Text('Reset'),
            ),
          const SizedBox(width: 8),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Divider(color: colors.outline),
        ),
      ),
      body: SafeArea(
        child: AnimatedSwitcher(
          duration: const Duration(milliseconds: 350),
          switchInCurve: Curves.easeOutCubic,
          switchOutCurve: Curves.easeInCubic,
          child: switch (state.status) {
            ExpenseCalculatorStatus.editing => _CalculatorForm(
              key: const ValueKey('calculator-form'),
              state: state,
              expenseHistory: expenseHistory,
            ),
            ExpenseCalculatorStatus.calculating => const _CalculatingView(
              key: ValueKey('calculator-loading'),
            ),
            ExpenseCalculatorStatus.result => _CalculatorResultView(
              key: const ValueKey('calculator-result'),
              result: state.result!,
            ),
          },
        ),
      ),
    );
  }
}

class _CalculatorForm extends ConsumerWidget {
  final ExpenseCalculatorState state;
  final AsyncValue<List<ExpenseModel>> expenseHistory;

  const _CalculatorForm({
    super.key,
    required this.state,
    required this.expenseHistory,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = Theme.of(context).colorScheme;
    final notifier = ref.read(expenseCalculatorProvider.notifier);
    final history = switch (expenseHistory) {
      AsyncData(:final value) => value,
      _ => const <ExpenseModel>[],
    };

    return ListView(
      padding: const EdgeInsets.fromLTRB(14, 14, 14, 28),
      children: [
        OutlinedButton.icon(
          onPressed: expenseHistory.isLoading
              ? null
              : () {
                  final count = notifier.importTodayExpenses(history);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        count == 0
                            ? 'No new expenses found for today.'
                            : '$count expense${count == 1 ? '' : 's'} imported.',
                      ),
                    ),
                  );
                },
          icon: const Icon(Icons.download_outlined, size: 18),
          label: Text(
            expenseHistory.isLoading
                ? 'Loading expenses...'
                : "Import today's expenses from app",
          ),
          style: OutlinedButton.styleFrom(
            minimumSize: const Size.fromHeight(48),
            side: BorderSide(color: colors.outline),
            foregroundColor: colors.primary,
            backgroundColor: colors.surfaceContainer,
          ),
        ),
        const SizedBox(height: 12),
        _SectionCard(
          title: 'INCOME (OPTIONAL)',
          icon: Icons.account_balance_wallet_outlined,
          child: TextFormField(
            key: const ValueKey('calculator-income'),
            initialValue: state.incomeText,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            inputFormatters: [_decimalFormatter],
            onChanged: notifier.updateIncome,
            decoration: InputDecoration(
              hintText: '0.00',
              prefixText: '${NumberFormatService.currencySymbol(context)}  ',
              helperText: 'Leave blank to calculate the income you need.',
            ),
          ),
        ),
        const SizedBox(height: 12),
        _SectionCard(
          title: 'EXPENSES',
          icon: Icons.sell_outlined,
          child: Column(
            children: [
              for (final entry in state.entries) ...[
                _ExpenseInputRow(entry: entry),
                if (entry != state.entries.last) const SizedBox(height: 8),
              ],
              const SizedBox(height: 10),
              OutlinedButton.icon(
                onPressed: notifier.addExpense,
                icon: const Icon(Icons.add, size: 18),
                label: const Text('Add Expense'),
                style: OutlinedButton.styleFrom(
                  minimumSize: const Size.fromHeight(46),
                  side: BorderSide(color: colors.outline),
                  foregroundColor: colors.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ),
        if (state.errorMessage != null) ...[
          const SizedBox(height: 10),
          Text(
            state.errorMessage!,
            textAlign: TextAlign.center,
            style: TextStyle(color: colors.error, fontWeight: FontWeight.w600),
          ),
        ],
        const SizedBox(height: 12),
        ElevatedButton.icon(
          onPressed: () => notifier.calculate(history),
          icon: const Icon(Icons.auto_graph_outlined, size: 20),
          label: const Text('Calculate'),
        ),
      ],
    );
  }
}

class _ExpenseInputRow extends ConsumerWidget {
  final CalculatorExpenseEntry entry;

  const _ExpenseInputRow({required this.entry});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = Theme.of(context).colorScheme;
    final notifier = ref.read(expenseCalculatorProvider.notifier);

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          flex: 5,
          child: TextFormField(
            key: ValueKey('title-${entry.id}'),
            initialValue: entry.title,
            textCapitalization: TextCapitalization.sentences,
            onChanged: (value) =>
                notifier.updateExpense(entry.id, title: value),
            decoration: const InputDecoration(
              hintText: 'Expense title',
              contentPadding: EdgeInsets.symmetric(
                horizontal: 12,
                vertical: 12,
              ),
            ),
          ),
        ),
        const SizedBox(width: 7),
        Expanded(
          flex: 3,
          child: TextFormField(
            key: ValueKey('amount-${entry.id}'),
            initialValue: entry.amountText,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            inputFormatters: [_decimalFormatter],
            onChanged: (value) =>
                notifier.updateExpense(entry.id, amountText: value),
            decoration: const InputDecoration(
              hintText: '0.00',
              contentPadding: EdgeInsets.symmetric(
                horizontal: 10,
                vertical: 12,
              ),
            ),
          ),
        ),
        const SizedBox(width: 7),
        SizedBox(
          width: 42,
          height: 48,
          child: IconButton(
            tooltip: 'Remove expense',
            onPressed: () => notifier.removeExpense(entry.id),
            style: IconButton.styleFrom(
              foregroundColor: colors.error,
              backgroundColor: colors.error.withValues(alpha: .1),
            ),
            icon: const Icon(Icons.close, size: 20),
          ),
        ),
      ],
    );
  }
}

class _SectionCard extends StatelessWidget {
  final String title;
  final IconData icon;
  final Widget child;

  const _SectionCard({
    required this.title,
    required this.icon,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, size: 15, color: colors.primary),
                const SizedBox(width: 7),
                Text(
                  title,
                  style: Theme.of(context).textTheme.labelMedium?.copyWith(
                    letterSpacing: 1.1,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            child,
          ],
        ),
      ),
    );
  }
}

class _CalculatingView extends StatelessWidget {
  const _CalculatingView({super.key});

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return Center(
      child: TweenAnimationBuilder<double>(
        tween: Tween(begin: .85, end: 1),
        curve: Curves.easeOutBack,
        duration: const Duration(milliseconds: 600),
        builder: (context, scale, child) =>
            Transform.scale(scale: scale, child: child),
        child: Card(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 36, vertical: 30),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                SizedBox(
                  width: 46,
                  height: 46,
                  child: CircularProgressIndicator(color: colors.primary),
                ),
                const SizedBox(height: 18),
                Text(
                  'Evaluating your plan...',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: 5),
                Text(
                  'Calculating balance and recommendations',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _CalculatorResultView extends StatelessWidget {
  final ExpenseCalculatorResult result;

  const _CalculatorResultView({super.key, required this.result});

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final balanceColor = !result.hasIncome
        ? colors.tertiary
        : result.isSurplus
        ? colors.primary
        : colors.error;
    final statusText = !result.hasIncome
        ? 'Income needed'
        : result.isSurplus
        ? 'Surplus'
        : 'Deficit';

    return ListView(
      padding: const EdgeInsets.fromLTRB(14, 14, 14, 30),
      children: [
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      result.hasIncome ? 'Balance' : 'Minimum income required',
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 5,
                      ),
                      decoration: BoxDecoration(
                        color: balanceColor.withValues(alpha: .14),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: balanceColor.withValues(alpha: .55),
                        ),
                      ),
                      child: Text(
                        statusText,
                        style: TextStyle(
                          color: balanceColor,
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                Text(
                  result.hasIncome
                      ? _signedCurrency(context, result.balance)
                      : NumberFormatService.formatCurrency(
                          context,
                          result.minimumIncome,
                        ),
                  style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                    color: balanceColor,
                    fontSize: 32,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 16),
                if (result.hasIncome)
                  _ResultLine(
                    icon: Icons.account_balance_wallet_outlined,
                    label: 'Income',
                    value: NumberFormatService.formatCurrency(
                      context,
                      result.income!,
                    ),
                    valueColor: colors.primary,
                  ),
                if (result.hasIncome) const SizedBox(height: 8),
                _ResultLine(
                  icon: Icons.sell_outlined,
                  label: 'Total expenses',
                  value: NumberFormatService.formatCurrency(
                    context,
                    result.totalExpenses,
                  ),
                  valueColor: colors.error,
                ),
                const SizedBox(height: 8),
                _ResultLine(
                  icon: Icons.savings_outlined,
                  label: result.hasIncome && result.additionalIncomeNeeded > 0
                      ? 'More income to break even'
                      : 'Recommended income (20% buffer)',
                  value: NumberFormatService.formatCurrency(
                    context,
                    result.hasIncome && result.additionalIncomeNeeded > 0
                        ? result.additionalIncomeNeeded
                        : result.recommendedIncome,
                  ),
                  valueColor: colors.tertiary,
                ),
                const SizedBox(height: 16),
                Text(
                  'BREAKDOWN',
                  style: Theme.of(context).textTheme.labelSmall?.copyWith(
                    letterSpacing: 1.2,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 6),
                for (final item in result.breakdown) ...[
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    child: Row(
                      children: [
                        Expanded(
                          child: Text(
                            '${item.title}  ${item.percentage.toStringAsFixed(1)}%',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(color: colors.onSurfaceVariant),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Text(
                          '-${NumberFormatService.formatCurrency(context, item.amount)}',
                          style: TextStyle(
                            color: colors.error,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Divider(color: colors.outline),
                ],
              ],
            ),
          ),
        ),
        const SizedBox(height: 12),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      width: 38,
                      height: 38,
                      decoration: BoxDecoration(
                        color: colors.primary,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Icon(Icons.auto_awesome, color: colors.onPrimary),
                    ),
                    const SizedBox(width: 10),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Smart Financial Advisor',
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                        Text(
                          'Based on your expense data',
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 14),
                for (var index = 0; index < result.suggestions.length; index++)
                  Padding(
                    padding: EdgeInsets.only(
                      bottom: index == result.suggestions.length - 1 ? 0 : 12,
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Icon(
                          Icons.check_circle_outline,
                          size: 18,
                          color: colors.primary,
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            result.suggestions[index],
                            style: TextStyle(
                              color: colors.onSurfaceVariant,
                              height: 1.4,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _ResultLine extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color valueColor;

  const _ResultLine({
    required this.icon,
    required this.label,
    required this.value,
    required this.valueColor,
  });

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
      decoration: BoxDecoration(
        color: colors.surfaceContainer,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        children: [
          Icon(icon, size: 17, color: colors.onSurfaceVariant),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              label,
              style: TextStyle(color: colors.onSurfaceVariant),
            ),
          ),
          Text(
            value,
            style: TextStyle(color: valueColor, fontWeight: FontWeight.w700),
          ),
        ],
      ),
    );
  }
}

String _signedCurrency(BuildContext context, double value) {
  final prefix = value >= 0 ? '+' : '-';
  return '$prefix${NumberFormatService.formatCurrency(context, value.abs())}';
}

final _decimalFormatter = FilteringTextInputFormatter.allow(
  RegExp(r'^\d*\.?\d{0,2}'),
);
