import 'package:expense_tracker/features/home/screens/providers/home_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../core/services/app_number_formatter.dart';
import '../../../core/utils/app_color.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});
  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  List<String> dropDownList = ["This Month", "Last Month", "All"];

  @override
  Widget build(BuildContext context) {
    final dropDownValue = ref.watch(dropdownProvider);
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          automaticallyImplyLeading: false,
          titleSpacing: 24,
          actionsPadding: const EdgeInsets.only(right: 24),
          centerTitle: false,
          title: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text("Hi, Mate", style: TextTheme.of(context).titleLarge),
              const SizedBox(height: 8),
              Text(
                "Track your expneses",
                style: TextTheme.of(context).labelLarge,
              ),
            ],
          ),
          actions: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(30),
                border: Border.all(color: AppColor.buttonColor),
              ),
              child: Text(
                DateFormat("MMM-dd-yy").format(DateTime.now()),
                style: TextTheme.of(
                  context,
                ).labelLarge!.copyWith(color: AppColor.buttonColor),
              ),
            ),
          ],
        ),
        body: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.max,
              children: [
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 16,
                  ),
                  decoration: BoxDecoration(
                    color: AppColor.cardBackgroundColor,
                    borderRadius: BorderRadius.circular(24),
                    border: Border.all(color: AppColor.borderColor),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            "Total Expense",
                            style: TextTheme.of(context).labelLarge,
                          ),
                          DropdownButton<String>(
                            value: dropDownValue,
                            items: [
                              ...List.generate(dropDownList.length, (index) {
                                return DropdownMenuItem(
                                  value: dropDownList[index],
                                  child: Text(dropDownList[index]),
                                );
                              }),
                            ],
                            onChanged: (value) {
                              ref.read(dropdownProvider.notifier).state = value!;
                            },
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(
                        NumberFormatService.formatCurrency(180.5),
                        style: TextTheme.of(context).displaySmall,
                      ),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          ExpenseCardWidget(
                            title: "Total Expense",
                            icon: "assets/icon/total_expense.png",
                            amount: 30,
                          ),
                          const SizedBox(width: 8),
                          ExpenseCardWidget(
                            title: "This Month",
                            icon: "assets/icon/monthly.png",
                            amount: 150,
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          ExpenseCardWidget(
                            title: "Total Budget",
                            icon: "assets/icon/income.png",
                            amount: 1000,
                          ),
                          const SizedBox(width: 8),
                          ExpenseCardWidget(
                            title: "Your Budget",
                            icon: "assets/icon/income.png",
                            amount: 800,
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(16),
                    color: AppColor.cardBackgroundColor,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class ExpenseCardWidget extends StatelessWidget {
  final String title;
  final String icon;
  final double amount;
  const ExpenseCardWidget({
    super.key,
    required this.title,
    required this.icon,
    required this.amount,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        decoration: BoxDecoration(
          color: AppColor.inputBackgroundColor,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColor.borderColor),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(title, style: TextTheme.of(context).labelMedium),
                Image.asset(icon, width: 15),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              NumberFormatService.formatCurrency(amount),
              style: TextTheme.of(context).titleLarge,
            ),
          ],
        ),
      ),
    );
  }
}
