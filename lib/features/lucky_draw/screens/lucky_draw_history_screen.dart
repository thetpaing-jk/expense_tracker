import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../core/services/app_number_formatter.dart';
import '../../../core/utils/app_const.dart';
import '../../expense/data/models/expense_model.dart';
import '../../expense/screens/providers/expense_provider.dart';
import '../domain/usecases/lucky_draw_history_calculator.dart';
import 'providers/lucky_draw_provider.dart';

class LuckyDrawHistoryScreen extends ConsumerWidget {
  const LuckyDrawHistoryScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final drawsState = ref.watch(luckyDrawHistoryProvider);
    final expensesState = ref.watch(expenseListProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Lucky Draw History')),
      body: SafeArea(
        child: drawsState.when(
          loading: () =>
              const Center(child: CircularProgressIndicator.adaptive()),
          error: (error, _) => _HistoryError(
            message: error.toString(),
            onRetry: () => ref.invalidate(luckyDrawHistoryProvider),
          ),
          data: (draws) => expensesState.when(
            loading: () =>
                const Center(child: CircularProgressIndicator.adaptive()),
            error: (error, _) => _HistoryError(
              message: error.toString(),
              onRetry: () => ref.invalidate(expenseListProvider),
            ),
            data: (expenses) => _HistoryList(
              entries: LuckyDrawHistoryCalculator.build(
                draws: draws,
                expenses: expenses,
              ),
              onRefresh: () async {
                ref.invalidate(luckyDrawHistoryProvider);
                ref.invalidate(expenseListProvider);
                await Future.wait([
                  ref.read(luckyDrawHistoryProvider.future),
                  ref.read(expenseListProvider.future),
                ]);
              },
            ),
          ),
        ),
      ),
    );
  }
}

class _HistoryList extends StatelessWidget {
  final List<LuckyDrawHistoryEntry> entries;
  final Future<void> Function() onRefresh;

  const _HistoryList({required this.entries, required this.onRefresh});

  @override
  Widget build(BuildContext context) {
    if (entries.isEmpty) {
      return RefreshIndicator(
        onRefresh: onRefresh,
        child: ListView(
          physics: const AlwaysScrollableScrollPhysics(),
          children: [
            SizedBox(height: MediaQuery.sizeOf(context).height * .22),
            const Icon(Icons.history, size: 58),
            const SizedBox(height: 12),
            Text(
              'No drawn ticket history yet.',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.titleMedium,
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: onRefresh,
      child: ListView.separated(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 28),
        itemCount: entries.length,
        separatorBuilder: (_, _) => const SizedBox(height: 10),
        itemBuilder: (context, index) => _HistoryCard(entry: entries[index]),
      ),
    );
  }
}

class _HistoryCard extends StatelessWidget {
  final LuckyDrawHistoryEntry entry;

  const _HistoryCard({required this.entry});

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final statusColor = entry.isOverBudget ? colors.error : colors.primary;
    final statusLabel = entry.isOverBudget
        ? 'Over ${NumberFormatService.formatCurrency(context, entry.overBudgetAmount)}'
        : 'Left ${NumberFormatService.formatCurrency(context, entry.remainingAmount)}';

    return Card(
      margin: EdgeInsets.zero,
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () =>
            context.pushNamed(AppConst.luckyDrawHistoryDetail, extra: entry),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          DateFormat('EEE, MMM d, yyyy').format(entry.date),
                          style: Theme.of(context).textTheme.titleSmall,
                        ),
                        const SizedBox(height: 2),
                        Text(
                          'Ticket #${entry.ticket.ticketNo}',
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 9,
                      vertical: 5,
                    ),
                    decoration: BoxDecoration(
                      color: statusColor.withValues(alpha: .12),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      statusLabel,
                      style: Theme.of(context).textTheme.labelSmall!.copyWith(
                        color: statusColor,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                  const SizedBox(width: 4),
                  const Icon(Icons.chevron_right),
                ],
              ),
              const SizedBox(height: 13),
              LinearProgressIndicator(
                value: entry.progress,
                minHeight: 7,
                borderRadius: BorderRadius.circular(8),
                color: statusColor,
                backgroundColor: colors.surfaceContainerHighest,
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  _HistoryValue(
                    label: 'Lucky budget',
                    value: NumberFormatService.formatCurrency(
                      context,
                      entry.ticket.amount,
                    ),
                  ),
                  _HistoryValue(
                    label: 'Spent',
                    value: NumberFormatService.formatCurrency(
                      context,
                      entry.spentAmount,
                    ),
                    alignEnd: true,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class LuckyDrawHistoryDetailScreen extends StatelessWidget {
  final LuckyDrawHistoryEntry entry;

  const LuckyDrawHistoryDetailScreen({super.key, required this.entry});

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final statusColor = entry.isOverBudget ? colors.error : colors.primary;
    final differenceLabel = entry.isOverBudget ? 'Over budget' : 'Remaining';
    final differenceAmount = entry.isOverBudget
        ? entry.overBudgetAmount
        : entry.remainingAmount;

    return Scaffold(
      appBar: AppBar(title: Text(DateFormat('MMM d, yyyy').format(entry.date))),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: statusColor.withValues(alpha: .10),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: statusColor.withValues(alpha: .4)),
                ),
                child: Column(
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            'Ticket #${entry.ticket.ticketNo}',
                            style: Theme.of(context).textTheme.titleMedium,
                          ),
                        ),
                        Text(
                          NumberFormatService.formatCurrency(
                            context,
                            entry.ticket.amount,
                          ),
                          style: Theme.of(context).textTheme.titleMedium!
                              .copyWith(fontWeight: FontWeight.w800),
                        ),
                      ],
                    ),
                    const SizedBox(height: 14),
                    LinearProgressIndicator(
                      value: entry.progress,
                      minHeight: 8,
                      borderRadius: BorderRadius.circular(8),
                      color: statusColor,
                      backgroundColor: colors.surface,
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        _HistoryValue(
                          label: 'Spent',
                          value: NumberFormatService.formatCurrency(
                            context,
                            entry.spentAmount,
                          ),
                        ),
                        _HistoryValue(
                          label: differenceLabel,
                          value: NumberFormatService.formatCurrency(
                            context,
                            differenceAmount,
                          ),
                          valueColor: statusColor,
                          alignEnd: true,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 18),
              Text(
                'Expenses (${entry.expenses.length})',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: 8),
              if (entry.expenses.isEmpty)
                const Expanded(
                  child: Center(
                    child: Text('No expenses were deducted on this day.'),
                  ),
                )
              else
                Expanded(
                  child: ListView.separated(
                    padding: const EdgeInsets.only(bottom: 24),
                    itemCount: entry.expenses.length,
                    separatorBuilder: (_, _) => const SizedBox(height: 8),
                    itemBuilder: (context, index) =>
                        _ExpenseHistoryTile(expense: entry.expenses[index]),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ExpenseHistoryTile extends StatelessWidget {
  final ExpenseModel expense;

  const _ExpenseHistoryTile({required this.expense});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.zero,
      child: ListTile(
        leading: const CircleAvatar(child: Icon(Icons.receipt_long_outlined)),
        title: Text(
          expense.title,
          style: const TextStyle(fontWeight: FontWeight.w700),
        ),
        subtitle: expense.note.trim().isEmpty
            ? null
            : Text(expense.note, maxLines: 2, overflow: TextOverflow.ellipsis),
        trailing: Text(
          NumberFormatService.formatCurrency(context, expense.amount),
          style: Theme.of(
            context,
          ).textTheme.titleSmall!.copyWith(fontWeight: FontWeight.w800),
        ),
      ),
    );
  }
}

class _HistoryValue extends StatelessWidget {
  final String label;
  final String value;
  final Color? valueColor;
  final bool alignEnd;

  const _HistoryValue({
    required this.label,
    required this.value,
    this.valueColor,
    this.alignEnd = false,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(
        crossAxisAlignment: alignEnd
            ? CrossAxisAlignment.end
            : CrossAxisAlignment.start,
        children: [
          Text(label, style: Theme.of(context).textTheme.bodySmall),
          const SizedBox(height: 2),
          Text(
            value,
            style: Theme.of(context).textTheme.labelLarge!.copyWith(
              color: valueColor,
              fontWeight: FontWeight.w800,
            ),
          ),
        ],
      ),
    );
  }
}

class _HistoryError extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;

  const _HistoryError({required this.message, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('Unable to load Lucky Draw history.'),
            const SizedBox(height: 6),
            Text(message, textAlign: TextAlign.center),
            const SizedBox(height: 12),
            OutlinedButton(onPressed: onRetry, child: const Text('Try Again')),
          ],
        ),
      ),
    );
  }
}
