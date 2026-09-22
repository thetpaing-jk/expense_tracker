import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:lottie/lottie.dart';

import '../../../core/services/app_number_formatter.dart';
import '../../../core/utils/app_const.dart';
import '../../lucky_draw/data/models/lucky_draw_model.dart';
import '../../lucky_draw/screens/providers/lucky_draw_provider.dart';
import '../../lucky_draw/screens/providers/lucky_draw_provider_state.dart';
import '../data/models/expense_model.dart';
import '../domain/usecases/expense_date_filter.dart';
import 'providers/expense_provider.dart';
import 'widgets/expense_widget.dart';

class ExpenseScreen extends ConsumerStatefulWidget {
  const ExpenseScreen({super.key});

  @override
  ConsumerState<ExpenseScreen> createState() => _ExpenseScreenState();
}

class _ExpenseScreenState extends ConsumerState<ExpenseScreen> {
  ExpenseDateFilter _selectedFilter = ExpenseDateFilter.thisMonth;
  DateTime? _customStart;
  DateTime? _customEnd;

  @override
  void initState() {
    super.initState();
    Future.microtask(
      () => ref.read(luckyDrawProvider.notifier).getCurrentDraw(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final expenseListState = ref.watch(expenseListProvider);
    final luckyDrawState = ref.watch(luckyDrawProvider);
    final colors = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: Text('Expenses', style: TextTheme.of(context).titleLarge),
        actions: [
          _ExpenseFilterAction(
            selectedFilter: _selectedFilter,
            onFilterSelected: _changeFilter,
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
          child: expenseListState.when(
            loading: () =>
                const Center(child: CircularProgressIndicator.adaptive()),
            data: (expenses) => _buildExpenseContent(expenses, luckyDrawState),
            error: (error, _) => Center(
              child: Text(
                error.toString(),
                style: TextTheme.of(
                  context,
                ).bodyMedium!.copyWith(color: colors.onSurfaceVariant),
              ),
            ),
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        heroTag: 'expense-add-fab',
        backgroundColor: colors.primary,
        foregroundColor: colors.onPrimary,
        onPressed: () {
          context.goNamed(AppConst.addExpenseScreen);
        },
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildExpenseContent(
    List<ExpenseModel> expenses,
    LuckyDrawState luckyDrawState,
  ) {
    List<ExpenseModel> filteredExpenses =
        ExpenseDateFilterService.filterAndSort(
          expenses,
          filter: _selectedFilter,
          customStart: _customStart,
          customEnd: _customEnd,
        );
    final groupedExpenses = ExpenseDateFilterService.groupByDay(
      filteredExpenses,
    );
    final totalExpense = filteredExpenses.fold<double>(
      0,
      (sum, expense) => sum + expense.amount,
    );
    final today = ExpenseDateFilterService.dateOnly(DateTime.now());
    final todayExpense = expenses.fold<double>(0, (total, expense) {
      final expenseDate = ExpenseDateFilterService.parseExpenseDate(
        expense.date,
      );
      return expenseDate != null && _isSameDay(expenseDate, today)
          ? total + expense.amount
          : total;
    });
    final currentDraw = luckyDrawState is LuckyDrawReadyState
        ? luckyDrawState.draw
        : null;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Total Expense', style: TextTheme.of(context).bodyMedium),
        const SizedBox(height: 6),
        Text(
          NumberFormatService.formatCurrency(context, totalExpense),
          style: TextTheme.of(
            context,
          ).titleLarge!.copyWith(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        if (_selectedFilter == ExpenseDateFilter.custom &&
            _customFilterLabel != null) ...[
          const SizedBox(height: 8),
          _CustomFilterLabel(
            label: _customFilterLabel!,
            onTap: () => _changeFilter(ExpenseDateFilter.custom),
          ),
        ],
        if (currentDraw != null) ...[
          const SizedBox(height: 14),
          _TodayLuckyDrawCard(
            draw: currentDraw,
            todayExpense: todayExpense,
            onTap: () => context.push('/lucky-draw'),
          ),
        ],
        const SizedBox(height: 8),
        if (filteredExpenses.isEmpty)
          Expanded(child: _EmptyExpenses(filterLabel: _filterLabel))
        else
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.only(bottom: 88),
              itemCount: groupedExpenses.length,
              itemBuilder: (context, index) {
                final entry = groupedExpenses.entries.elementAt(index);
                final dayTotal = entry.value.fold<double>(
                  0,
                  (sum, expense) => sum + expense.amount,
                );
                return Column(
                  children: [
                    _DayDivider(date: entry.key, total: dayTotal),
                    for (final expense in entry.value)
                      ExpenseWidget(expense: expense, showDate: false),
                  ],
                );
              },
            ),
          ),
      ],
    );
  }

  String get _filterLabel {
    return switch (_selectedFilter) {
      ExpenseDateFilter.thisWeek => 'This Week',
      ExpenseDateFilter.thisMonth => 'This Month',
      ExpenseDateFilter.custom => _customFilterLabel ?? 'Custom',
    };
  }

  String? get _customFilterLabel {
    final start = _customStart;
    final end = _customEnd;
    if (start == null || end == null) return null;
    if (_isSameDay(start, end)) {
      return DateFormat('MMM d, yyyy').format(start);
    }
    if (start.year == end.year) {
      return '${DateFormat('MMM d').format(start)} – ${DateFormat('MMM d, yyyy').format(end)}';
    }
    return '${DateFormat('MMM d, yyyy').format(start)} – ${DateFormat('MMM d, yyyy').format(end)}';
  }

  Future<void> _changeFilter(ExpenseDateFilter filter) async {
    if (filter != ExpenseDateFilter.custom) {
      setState(() => _selectedFilter = filter);
      return;
    }

    final today = ExpenseDateFilterService.dateOnly(DateTime.now());
    final selection = await showDialog<_CustomDateResult>(
      context: context,
      builder: (_) => _CustomDatePickerDialog(
        initialStart: _customStart,
        initialEnd: _customEnd,
        firstDate: DateTime(1900),
        lastDate: today,
      ),
    );
    if (!mounted || selection == null) return;
    setState(() {
      _customStart = selection.start;
      _customEnd = selection.end;
      _selectedFilter = ExpenseDateFilter.custom;
    });
  }
}

class _ExpenseFilterAction extends StatelessWidget {
  final ExpenseDateFilter selectedFilter;
  final ValueChanged<ExpenseDateFilter> onFilterSelected;

  const _ExpenseFilterAction({
    required this.selectedFilter,
    required this.onFilterSelected,
  });

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return PopupMenuButton<ExpenseDateFilter>(
      tooltip: 'Filter expenses',
      initialValue: selectedFilter,
      onSelected: onFilterSelected,
      itemBuilder: (context) => [
        CheckedPopupMenuItem(
          value: ExpenseDateFilter.thisWeek,
          checked: selectedFilter == ExpenseDateFilter.thisWeek,
          child: const Text('This Week'),
        ),
        CheckedPopupMenuItem(
          value: ExpenseDateFilter.thisMonth,
          checked: selectedFilter == ExpenseDateFilter.thisMonth,
          child: const Text('This Month'),
        ),
        CheckedPopupMenuItem(
          value: ExpenseDateFilter.custom,
          checked: selectedFilter == ExpenseDateFilter.custom,
          child: const Text('Custom'),
        ),
      ],
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.filter_alt_outlined, size: 19, color: colors.primary),
            const SizedBox(width: 5),
            Text(
              switch (selectedFilter) {
                ExpenseDateFilter.thisWeek => 'Week',
                ExpenseDateFilter.thisMonth => 'Month',
                ExpenseDateFilter.custom => 'Custom',
              },
              style: Theme.of(
                context,
              ).textTheme.labelLarge!.copyWith(color: colors.primary),
            ),
            Icon(Icons.arrow_drop_down, color: colors.primary),
          ],
        ),
      ),
    );
  }
}

class _CustomFilterLabel extends StatelessWidget {
  final String label;
  final VoidCallback onTap;

  const _CustomFilterLabel({required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return InkWell(
      borderRadius: BorderRadius.circular(8),
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 4),
        child: Row(
          children: [
            Icon(
              Icons.calendar_month_outlined,
              size: 16,
              color: colors.primary,
            ),
            const SizedBox(width: 6),
            Text(
              label,
              style: Theme.of(
                context,
              ).textTheme.labelMedium!.copyWith(color: colors.primary),
            ),
            const Spacer(),
            Icon(Icons.edit_outlined, size: 16, color: colors.primary),
          ],
        ),
      ),
    );
  }
}

class _TodayLuckyDrawCard extends StatelessWidget {
  final LuckyDrawModel draw;
  final double todayExpense;
  final VoidCallback onTap;

  const _TodayLuckyDrawCard({
    required this.draw,
    required this.todayExpense,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final ticket = draw.todayTicket;
    return ticket == null
        ? _buildReminder(context)
        : _buildSpendingStatus(context, ticket);
  }

  Widget _buildReminder(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final hasTicket = draw.undrawnTickets.isNotEmpty;
    return Material(
      color: colors.primaryContainer,
      borderRadius: BorderRadius.circular(14),
      child: InkWell(
        borderRadius: BorderRadius.circular(14),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Row(
            children: [
              CircleAvatar(
                backgroundColor: colors.primary,
                foregroundColor: colors.onPrimary,
                child: const Icon(Icons.casino_outlined),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      hasTicket
                          ? "Today's lucky draw is waiting"
                          : 'Lucky draw is complete',
                      style: Theme.of(context).textTheme.titleSmall,
                    ),
                    const SizedBox(height: 3),
                    Text(
                      hasTicket
                          ? 'Draw a ticket to get your budget for today.'
                          : 'Open Lucky Draw to review or create a new draw.',
                      style: Theme.of(context).textTheme.bodySmall!.copyWith(
                        color: colors.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Icon(Icons.arrow_forward_ios, size: 16, color: colors.primary),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSpendingStatus(BuildContext context, LuckyDrawTicket ticket) {
    final colors = Theme.of(context).colorScheme;
    final difference = ticket.amount - todayExpense;
    final isOverBudget = difference < 0;
    final statusColor = isOverBudget ? colors.error : colors.primary;
    final progress = ticket.amount <= 0
        ? 0.0
        : (todayExpense / ticket.amount).clamp(0.0, 1.0).toDouble();

    return Material(
      color: isOverBudget ? colors.errorContainer : colors.primaryContainer,
      borderRadius: BorderRadius.circular(14),
      child: InkWell(
        borderRadius: BorderRadius.circular(14),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(Icons.casino_outlined, size: 18, color: statusColor),
                  const SizedBox(width: 7),
                  Text(
                    "Today's Lucky Budget",
                    style: Theme.of(context).textTheme.titleSmall,
                  ),
                  const Spacer(),
                  Text(
                    NumberFormatService.formatCurrency(context, ticket.amount),
                    style: Theme.of(context).textTheme.titleSmall!.copyWith(
                      color: statusColor,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: LinearProgressIndicator(
                  value: progress,
                  minHeight: 7,
                  color: statusColor,
                  backgroundColor: colors.surface.withValues(alpha: 0.75),
                ),
              ),
              const SizedBox(height: 9),
              Row(
                children: [
                  Expanded(
                    child: _LuckyBudgetValue(
                      label: 'Spent today',
                      value: NumberFormatService.formatCurrency(
                        context,
                        todayExpense,
                      ),
                    ),
                  ),
                  Container(width: 1, height: 34, color: colors.outlineVariant),
                  Expanded(
                    child: _LuckyBudgetValue(
                      label: isOverBudget ? 'Over budget' : 'Remaining',
                      value: NumberFormatService.formatCurrency(
                        context,
                        difference.abs(),
                      ),
                      color: statusColor,
                      alignEnd: true,
                    ),
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

class _LuckyBudgetValue extends StatelessWidget {
  final String label;
  final String value;
  final Color? color;
  final bool alignEnd;

  const _LuckyBudgetValue({
    required this.label,
    required this.value,
    this.color,
    this.alignEnd = false,
  });

  @override
  Widget build(BuildContext context) {
    final alignment = alignEnd
        ? CrossAxisAlignment.end
        : CrossAxisAlignment.start;
    return Column(
      crossAxisAlignment: alignment,
      children: [
        Text(label, style: Theme.of(context).textTheme.bodySmall),
        const SizedBox(height: 2),
        Text(
          value,
          style: Theme.of(context).textTheme.labelLarge!.copyWith(
            color: color,
            fontWeight: FontWeight.w700,
          ),
        ),
      ],
    );
  }
}

class _CustomDateResult {
  final DateTime start;
  final DateTime end;

  const _CustomDateResult({required this.start, required this.end});
}

class _CustomDatePickerDialog extends StatefulWidget {
  final DateTime? initialStart;
  final DateTime? initialEnd;
  final DateTime firstDate;
  final DateTime lastDate;

  const _CustomDatePickerDialog({
    required this.initialStart,
    required this.initialEnd,
    required this.firstDate,
    required this.lastDate,
  });

  @override
  State<_CustomDatePickerDialog> createState() =>
      _CustomDatePickerDialogState();
}

class _CustomDatePickerDialogState extends State<_CustomDatePickerDialog> {
  DateTime? _start;
  DateTime? _end;
  late DateTime _displayedMonth;

  @override
  void initState() {
    super.initState();
    _start = widget.initialStart;
    _end = widget.initialEnd;
    final initialMonth = _start ?? widget.lastDate;
    _displayedMonth = DateTime(initialMonth.year, initialMonth.month);
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return AlertDialog(
      title: const Text('Select date'),
      contentPadding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
      content: SizedBox(
        width: 360,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Select one day, or select a second day for a date range.',
              style: Theme.of(
                context,
              ).textTheme.bodySmall!.copyWith(color: colors.onSurfaceVariant),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                IconButton(
                  onPressed: _canGoToPreviousMonth ? _showPreviousMonth : null,
                  icon: const Icon(Icons.chevron_left),
                ),
                Expanded(
                  child: Text(
                    DateFormat('MMMM yyyy').format(_displayedMonth),
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.titleSmall,
                  ),
                ),
                IconButton(
                  onPressed: _canGoToNextMonth ? _showNextMonth : null,
                  icon: const Icon(Icons.chevron_right),
                ),
              ],
            ),
            const _WeekdayHeader(),
            const SizedBox(height: 4),
            _buildMonthGrid(colors),
            const SizedBox(height: 12),
            Align(
              alignment: Alignment.centerLeft,
              child: Text(
                _selectionLabel,
                style: Theme.of(context).textTheme.labelMedium!.copyWith(
                  color: _start == null
                      ? colors.onSurfaceVariant
                      : colors.primary,
                ),
              ),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        FilledButton(
          onPressed: _start == null
              ? null
              : () {
                  Navigator.of(context).pop(
                    _CustomDateResult(start: _start!, end: _end ?? _start!),
                  );
                },
          child: const Text('Apply'),
        ),
      ],
    );
  }

  Widget _buildMonthGrid(ColorScheme colors) {
    final firstDay = DateTime(_displayedMonth.year, _displayedMonth.month);
    final daysInMonth = DateTime(
      _displayedMonth.year,
      _displayedMonth.month + 1,
      0,
    ).day;
    final leadingEmptyCells = firstDay.weekday % DateTime.daysPerWeek;
    final cellCount =
        ((leadingEmptyCells + daysInMonth + 6) ~/ 7) * DateTime.daysPerWeek;

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: DateTime.daysPerWeek,
        mainAxisExtent: 40,
      ),
      itemCount: cellCount,
      itemBuilder: (context, index) {
        final dayNumber = index - leadingEmptyCells + 1;
        if (dayNumber < 1 || dayNumber > daysInMonth) {
          return const SizedBox.shrink();
        }

        final date = DateTime(
          _displayedMonth.year,
          _displayedMonth.month,
          dayNumber,
        );
        final isEnabled =
            !date.isBefore(widget.firstDate) && !date.isAfter(widget.lastDate);
        final isStart = _start != null && _isSameDay(date, _start!);
        final isEnd = _end != null && _isSameDay(date, _end!);
        final isInRange =
            _start != null &&
            _end != null &&
            date.isAfter(_start!) &&
            date.isBefore(_end!);
        final isToday = _isSameDay(date, widget.lastDate);

        return Padding(
          padding: const EdgeInsets.all(2),
          child: Material(
            color: isStart || isEnd
                ? colors.primary
                : isInRange
                ? colors.secondaryContainer
                : Colors.transparent,
            shape: CircleBorder(
              side: isToday && !isStart && !isEnd
                  ? BorderSide(color: colors.primary)
                  : BorderSide.none,
            ),
            child: InkWell(
              customBorder: const CircleBorder(),
              onTap: isEnabled ? () => _selectDate(date) : null,
              child: Center(
                child: Text(
                  '$dayNumber',
                  style: Theme.of(context).textTheme.bodySmall!.copyWith(
                    color: !isEnabled
                        ? colors.onSurface.withValues(alpha: 0.35)
                        : isStart || isEnd
                        ? colors.onPrimary
                        : colors.onSurface,
                    fontWeight: isStart || isEnd
                        ? FontWeight.w700
                        : FontWeight.normal,
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  void _selectDate(DateTime date) {
    setState(() {
      if (_start == null || _end != null) {
        _start = date;
        _end = null;
      } else if (date.isBefore(_start!)) {
        _end = _start;
        _start = date;
      } else if (_isSameDay(date, _start!)) {
        _end = null;
      } else {
        _end = date;
      }
    });
  }

  bool get _canGoToPreviousMonth {
    final firstMonth = DateTime(widget.firstDate.year, widget.firstDate.month);
    return _displayedMonth.isAfter(firstMonth);
  }

  bool get _canGoToNextMonth {
    final lastMonth = DateTime(widget.lastDate.year, widget.lastDate.month);
    return _displayedMonth.isBefore(lastMonth);
  }

  void _showPreviousMonth() {
    setState(() {
      _displayedMonth = DateTime(
        _displayedMonth.year,
        _displayedMonth.month - 1,
      );
    });
  }

  void _showNextMonth() {
    setState(() {
      _displayedMonth = DateTime(
        _displayedMonth.year,
        _displayedMonth.month + 1,
      );
    });
  }

  String get _selectionLabel {
    if (_start == null) return 'No date selected';
    if (_end == null || _isSameDay(_start!, _end!)) {
      return DateFormat('MMM d, yyyy').format(_start!);
    }
    return '${DateFormat('MMM d, yyyy').format(_start!)} - '
        '${DateFormat('MMM d, yyyy').format(_end!)}';
  }
}

class _WeekdayHeader extends StatelessWidget {
  const _WeekdayHeader();

  @override
  Widget build(BuildContext context) {
    const weekdays = ['S', 'M', 'T', 'W', 'T', 'F', 'S'];
    return Row(
      children: [
        for (final day in weekdays)
          Expanded(
            child: Text(
              day,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.labelSmall,
            ),
          ),
      ],
    );
  }
}

class _DayDivider extends StatelessWidget {
  final DateTime date;
  final double total;

  const _DayDivider({required this.date, required this.total});

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.only(top: 8, bottom: 10),
      child: Row(
        children: [
          Text(
            _dateLabel(date),
            style: Theme.of(context).textTheme.labelLarge!.copyWith(
              color: colors.onSurface,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(width: 10),
          Expanded(child: Divider(color: colors.outline)),
          const SizedBox(width: 10),
          Text(
            NumberFormatService.formatCurrency(context, total),
            style: Theme.of(
              context,
            ).textTheme.labelMedium!.copyWith(color: colors.onSurfaceVariant),
          ),
        ],
      ),
    );
  }

  String _dateLabel(DateTime date) {
    final today = ExpenseDateFilterService.dateOnly(DateTime.now());
    if (_isSameDay(date, today)) return 'Today';
    if (_isSameDay(date, today.subtract(const Duration(days: 1)))) {
      return 'Yesterday';
    }
    return DateFormat('EEE, MMM d').format(date);
  }
}

class _EmptyExpenses extends StatelessWidget {
  final String filterLabel;

  const _EmptyExpenses({required this.filterLabel});

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        LottieBuilder.asset('assets/animation/no data.json'),
        const SizedBox(height: 8),
        Text.rich(
          TextSpan(
            text: 'There are no expenses for ',
            style: TextTheme.of(context).labelLarge!.copyWith(fontSize: 16),
            children: [
              TextSpan(
                text: filterLabel,
                style: TextTheme.of(
                  context,
                ).labelLarge!.copyWith(fontSize: 16, color: colors.primary),
              ),
            ],
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 4),
        Text(
          'Add an expense or choose another date.',
          style: TextTheme.of(context).labelLarge,
          textAlign: TextAlign.center,
        ),
      ],
    );
  }
}

bool _isSameDay(DateTime first, DateTime second) {
  return first.year == second.year &&
      first.month == second.month &&
      first.day == second.day;
}
