import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/services/app_number_formatter.dart';
import '../../../core/utils/app_color.dart';
import '../data/models/budget_model.dart';
import 'providers/budget_provider.dart';
import 'providers/budget_provider_state.dart';
import 'widgets/budget_period_widget.dart';
import 'widgets/budget_widget.dart';

class BudgetScreen extends ConsumerStatefulWidget {
  const BudgetScreen({super.key});

  @override
  ConsumerState<BudgetScreen> createState() => _BudgetScreenState();
}

class _BudgetScreenState extends ConsumerState<BudgetScreen> {
  final List<String> periodList = const ['Weekly', 'Monthly', 'Yearly'];
  final List<int> budgetList = const [500, 1000, 2000, 3000, 5000, 10000];
  final TextEditingController budgetC = TextEditingController(text: "500");
  final FocusNode budgetF = FocusNode();
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    final selectedBudget = ref.watch(budgetAmountSelectionProvider);
    final currentBudget = ref.watch(currentBudgetProvider);
    final budgetState = ref.watch(budgetProvider);
    _listenForSaveResult();

    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: true,
        title: const Text('Budget Setting'),
      ),
      body: Form(
        key: formKey,
        child: ListView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: AppColor.inputBackgroundColor,
                borderRadius: BorderRadius.circular(24),
                border: Border.all(width: 2, color: AppColor.borderColor),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Current Budget',
                    style: TextTheme.of(context).labelLarge,
                  ),
                  const SizedBox(height: 16),
                  currentBudget.when(
                    loading: () => const SizedBox(
                      width: 28,
                      height: 28,
                      child: CircularProgressIndicator.adaptive(),
                    ),
                    error: (error, stackTrace) => Text(
                      'Unable to load budget',
                      style: TextTheme.of(context).bodyMedium!.copyWith(
                        color: Theme.of(context).colorScheme.error,
                      ),
                    ),
                    data: (amount) => Text(
                      NumberFormatService.formatCurrency(amount),
                      style: TextTheme.of(
                        context,
                      ).headlineLarge!.copyWith(color: AppColor.buttonColor),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Total saved budget',
                    style: TextTheme.of(
                      context,
                    ).labelLarge!.copyWith(color: AppColor.placeholderColor),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'Budget Period',
              style: TextTheme.of(context).bodyMedium!.copyWith(
                color: Theme.of(context).colorScheme.onSecondary,
                fontWeight: FontWeight.w500,
              ),
            ),
            SizedBox(
              height: 80,
              child: ListView.builder(
                padding: const EdgeInsets.symmetric(vertical: 16),
                scrollDirection: Axis.horizontal,
                itemCount: periodList.length,
                itemBuilder: (context, index) {
                  return BudgetPeriodWidget(
                    name: periodList[index],
                    index: index,
                  );
                },
              ),
            ),
            Text(
              'Budget Amount',
              style: TextTheme.of(context).bodyMedium!.copyWith(
                color: Theme.of(context).colorScheme.onSecondary,
                fontWeight: FontWeight.w500,
              ),
            ),
            TextFormField(
              controller: budgetC,
              focusNode: budgetF,
              enabled: budgetState is! BudgetLoadingState,
              onChanged: (_) {
                ref.read(budgetAmountSelectionProvider.notifier).state = null;
              },
              onTapOutside: (_) => budgetF.unfocus(),
              keyboardType: const TextInputType.numberWithOptions(
                decimal: true,
              ),
              inputFormatters: [
                FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d{0,2}')),
              ],
              validator: (value) {
                final amount = double.tryParse(value?.trim() ?? '');
                if (value == null || value.trim().isEmpty) {
                  return 'Budget amount is required';
                }
                if (amount == null) {
                  return 'Budget amount must be a number';
                }
                if (amount <= 0) {
                  return 'Budget amount must be greater than zero';
                }
                return null;
              },
              style: TextTheme.of(context).headlineSmall,
              decoration: const InputDecoration(
                prefixText: '฿ ',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'Quick Select',
              style: TextTheme.of(context).bodyMedium!.copyWith(
                color: Theme.of(context).colorScheme.onSecondary,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 8),
            GridView.builder(
              padding: EdgeInsets.zero,
              primary: false,
              physics: const NeverScrollableScrollPhysics(),
              shrinkWrap: true,
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3,
                mainAxisExtent: 40,
                crossAxisSpacing: 8,
                mainAxisSpacing: 8,
              ),
              itemCount: budgetList.length,
              itemBuilder: (context, index) {
                final budget = budgetList[index];
                return BudgetWidget(
                  budget: budget,
                  isSelected: selectedBudget == index,
                  onTap: () {
                    budgetC.text = budget.toString();
                    ref.read(budgetAmountSelectionProvider.notifier).state =
                        index;
                  },
                );
              },
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: budgetState is BudgetLoadingState ? null : _saveBudget,
              child: budgetState is BudgetLoadingState
                  ? const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text('Saving Budget'),
                        SizedBox(width: 16),
                        SizedBox(
                          width: 22,
                          height: 22,
                          child: CircularProgressIndicator.adaptive(),
                        ),
                      ],
                    )
                  : const Text('Save Budget'),
            ),
          ],
        ),
      ),
    );
  }

  void _saveBudget() {
    budgetF.unfocus();
    if (!(formKey.currentState?.validate() ?? false)) return;

    final budget = BudgetModel(amount: double.parse(budgetC.text.trim()));
    ref.read(budgetProvider.notifier).addBudget(budget);
  }

  void _listenForSaveResult() {
    ref.listen(budgetProvider, (previous, next) {
      if (next is BudgetSuccessState) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(next.message)));
        budgetC.clear();
        ref.read(budgetAmountSelectionProvider.notifier).state = null;
        ref.read(budgetProvider.notifier).resetForm();
      } else if (next is BudgetErrorState) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(next.errorMessage)));
      }
    });
  }

  @override
  void dispose() {
    budgetC.dispose();
    budgetF.dispose();
    super.dispose();
  }
}
