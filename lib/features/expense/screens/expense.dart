import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lottie/lottie.dart';

import '../../../core/services/app_number_formatter.dart';
import '../../../core/utils/app_color.dart';
import '../../../core/utils/app_const.dart';
import 'providers/expense_provider.dart';
import 'widgets/expense_widget.dart';

class ExpenseScreen extends ConsumerStatefulWidget {
  const ExpenseScreen({super.key});
  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _ExpenseScreenState();
}

class _ExpenseScreenState extends ConsumerState<ExpenseScreen> {
  @override
  Widget build(BuildContext context) {
    final expenseListState = ref.watch(expenseListProvider);
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: Text("Expenses", style: TextTheme.of(context).titleLarge),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
          child: expenseListState.when(
            loading: () => Column(
              children: [
                SizedBox(
                  height: 25,
                  width: 25,
                  child: CircularProgressIndicator.adaptive(
                    backgroundColor: AppColor.primaryColor,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  "Fetching Expense...",
                  style: TextTheme.of(
                    context,
                  ).bodyMedium!.copyWith(color: AppColor.primaryTextColor),
                ),
              ],
            ),
            data: (expenseList) {
              final totalExpense = expenseList.fold<double>(
                0,
                (sum, expense) => sum + expense.amount,
              );
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Total Expense",
                    style: TextTheme.of(context).bodyMedium,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    NumberFormatService.formatCurrency(totalExpense),
                    style: TextTheme.of(context).titleLarge!.copyWith(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  expenseList.isEmpty
                      ? Expanded(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            mainAxisSize: MainAxisSize.max,
                            children: [
                              LottieBuilder.asset(
                                "assets/animation/no data.json",
                              ),
                              const SizedBox(height: 8),
                              Text.rich(
                                TextSpan(
                                  text: "There is no ",
                                  style: TextTheme.of(
                                    context,
                                  ).labelLarge!.copyWith(fontSize: 16),
                                  children: [
                                    TextSpan(
                                      text: "Expense",
                                      style: TextTheme.of(context).labelLarge!
                                          .copyWith(
                                            fontSize: 16,
                                            color: AppColor.buttonColor,
                                          ),
                                    ),
                                  ],
                                ),
                              ),
                              Text(
                                "Add your Expense to track",
                                style: TextTheme.of(
                                  context,
                                ).labelLarge!.copyWith(fontSize: 16),
                              ),
                            ],
                          ),
                        )
                      : Expanded(
                          child: ListView.builder(
                            itemCount: expenseList.length,
                            itemBuilder: (context, index) {
                              return ExpenseWidget(expense: expenseList[index]);
                            },
                          ),
                        ),
                ],
              );
            },
            error: (error, _) => Text(
              error.toString(),
              style: TextTheme.of(
                context,
              ).bodyMedium!.copyWith(color: AppColor.secondaryTextColor),
            ),
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          context.goNamed(AppConst.addExpenseScreen);
        },
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
        child: Icon(Icons.add),
      ),
    );
  }
}
