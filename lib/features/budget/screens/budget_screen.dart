import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/services/app_number_formatter.dart';
import '../../../core/utils/app_const.dart';
import '../data/models/budget_model.dart';
import 'providers/budget_provider.dart';

class BudgetScreen extends ConsumerWidget {
  const BudgetScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = Theme.of(context).colorScheme;
    final currentBudget = ref.watch(currentBudgetProvider);
    final budgets = ref.watch(budgetListProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Budgets')),
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: () async {
            ref.invalidate(currentBudgetProvider);
            ref.invalidate(budgetListProvider);
            await Future.wait([
              ref.read(currentBudgetProvider.future),
              ref.read(budgetListProvider.future),
            ]);
          },
          child: CustomScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            slivers: [
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(24, 20, 24, 14),
                sliver: SliverToBoxAdapter(
                  child: _CurrentBudgetCard(currentBudget: currentBudget),
                ),
              ),
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(24, 4, 24, 10),
                sliver: SliverToBoxAdapter(
                  child: Text(
                    'Budget History',
                    style: Theme.of(context).textTheme.titleMedium!.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ),
              budgets.when(
                loading: () => const SliverFillRemaining(
                  hasScrollBody: false,
                  child: Center(child: CircularProgressIndicator.adaptive()),
                ),
                error: (error, _) => SliverFillRemaining(
                  hasScrollBody: false,
                  child: _BudgetListError(
                    onRetry: () => ref.invalidate(budgetListProvider),
                  ),
                ),
                data: (items) => items.isEmpty
                    ? const SliverFillRemaining(
                        hasScrollBody: false,
                        child: _EmptyBudgetList(),
                      )
                    : SliverPadding(
                        padding: const EdgeInsets.fromLTRB(24, 0, 24, 96),
                        sliver: SliverList.separated(
                          itemCount: items.length,
                          separatorBuilder: (_, _) =>
                              const SizedBox(height: 10),
                          itemBuilder: (context, index) {
                            return _BudgetListTile(budget: items[index]);
                          },
                        ),
                      ),
              ),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        heroTag: 'budget-add-fab',
        backgroundColor: colors.primary,
        foregroundColor: colors.onPrimary,
        onPressed: () async {
          final saved = await context.pushNamed<bool>(AppConst.budgetAdd);
          if (saved == true && context.mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Budget saved successfully')),
            );
          }
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}

class _CurrentBudgetCard extends StatelessWidget {
  final AsyncValue<double> currentBudget;

  const _CurrentBudgetCard({required this.currentBudget});

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        color: colors.secondary,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: colors.primary.withValues(alpha: 0.25)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.account_balance_wallet_outlined,
                color: colors.primary,
              ),
              const SizedBox(width: 8),
              Text(
                'Current Budget',
                style: Theme.of(context).textTheme.labelLarge,
              ),
            ],
          ),
          const SizedBox(height: 12),
          currentBudget.when(
            loading: () => const SizedBox(
              width: 26,
              height: 26,
              child: CircularProgressIndicator.adaptive(),
            ),
            error: (_, _) => Text(
              'Unable to load budget',
              style: Theme.of(
                context,
              ).textTheme.bodyMedium!.copyWith(color: colors.error),
            ),
            data: (amount) => Text(
              NumberFormatService.formatCurrency(context, amount),
              style: Theme.of(context).textTheme.headlineLarge!.copyWith(
                color: colors.primary,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'Total budgets minus total expenses',
            style: Theme.of(
              context,
            ).textTheme.bodySmall!.copyWith(color: colors.onSurfaceVariant),
          ),
        ],
      ),
    );
  }
}

class _BudgetListTile extends StatelessWidget {
  final BudgetModel budget;

  const _BudgetListTile({required this.budget});

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 15),
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: colors.outline),
      ),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: colors.primaryContainer,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(Icons.savings_outlined, color: colors.primary),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              budget.name,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: Theme.of(
                context,
              ).textTheme.titleSmall!.copyWith(fontWeight: FontWeight.w700),
            ),
          ),
          const SizedBox(width: 12),
          Text(
            NumberFormatService.formatCurrency(context, budget.amount),
            style: Theme.of(context).textTheme.titleSmall!.copyWith(
              color: colors.primary,
              fontWeight: FontWeight.w800,
            ),
          ),
        ],
      ),
    );
  }
}

class _EmptyBudgetList extends StatelessWidget {
  const _EmptyBudgetList();

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.all(32),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.savings_outlined, size: 64, color: colors.outline),
          const SizedBox(height: 14),
          Text(
            'No budgets yet',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 6),
          Text(
            'Tap the + button to add your first budget.',
            textAlign: TextAlign.center,
            style: Theme.of(
              context,
            ).textTheme.bodyMedium!.copyWith(color: colors.onSurfaceVariant),
          ),
        ],
      ),
    );
  }
}

class _BudgetListError extends StatelessWidget {
  final VoidCallback onRetry;

  const _BudgetListError({required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text('Unable to load budgets.'),
          const SizedBox(height: 10),
          OutlinedButton(onPressed: onRetry, child: const Text('Try Again')),
        ],
      ),
    );
  }
}
