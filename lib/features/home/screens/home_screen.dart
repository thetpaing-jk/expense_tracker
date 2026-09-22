import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../core/services/app_number_formatter.dart';
import '../../../core/utils/app_const.dart';
import '../../budget/data/models/budget_model.dart';
import '../../budget/screens/providers/budget_provider.dart';
import '../../expense/data/models/expense_model.dart';
import '../../expense/domain/usecases/expense_date_filter.dart';
import '../../expense/screens/providers/expense_provider.dart';
import '../../expense_type/data/models/expense_type_model.dart';
import '../../expense_type/screens/providers/expense_type_provider.dart';
import '../../lucky_draw/data/models/lucky_draw_model.dart';
import '../../lucky_draw/screens/providers/lucky_draw_provider.dart';
import '../../lucky_draw/screens/providers/lucky_draw_provider_state.dart';
import '../domain/usecases/home_summary_calculator.dart';
import 'providers/home_provider.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  bool _checkingLuckyDraw = true;

  @override
  void initState() {
    super.initState();
    Future.microtask(_loadHomeData);
  }

  Future<void> _loadHomeData() async {
    await _loadLuckyDraw();
  }

  Future<void> _loadLuckyDraw() async {
    if (mounted) setState(() => _checkingLuckyDraw = true);
    await ref.read(luckyDrawProvider.notifier).getCurrentDraw();
    if (mounted) setState(() => _checkingLuckyDraw = false);
  }

  @override
  Widget build(BuildContext context) {
    final selectedPeriod = ref.watch(dropdownProvider);
    final expenseState = ref.watch(expenseListProvider);
    final budgetState = ref.watch(budgetListProvider);
    final luckyDrawState = ref.watch(luckyDrawProvider);
    final expenseTypeState = ref.watch(expenseTypeListProvider);

    final expenses = switch (expenseState) {
      AsyncData(:final value) => value,
      _ => const <ExpenseModel>[],
    };
    final budgets = switch (budgetState) {
      AsyncData(:final value) => value,
      _ => const <BudgetModel>[],
    };
    final luckyDraw = switch (luckyDrawState) {
      LuckyDrawReadyState(:final draw) => draw,
      _ => null,
    };
    final expenseTypes = switch (expenseTypeState) {
      AsyncData(:final value) => value,
      _ => const <ExpenseTypeModel>[],
    };
    final summary = HomeSummaryCalculator.calculate(
      expenses: expenses,
      budgets: budgets,
      period: selectedPeriod,
      luckyDraw: luckyDraw,
    );

    return Scaffold(
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: () async {
            ref.invalidate(expenseListProvider);
            ref.invalidate(budgetListProvider);
            ref.invalidate(expenseTypeListProvider);
            await Future.wait([
              ref.read(expenseListProvider.future),
              ref.read(budgetListProvider.future),
              ref.read(expenseTypeListProvider.future),
              _loadHomeData(),
            ]);
          },
          child: ListView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.fromLTRB(24, 14, 24, 96),
            children: [
              const _HomeHeader(),
              const SizedBox(height: 20),
              _ExpenseSummarySection(
                selectedPeriod: selectedPeriod,
                onPeriodChanged: (period) {
                  ref.read(dropdownProvider.notifier).state = period;
                },
                summary: summary,
                expensesLoading: expenseState is! AsyncData,
                budgetsLoading: budgetState is! AsyncData,
                luckyDraw: luckyDraw,
                luckyDrawState: luckyDrawState,
                checkingLuckyDraw: _checkingLuckyDraw,
                onLuckyDrawTap: luckyDrawState is LuckyDrawErrorState
                    ? _loadLuckyDraw
                    : () => _openLuckyDraw(luckyDraw),
                onBudgetTap: () => context.pushNamed(AppConst.budget),
              ),
              const SizedBox(height: 14),
              _ExpenseOverviewSection(
                selectedPeriod: selectedPeriod,
                onPeriodChanged: (period) {
                  ref.read(dropdownProvider.notifier).state = period;
                },
                categoryTotals: HomeSummaryCalculator.categoryTotals(
                  expenses,
                  period: selectedPeriod,
                ),
                expenseTypes: expenseTypes,
                loading:
                    expenseState is! AsyncData ||
                    expenseTypeState is! AsyncData,
              ),
              const SizedBox(height: 14),
              _RecentExpensesSection(
                expenses: HomeSummaryCalculator.recentExpenses(expenses),
                expenseTypes: expenseTypes,
                loading:
                    expenseState is! AsyncData ||
                    expenseTypeState is! AsyncData,
                onSeeAll: () => context.go(AppConst.expense),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _openLuckyDraw(LuckyDrawModel? luckyDraw) async {
    if (luckyDraw == null) {
      await context.push('/lucky-draw/create');
    } else {
      await context.push('/lucky-draw');
    }
    if (mounted) await _loadLuckyDraw();
  }
}

class _ExpenseSummarySection extends StatelessWidget {
  final HomeExpensePeriod selectedPeriod;
  final ValueChanged<HomeExpensePeriod> onPeriodChanged;
  final HomeSummaryData summary;
  final bool expensesLoading;
  final bool budgetsLoading;
  final LuckyDrawModel? luckyDraw;
  final LuckyDrawState luckyDrawState;
  final bool checkingLuckyDraw;
  final VoidCallback onLuckyDrawTap;
  final VoidCallback onBudgetTap;

  const _ExpenseSummarySection({
    required this.selectedPeriod,
    required this.onPeriodChanged,
    required this.summary,
    required this.expensesLoading,
    required this.budgetsLoading,
    required this.luckyDraw,
    required this.luckyDrawState,
    required this.checkingLuckyDraw,
    required this.onLuckyDrawTap,
    required this.onBudgetTap,
  });

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final luckyLoading =
        checkingLuckyDraw || luckyDrawState is LuckyDrawLoadingState;
    final luckyHasError = luckyDrawState is LuckyDrawErrorState;

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: colors.outline),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  'Total Expense',
                  style: Theme.of(context).textTheme.labelLarge,
                ),
              ),
              _PeriodDropdown(
                value: selectedPeriod,
                onChanged: onPeriodChanged,
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            expensesLoading
                ? '—'
                : NumberFormatService.formatCurrency(
                    context,
                    summary.periodExpense,
                  ),
            style: Theme.of(
              context,
            ).textTheme.headlineLarge!.copyWith(fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: 18),
          Row(
            children: [
              Expanded(
                child: _SummaryCard(
                  label: 'Today Expense',
                  value: expensesLoading
                      ? '—'
                      : NumberFormatService.formatCurrency(
                          context,
                          summary.todayExpense,
                        ),
                  icon: Icons.flight_takeoff_outlined,
                  iconColor: colors.primary,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _SummaryCard(
                  label: selectedPeriod.label,
                  value: expensesLoading
                      ? '—'
                      : NumberFormatService.formatCurrency(
                          context,
                          summary.periodExpense,
                        ),
                  icon: Icons.calendar_month_outlined,
                  iconColor: colors.tertiary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                child: _SummaryCard(
                  label: 'Lucky Budget',
                  value: luckyLoading
                      ? '—'
                      : luckyHasError
                      ? 'Unable to load'
                      : luckyDraw == null
                      ? 'No lucky draw program'
                      : NumberFormatService.formatCurrency(
                          context,
                          summary.luckyBudgetRemaining ?? 0,
                        ),
                  icon: Icons.favorite,
                  iconColor: colors.primary,
                  actionLabel: luckyHasError
                      ? 'Retry'
                      : !luckyLoading && luckyDraw == null
                      ? 'Create'
                      : null,
                  onTap: luckyLoading ? null : onLuckyDrawTap,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _SummaryCard(
                  label: 'Your Budget',
                  value: budgetsLoading
                      ? '—'
                      : NumberFormatService.formatCurrency(
                          context,
                          summary.totalBudget,
                        ),
                  icon: Icons.favorite,
                  iconColor: colors.secondary,
                  onTap: onBudgetTap,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _PeriodDropdown extends StatelessWidget {
  final HomeExpensePeriod value;
  final ValueChanged<HomeExpensePeriod> onChanged;

  const _PeriodDropdown({required this.value, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.only(left: 10, right: 4),
      decoration: BoxDecoration(
        color: colors.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(9),
        border: Border.all(color: colors.outline),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<HomeExpensePeriod>(
          value: value,
          isDense: true,
          borderRadius: BorderRadius.circular(12),
          style: Theme.of(
            context,
          ).textTheme.labelMedium!.copyWith(color: colors.primary),
          items: [
            for (final period in HomeExpensePeriod.values)
              DropdownMenuItem(value: period, child: Text(period.label)),
          ],
          onChanged: (period) {
            if (period != null) onChanged(period);
          },
        ),
      ),
    );
  }
}

class _SummaryCard extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final Color iconColor;
  final String? actionLabel;
  final VoidCallback? onTap;

  const _SummaryCard({
    required this.label,
    required this.value,
    required this.icon,
    required this.iconColor,
    this.actionLabel,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return Material(
      color: colors.surfaceContainerHigh,
      borderRadius: BorderRadius.circular(14),
      child: InkWell(
        borderRadius: BorderRadius.circular(14),
        onTap: onTap,
        child: Container(
          constraints: const BoxConstraints(minHeight: 92),
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: colors.outline),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      label,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.labelSmall,
                    ),
                  ),
                  Icon(icon, size: 16, color: iconColor),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                value,
                maxLines: actionLabel == null ? 1 : 2,
                overflow: TextOverflow.ellipsis,
                style: Theme.of(
                  context,
                ).textTheme.titleSmall!.copyWith(fontWeight: FontWeight.w800),
              ),
              if (actionLabel != null) ...[
                const SizedBox(height: 5),
                Text(
                  actionLabel!,
                  style: Theme.of(context).textTheme.labelSmall!.copyWith(
                    color: colors.primary,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class _ExpenseOverviewSection extends StatelessWidget {
  final HomeExpensePeriod selectedPeriod;
  final ValueChanged<HomeExpensePeriod> onPeriodChanged;
  final Map<int, double> categoryTotals;
  final List<ExpenseTypeModel> expenseTypes;
  final bool loading;

  const _ExpenseOverviewSection({
    required this.selectedPeriod,
    required this.onPeriodChanged,
    required this.categoryTotals,
    required this.expenseTypes,
    required this.loading,
  });

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final categories = _buildCategories(context);
    final total = categories.fold<double>(
      0,
      (sum, category) => sum + category.amount,
    );

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: colors.outline),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  'Expense Overview',
                  style: Theme.of(context).textTheme.titleMedium!.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              _PeriodDropdown(
                value: selectedPeriod,
                onChanged: onPeriodChanged,
              ),
            ],
          ),
          const SizedBox(height: 18),
          if (loading)
            const SizedBox(
              height: 120,
              child: Center(child: CircularProgressIndicator.adaptive()),
            )
          else if (categories.isEmpty)
            SizedBox(
              height: 100,
              child: Center(
                child: Text(
                  'No expenses for ${selectedPeriod.label.toLowerCase()}.',
                  style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                    color: colors.onSurfaceVariant,
                  ),
                ),
              ),
            )
          else
            Row(
              children: [
                SizedBox(
                  width: 105,
                  height: 105,
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      PieChart(
                        PieChartData(
                          startDegreeOffset: -90,
                          centerSpaceRadius: 29,
                          sectionsSpace: 2,
                          borderData: FlBorderData(show: false),
                          sections: [
                            for (final category in categories)
                              PieChartSectionData(
                                value: category.amount,
                                color: category.color,
                                radius: 17,
                                showTitle: false,
                              ),
                          ],
                        ),
                        duration: const Duration(milliseconds: 450),
                      ),
                      Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            'Total',
                            style: Theme.of(context).textTheme.labelSmall,
                          ),
                          Text(
                            NumberFormatService.formatCompact(total),
                            style: Theme.of(context).textTheme.labelSmall!
                                .copyWith(fontWeight: FontWeight.w800),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    children: [
                      for (final category in categories)
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 3),
                          child: Row(
                            children: [
                              Container(
                                width: 8,
                                height: 8,
                                decoration: BoxDecoration(
                                  color: category.color,
                                  shape: BoxShape.circle,
                                ),
                              ),
                              const SizedBox(width: 6),
                              Expanded(
                                child: Text(
                                  category.label,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: Theme.of(context).textTheme.labelSmall,
                                ),
                              ),
                              Text(
                                '${(category.amount / total * 100).round()}%',
                                style: Theme.of(context).textTheme.labelSmall!
                                    .copyWith(fontWeight: FontWeight.w800),
                              ),
                            ],
                          ),
                        ),
                    ],
                  ),
                ),
                const SizedBox(width: 10),
                _OverviewBars(categories: categories),
              ],
            ),
        ],
      ),
    );
  }

  List<_CategoryViewData> _buildCategories(BuildContext context) {
    if (categoryTotals.isEmpty) return const [];
    final typesById = {
      for (final type in expenseTypes)
        if (type.id != null) type.id!: type,
    };
    final entries = categoryTotals.entries.toList();
    final visibleEntries = entries.take(4).toList();
    final result = <_CategoryViewData>[];

    for (var index = 0; index < visibleEntries.length; index++) {
      final entry = visibleEntries[index];
      final type = typesById[entry.key];
      result.add(
        _CategoryViewData(
          label: type?.title ?? 'Unknown',
          amount: entry.value,
          color: _categoryColor(context, type, index),
        ),
      );
    }

    if (entries.length > 4) {
      final otherTotal = entries
          .skip(4)
          .fold<double>(0, (sum, entry) => sum + entry.value);
      result.add(
        _CategoryViewData(
          label: 'Others',
          amount: otherTotal,
          color: Theme.of(context).colorScheme.outline,
        ),
      );
    }
    return result;
  }

  Color _categoryColor(
    BuildContext context,
    ExpenseTypeModel? type,
    int index,
  ) {
    if (type != null &&
        type.iconColor >= 0 &&
        type.iconColor < AppConst.colorList.length) {
      return AppConst.colorList[type.iconColor];
    }
    final fallback = [
      const Color(0xFFFFA51F),
      const Color(0xFF60A5FA),
      const Color(0xFFF472B6),
      const Color(0xFFFB7185),
    ];
    return fallback[index % fallback.length];
  }
}

class _CategoryViewData {
  final String label;
  final double amount;
  final Color color;

  const _CategoryViewData({
    required this.label,
    required this.amount,
    required this.color,
  });
}

class _OverviewBars extends StatelessWidget {
  final List<_CategoryViewData> categories;

  const _OverviewBars({required this.categories});

  @override
  Widget build(BuildContext context) {
    final maxAmount = categories.fold<double>(
      0,
      (maximum, category) =>
          category.amount > maximum ? category.amount : maximum,
    );
    return SizedBox(
      width: 55,
      height: 72,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          for (final category in categories)
            Container(
              width: 7,
              height: 14 + (category.amount / maxAmount * 54),
              decoration: BoxDecoration(
                color: category.color,
                borderRadius: BorderRadius.circular(3),
              ),
            ),
        ],
      ),
    );
  }
}

class _RecentExpensesSection extends StatelessWidget {
  final List<ExpenseModel> expenses;
  final List<ExpenseTypeModel> expenseTypes;
  final bool loading;
  final VoidCallback onSeeAll;

  const _RecentExpensesSection({
    required this.expenses,
    required this.expenseTypes,
    required this.loading,
    required this.onSeeAll,
  });

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final typesById = {
      for (final type in expenseTypes)
        if (type.id != null) type.id!: type,
    };
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: colors.outline),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  'Recent Expenses',
                  style: Theme.of(context).textTheme.titleMedium!.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              TextButton(onPressed: onSeeAll, child: const Text('See All')),
            ],
          ),
          if (loading)
            const SizedBox(
              height: 110,
              child: Center(child: CircularProgressIndicator.adaptive()),
            )
          else if (expenses.isEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 28),
              child: Text(
                'No recent expenses.',
                style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                  color: colors.onSurfaceVariant,
                ),
              ),
            )
          else
            for (var index = 0; index < expenses.length; index++) ...[
              _RecentExpenseTile(
                expense: expenses[index],
                type: typesById[expenses[index].type],
              ),
              if (index != expenses.length - 1) const Divider(height: 1),
            ],
        ],
      ),
    );
  }
}

class _RecentExpenseTile extends StatelessWidget {
  final ExpenseModel expense;
  final ExpenseTypeModel? type;

  const _RecentExpenseTile({required this.expense, required this.type});

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final parsedDate = ExpenseDateFilterService.parseExpenseDate(expense.date);
    final iconColor =
        type != null &&
            type!.iconColor >= 0 &&
            type!.iconColor < AppConst.colorList.length
        ? AppConst.colorList[type!.iconColor]
        : colors.primary;
    final hasIcon =
        type != null &&
        type!.icon >= 0 &&
        type!.icon < AppConst.iconList.length;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Row(
        children: [
          Container(
            width: 42,
            height: 42,
            padding: const EdgeInsets.all(9),
            decoration: BoxDecoration(
              color: iconColor.withValues(alpha: 0.16),
              borderRadius: BorderRadius.circular(11),
            ),
            child: hasIcon
                ? Image.asset(
                    '${AppConst.expneseTypeUrl}${AppConst.iconList[type!.icon]}.png',
                    errorBuilder: (_, _, _) =>
                        Icon(Icons.receipt_long_outlined, color: iconColor),
                  )
                : Icon(Icons.receipt_long_outlined, color: iconColor),
          ),
          const SizedBox(width: 11),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  type?.title ?? expense.title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(
                    context,
                  ).textTheme.titleSmall!.copyWith(fontWeight: FontWeight.w700),
                ),
                const SizedBox(height: 3),
                Text(
                  expense.note.trim().isEmpty ? expense.title : expense.note,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.bodySmall!.copyWith(
                    color: colors.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 10),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                NumberFormatService.formatCurrency(context, expense.amount),
                style: Theme.of(
                  context,
                ).textTheme.labelLarge!.copyWith(fontWeight: FontWeight.w800),
              ),
              const SizedBox(height: 3),
              Text(
                parsedDate == null
                    ? expense.date
                    : DateFormat('MMM d').format(parsedDate),
                style: Theme.of(context).textTheme.labelSmall!.copyWith(
                  color: colors.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _HomeHeader extends StatelessWidget {
  const _HomeHeader();

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Hi, Mate', style: Theme.of(context).textTheme.titleLarge),
              const SizedBox(height: 5),
              Text(
                'Track your expenses',
                style: Theme.of(context).textTheme.labelLarge,
              ),
            ],
          ),
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(30),
            border: Border.all(color: colors.primary),
          ),
          child: Text(
            DateFormat('MMM dd, yy').format(DateTime.now()),
            style: Theme.of(
              context,
            ).textTheme.labelMedium!.copyWith(color: colors.primary),
          ),
        ),
      ],
    );
  }
}
