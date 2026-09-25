import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/services/app_number_formatter.dart';
import '../../budget/screens/providers/budget_provider.dart';
import '../data/models/lucky_draw_model.dart';
import '../domain/usecases/lucky_draw_generator.dart';
import 'providers/lucky_draw_provider.dart';
import 'providers/lucky_draw_provider_state.dart';

class LuckyDrawCreateScreen extends ConsumerStatefulWidget {
  const LuckyDrawCreateScreen({super.key});

  @override
  ConsumerState<LuckyDrawCreateScreen> createState() =>
      _LuckyDrawCreateScreenState();
}

class _LuckyDrawCreateScreenState extends ConsumerState<LuckyDrawCreateScreen> {
  final _formKey = GlobalKey<FormState>();
  final _daysController = TextEditingController(text: '1');
  final _drawBudgetController = TextEditingController();
  final _maxBudgetController = TextEditingController();
  final _minBudgetController = TextEditingController();
  final _daysFocusNode = FocusNode();
  final _drawBudgetFocusNode = FocusNode();
  final _maxBudgetFocusNode = FocusNode();
  final _minBudgetFocusNode = FocusNode();

  String _period = 'monthly';
  bool _checkingExistingDraw = true;
  bool _isSubmitting = false;
  double _availableBudget = 0;

  int get _days {
    return switch (_period) {
      'weekly' => 7,
      'monthly' => 30,
      'yearly' => 365,
      _ => int.tryParse(_daysController.text) ?? 0,
    };
  }

  double get _maxAllowed {
    final drawBudget = _enteredDrawBudget;
    if (_days <= 0 || drawBudget == null || drawBudget <= 0) return 0;
    return ((drawBudget * 100).round() ~/ _days) / 100;
  }

  double? get _enteredDrawBudget {
    return double.tryParse(_drawBudgetController.text.trim());
  }

  double? get _enteredMaxBudget {
    return double.tryParse(_maxBudgetController.text.trim());
  }

  double? get _enteredMinBudget {
    return double.tryParse(_minBudgetController.text.trim());
  }

  bool get _canEnterMinBudget {
    final maxBudget = _enteredMaxBudget;
    return maxBudget != null && maxBudget > 0 && maxBudget <= _maxAllowed;
  }

  double get _projectedPrizePool {
    final maxBudget = _enteredMaxBudget;
    final minBudget = _enteredMinBudget;
    if (maxBudget == null ||
        maxBudget <= 0 ||
        maxBudget > _maxAllowed ||
        minBudget == null ||
        minBudget <= 0 ||
        minBudget > maxBudget) {
      return 0;
    }
    final averageTicket = (minBudget + maxBudget) / 2;
    return double.parse((_days * averageTicket).toStringAsFixed(2));
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _checkExistingDraw());
  }

  Future<void> _checkExistingDraw() async {
    await ref.read(luckyDrawProvider.notifier).getCurrentDraw();
    if (!mounted) return;
    final state = ref.read(luckyDrawProvider);
    if (state is LuckyDrawReadyState && state.draw.undrawnTickets.isNotEmpty) {
      context.pushReplacement('/lucky-draw');
      return;
    }
    setState(() => _checkingExistingDraw = false);
  }

  @override
  Widget build(BuildContext context) {
    final currentBudget = ref.watch(currentBudgetProvider);
    final luckyDrawState = ref.watch(luckyDrawProvider);
    _listenForCreateResult();

    if (_checkingExistingDraw) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator.adaptive()),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Create Lucky Draw'),
        actions: const [
          Padding(
            padding: EdgeInsets.only(right: 20),
            child: Center(child: Text('🎟️', style: TextStyle(fontSize: 20))),
          ),
        ],
      ),
      body: currentBudget.when(
        loading: () =>
            const Center(child: CircularProgressIndicator.adaptive()),
        error: (error, stackTrace) => _BudgetError(
          onRetry: () {
            ref.invalidate(currentBudgetProvider);
          },
        ),
        data: (budget) {
          _availableBudget = budget;
          return _buildForm(
            context,
            isSaving: luckyDrawState is LuckyDrawLoadingState,
          );
        },
      ),
    );
  }

  Widget _buildForm(BuildContext context, {required bool isSaving}) {
    final colors = Theme.of(context).colorScheme;
    final drawBudget = _enteredDrawBudget;
    final projectedPrizePool = _projectedPrizePool;
    final projectedSavedMoney = ((drawBudget ?? 0) - projectedPrizePool).clamp(
      0,
      drawBudget ?? 0,
    );

    return Form(
      key: _formKey,
      child: ListView(
        padding: const EdgeInsets.fromLTRB(20, 18, 20, 28),
        children: [
          Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: colors.primary.withValues(alpha: 0.06),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: colors.primary.withValues(alpha: 0.35)),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Total Budget',
                        style: Theme.of(context).textTheme.labelSmall,
                      ),
                      const SizedBox(height: 6),
                      Text(
                        NumberFormatService.formatCurrency(
                          context,
                          _availableBudget,
                        ),
                        style: Theme.of(context).textTheme.headlineSmall!
                            .copyWith(
                              color: colors.primary,
                              fontWeight: FontWeight.w800,
                            ),
                      ),
                    ],
                  ),
                ),
                const Text('💰', style: TextStyle(fontSize: 30)),
              ],
            ),
          ),
          if (_availableBudget <= 0) ...[
            const SizedBox(height: 8),
            Text(
              'Set a budget in Budget Setting before creating a Lucky Draw.',
              style: Theme.of(
                context,
              ).textTheme.bodySmall!.copyWith(color: colors.error),
            ),
          ],
          const SizedBox(height: 20),
          Text.rich(
            TextSpan(
              text: 'Lucky Draw Budget ',
              style: Theme.of(context).textTheme.bodyMedium,
              children: [
                TextSpan(
                  text:
                      '(max ${NumberFormatService.formatCurrency(context, _availableBudget)})',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ],
            ),
          ),
          const SizedBox(height: 6),
          TextFormField(
            controller: _drawBudgetController,
            focusNode: _drawBudgetFocusNode,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            inputFormatters: [
              FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d{0,2}')),
            ],
            onChanged: (_) {
              setState(() {});
              _formKey.currentState?.validate();
            },
            onTapOutside: (_) => _drawBudgetFocusNode.unfocus(),
            validator: (value) {
              final amount = double.tryParse(value?.trim() ?? '');
              if (amount == null) return 'Lucky Draw budget is required';
              if (amount <= 0) {
                return 'Lucky Draw budget must be greater than zero';
              }
              if (amount > _availableBudget) {
                return 'Lucky Draw budget cannot exceed the total budget';
              }
              return null;
            },
            decoration: InputDecoration(
              prefixText: '${NumberFormatService.currencySymbol(context)}  ',
              hintText: '0 – ${_availableBudget.toStringAsFixed(2)}',
            ),
          ),
          const SizedBox(height: 20),
          Text('Period', style: Theme.of(context).textTheme.bodyMedium),
          const SizedBox(height: 10),
          Row(
            children: [
              for (final period in const [
                ('weekly', 'Weekly'),
                ('monthly', 'Monthly'),
                ('yearly', 'Yearly'),
                ('custom', 'Custom'),
              ]) ...[
                Expanded(
                  child: Padding(
                    padding: EdgeInsets.only(
                      right: period.$1 == 'custom' ? 0 : 6,
                    ),
                    child: _PeriodButton(
                      label: period.$2,
                      selected: _period == period.$1,
                      onTap: () => setState(() => _period = period.$1),
                    ),
                  ),
                ),
              ],
            ],
          ),
          if (_period == 'custom') ...[
            const SizedBox(height: 12),
            TextFormField(
              controller: _daysController,
              focusNode: _daysFocusNode,
              keyboardType: TextInputType.number,
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              onChanged: (_) => setState(() {}),
              onTapOutside: (_) => _daysFocusNode.unfocus(),
              validator: (value) {
                final days = int.tryParse(value ?? '');
                if (days == null || days <= 0) {
                  return 'Custom days must be greater than zero';
                }
                return null;
              },
              decoration: const InputDecoration(
                hintText: 'Number of days',
                suffixText: 'days',
              ),
            ),
          ],
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _MetricCard(label: '🎟 Tickets', value: '$_days'),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _MetricCard(
                  label: 'Max/day',
                  value: NumberFormatService.formatCurrency(
                    context,
                    _maxAllowed,
                  ),
                  valueColor: const Color(0xFFFBBF24),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text.rich(
            TextSpan(
              text: 'Max Budget per Day ',
              style: Theme.of(context).textTheme.bodyMedium,
              children: [
                TextSpan(
                  text:
                      '(max ${NumberFormatService.formatCurrency(context, _maxAllowed)})',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ],
            ),
          ),
          const SizedBox(height: 6),
          TextFormField(
            controller: _maxBudgetController,
            focusNode: _maxBudgetFocusNode,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            inputFormatters: [
              FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d{0,2}')),
            ],
            onChanged: (_) {
              setState(() {});
              _formKey.currentState?.validate();
            },
            onTapOutside: (_) => _maxBudgetFocusNode.unfocus(),
            validator: (value) {
              final amount = double.tryParse(value?.trim() ?? '');
              if (amount == null) return 'Max budget is required';
              if (amount <= 0) return 'Max budget must be greater than zero';
              if (amount > _maxAllowed) {
                return 'Max budget cannot exceed ${_maxAllowed.toStringAsFixed(2)}';
              }
              return null;
            },
            decoration: InputDecoration(
              prefixText: '${NumberFormatService.currencySymbol(context)}  ',
              hintText: '0 – ${_maxAllowed.toStringAsFixed(2)}',
            ),
          ),
          const SizedBox(height: 16),
          Text.rich(
            TextSpan(
              text: 'Minimum Budget per Day ',
              style: Theme.of(context).textTheme.bodyMedium,
              children: [
                TextSpan(
                  text: _canEnterMinBudget
                      ? '(max ${NumberFormatService.formatCurrency(context, _enteredMaxBudget!)})'
                      : '(enter a valid max budget first)',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ],
            ),
          ),
          const SizedBox(height: 6),
          TextFormField(
            controller: _minBudgetController,
            focusNode: _minBudgetFocusNode,
            enabled: _canEnterMinBudget,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            inputFormatters: [
              FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d{0,2}')),
            ],
            onChanged: (_) {
              setState(() {});
              _formKey.currentState?.validate();
            },
            onTapOutside: (_) => _minBudgetFocusNode.unfocus(),
            validator: (value) {
              final amount = double.tryParse(value?.trim() ?? '');
              if (amount == null) return 'Minimum budget is required';
              if (amount <= 0) {
                return 'Minimum budget must be greater than zero';
              }
              final maxBudget = _enteredMaxBudget;
              if (maxBudget == null || maxBudget <= 0) {
                return 'Enter a valid max budget first';
              }
              if (amount > maxBudget) {
                return 'Minimum budget cannot exceed ${maxBudget.toStringAsFixed(2)}';
              }
              return null;
            },
            decoration: InputDecoration(
              prefixText: '${NumberFormatService.currencySymbol(context)}  ',
              hintText: _canEnterMinBudget
                  ? '0 – ${_enteredMaxBudget!.toStringAsFixed(2)}'
                  : 'Enter max budget first',
            ),
          ),
          if (_enteredMaxBudget != null &&
              _enteredMinBudget != null &&
              drawBudget != null &&
              drawBudget > 0 &&
              drawBudget <= _availableBudget &&
              _enteredMaxBudget! > 0 &&
              _enteredMaxBudget! <= _maxAllowed &&
              _enteredMinBudget! > 0 &&
              _enteredMinBudget! <= _enteredMaxBudget!) ...[
            const SizedBox(height: 12),
            _SummaryCard(
              tickets: _days,
              prizePool: projectedPrizePool,
              savedMoney: projectedSavedMoney.toDouble(),
            ),
          ],
          const SizedBox(height: 14),
          ElevatedButton(
            onPressed: isSaving || _availableBudget <= 0 ? null : _createDraw,
            child: isSaving
                ? const SizedBox(
                    width: 24,
                    height: 24,
                    child: CircularProgressIndicator.adaptive(),
                  )
                : const Text('🎟️  Create Lucky Draw'),
          ),
        ],
      ),
    );
  }

  Future<void> _createDraw() async {
    _daysFocusNode.unfocus();
    _drawBudgetFocusNode.unfocus();
    _maxBudgetFocusNode.unfocus();
    _minBudgetFocusNode.unfocus();
    if (!(_formKey.currentState?.validate() ?? false)) return;

    final totalBudget = _enteredDrawBudget!;
    final maxBudget = _enteredMaxBudget!;
    final minBudget = _enteredMinBudget!;
    final amounts = LuckyDrawGenerator.generate(
      totalBudget: totalBudget,
      days: _days,
      minBudget: minBudget,
      maxBudget: maxBudget,
    );
    final tickets = [
      for (var index = 0; index < amounts.length; index++)
        LuckyDrawTicket(
          id: 0,
          drawId: 0,
          ticketNo: index + 1,
          amount: amounts[index],
        ),
    ];
    final draw = LuckyDrawModel(
      id: 0,
      totalBudget: totalBudget,
      period: _period,
      days: _days,
      minBudget: minBudget,
      maxBudget: maxBudget,
      savedMoney: LuckyDrawGenerator.savedMoney(totalBudget, amounts),
      tickets: tickets,
      createdAt: DateTime.now(),
    );

    _isSubmitting = true;
    await ref.read(luckyDrawProvider.notifier).createDraw(draw);
  }

  void _listenForCreateResult() {
    ref.listen(luckyDrawProvider, (previous, next) {
      if (!_isSubmitting) return;
      if (next is LuckyDrawReadyState) {
        _isSubmitting = false;
        context.pushReplacement('/lucky-draw');
      } else if (next is LuckyDrawErrorState) {
        _isSubmitting = false;
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(next.errorMessage)));
      }
    });
  }

  @override
  void dispose() {
    _daysController.dispose();
    _drawBudgetController.dispose();
    _maxBudgetController.dispose();
    _minBudgetController.dispose();
    _daysFocusNode.dispose();
    _drawBudgetFocusNode.dispose();
    _maxBudgetFocusNode.dispose();
    _minBudgetFocusNode.dispose();
    super.dispose();
  }
}

class _PeriodButton extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const _PeriodButton({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return Material(
      color: selected ? colors.primary : colors.surfaceContainerHighest,
      borderRadius: BorderRadius.circular(10),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: SizedBox(
          height: 44,
          child: Center(
            child: Text(
              label,
              style: Theme.of(context).textTheme.labelMedium!.copyWith(
                color: selected ? colors.onPrimary : colors.onSecondary,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _MetricCard extends StatelessWidget {
  final String label;
  final String value;
  final Color? valueColor;

  const _MetricCard({
    required this.label,
    required this.value,
    this.valueColor,
  });

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return Container(
      height: 74,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: colors.secondary,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: colors.outline),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(label, style: Theme.of(context).textTheme.labelSmall),
          const SizedBox(height: 5),
          Text(
            value,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: Theme.of(context).textTheme.titleMedium!.copyWith(
              color: valueColor,
              fontWeight: FontWeight.w800,
            ),
          ),
        ],
      ),
    );
  }
}

class _SummaryCard extends StatelessWidget {
  final int tickets;
  final double prizePool;
  final double savedMoney;

  const _SummaryCard({
    required this.tickets,
    required this.prizePool,
    required this.savedMoney,
  });

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colors.secondary,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: colors.outline),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Summary', style: Theme.of(context).textTheme.labelLarge),
          const SizedBox(height: 12),
          _SummaryRow(label: '🎟 Total Tickets', value: '$tickets tickets'),
          _SummaryRow(
            label: '💸 Estimated Prize Pool',
            value: NumberFormatService.formatCurrency(context, prizePool),
          ),
          _SummaryRow(
            label: '🏦 Estimated Saved Money',
            value: NumberFormatService.formatCurrency(context, savedMoney),
            valueColor: colors.primary,
            showDivider: false,
          ),
        ],
      ),
    );
  }
}

class _SummaryRow extends StatelessWidget {
  final String label;
  final String value;
  final Color? valueColor;
  final bool showDivider;

  const _SummaryRow({
    required this.label,
    required this.value,
    this.valueColor,
    this.showDivider = true,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: Text(label, style: Theme.of(context).textTheme.bodySmall),
            ),
            Text(
              value,
              style: Theme.of(context).textTheme.labelMedium!.copyWith(
                color: valueColor ?? Theme.of(context).colorScheme.onSurface,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
        if (showDivider) ...[
          const SizedBox(height: 8),
          const Divider(),
          const SizedBox(height: 8),
        ],
      ],
    );
  }
}

class _BudgetError extends StatelessWidget {
  final VoidCallback onRetry;

  const _BudgetError({required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('Unable to load your current budget.'),
            const SizedBox(height: 12),
            OutlinedButton(onPressed: onRetry, child: const Text('Try Again')),
          ],
        ),
      ),
    );
  }
}
