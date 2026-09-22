import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/services/app_number_formatter.dart';
import '../data/models/budget_model.dart';
import 'providers/budget_provider.dart';
import 'providers/budget_provider_state.dart';
import 'widgets/budget_widget.dart';

class BudgetAddScreen extends ConsumerStatefulWidget {
  const BudgetAddScreen({super.key});

  @override
  ConsumerState<BudgetAddScreen> createState() => _BudgetAddScreenState();
}

class _BudgetAddScreenState extends ConsumerState<BudgetAddScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _amountController = TextEditingController(text: '500');
  final _nameFocusNode = FocusNode();
  final _amountFocusNode = FocusNode();

  final List<int> _quickAmounts = const [500, 1000, 2000, 3000, 5000, 10000];
  bool _isSubmitting = false;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final selectedAmount = ref.watch(budgetAmountSelectionProvider);
    final budgetState = ref.watch(budgetProvider);
    _listenForSaveResult();

    return Scaffold(
      appBar: AppBar(title: const Text('Add Budget')),
      body: SafeArea(
        child: Form(
          key: _formKey,
          child: ListView(
            padding: const EdgeInsets.fromLTRB(24, 16, 24, 32),
            children: [
              Text(
                'Name',
                style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                  color: colors.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: 6),
              TextFormField(
                controller: _nameController,
                focusNode: _nameFocusNode,
                enabled: budgetState is! BudgetLoadingState,
                textInputAction: TextInputAction.next,
                maxLength: 50,
                onFieldSubmitted: (_) => _amountFocusNode.requestFocus(),
                onTapOutside: (_) => _nameFocusNode.unfocus(),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Budget name is required';
                  }
                  return null;
                },
                decoration: const InputDecoration(
                  hintText: 'e.g. Monthly salary',
                  prefixIcon: Icon(Icons.label_outline),
                  counterText: '',
                ),
              ),
              const SizedBox(height: 18),
              Text(
                'Budget Amount',
                style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                  color: colors.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: 6),
              TextFormField(
                controller: _amountController,
                focusNode: _amountFocusNode,
                enabled: budgetState is! BudgetLoadingState,
                keyboardType: const TextInputType.numberWithOptions(
                  decimal: true,
                ),
                inputFormatters: [
                  FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d{0,2}')),
                ],
                onChanged: (_) {
                  ref.read(budgetAmountSelectionProvider.notifier).state = null;
                },
                onTapOutside: (_) => _amountFocusNode.unfocus(),
                validator: (value) {
                  final amount = double.tryParse(value?.trim() ?? '');
                  if (value == null || value.trim().isEmpty) {
                    return 'Budget amount is required';
                  }
                  if (amount == null) return 'Budget amount must be a number';
                  if (amount <= 0) {
                    return 'Budget amount must be greater than zero';
                  }
                  return null;
                },
                style: Theme.of(context).textTheme.headlineSmall,
                decoration: InputDecoration(
                  prefixText: '${NumberFormatService.currencySymbol(context)} ',
                  hintText: 'Enter budget amount',
                ),
              ),
              const SizedBox(height: 22),
              Text(
                'Quick Select',
                style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                  color: colors.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: 8),
              GridView.builder(
                padding: EdgeInsets.zero,
                physics: const NeverScrollableScrollPhysics(),
                shrinkWrap: true,
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 3,
                  mainAxisExtent: 40,
                  crossAxisSpacing: 8,
                  mainAxisSpacing: 8,
                ),
                itemCount: _quickAmounts.length,
                itemBuilder: (context, index) {
                  return BudgetWidget(
                    budget: _quickAmounts[index],
                    isSelected: selectedAmount == index,
                    onTap: () {
                      _amountController.text = _quickAmounts[index].toString();
                      ref.read(budgetAmountSelectionProvider.notifier).state =
                          index;
                    },
                  );
                },
              ),
              const SizedBox(height: 28),
              ElevatedButton(
                onPressed: budgetState is BudgetLoadingState
                    ? null
                    : _saveBudget,
                child: budgetState is BudgetLoadingState
                    ? const SizedBox(
                        width: 24,
                        height: 24,
                        child: CircularProgressIndicator.adaptive(),
                      )
                    : const Text('Save Budget'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _saveBudget() {
    _nameFocusNode.unfocus();
    _amountFocusNode.unfocus();
    if (!(_formKey.currentState?.validate() ?? false)) return;

    _isSubmitting = true;
    ref
        .read(budgetProvider.notifier)
        .addBudget(
          BudgetModel(
            name: _nameController.text.trim(),
            amount: double.parse(_amountController.text.trim()),
          ),
        );
  }

  void _listenForSaveResult() {
    ref.listen(budgetProvider, (previous, next) {
      if (!_isSubmitting) return;
      if (next is BudgetSuccessState) {
        _isSubmitting = false;
        ref.read(budgetAmountSelectionProvider.notifier).state = null;
        ref.read(budgetProvider.notifier).resetForm();
        context.pop(true);
      } else if (next is BudgetErrorState) {
        _isSubmitting = false;
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(next.errorMessage)));
      }
    });
  }

  @override
  void dispose() {
    _nameController.dispose();
    _amountController.dispose();
    _nameFocusNode.dispose();
    _amountFocusNode.dispose();
    super.dispose();
  }
}
