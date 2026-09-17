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
  DraggableScrollableController draggableScrollableController =
      DraggableScrollableController();
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    draggableScrollableController.addListener(() {
      debugPrint(
        "Draggable controller : ${draggableScrollableController.size}",
      );
      if (draggableScrollableController.size >= .85) {
        ref.read(draggableProvider.notifier).state = true;
      } else {
        ref.read(draggableProvider.notifier).state = false;
      }
    });
  }

  @override
  void dispose() {
    draggableScrollableController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final dropDownValue = ref.watch(dropdownProvider);
    final draggableValue = ref.watch(draggableProvider);
    return Scaffold(
      body: Stack(
        children: [
          Positioned(
            top: kToolbarHeight + MediaQuery.paddingOf(context).top,
            left: 0,
            right: 0,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.max,
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: Column(
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
                                    ref.read(dropdownProvider.notifier).state =
                                        value!;
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
              ],
            ),
          ),
          // DraggableScrollableSheet(
          //   controller: draggableScrollableController,
          //   snap: true,
          //   initialChildSize: .4,
          //   minChildSize: .4,
          //   builder: (context, controller) {
          //     return Container(
          //       decoration: BoxDecoration(
          //         color: AppColor.primaryTextColor,
          //         borderRadius: BorderRadius.only(
          //           topLeft: Radius.circular(25),
          //           topRight: Radius.circular(25),
          //         ),
          //       ),
          //       child: ListView.builder(
          //         controller: controller,
          //         // physics: NeverScrollableScrollPhysics(),
          //         itemCount: 20,
          //         itemBuilder: (context, index) {
          //           if (index == 0) {
          //             return Align(
          //               child: Container(
          //                 margin: const EdgeInsets.all(20),
          //                 width: 50,
          //                 height: 8,
          //                 decoration: BoxDecoration(
          //                   color: Colors.grey,
          //                   borderRadius: BorderRadius.circular(35),
          //                 ),
          //               ),
          //             );
          //           }
          //           return Container(
          //             margin: const EdgeInsets.only(
          //               bottom: 8,
          //               left: 16,
          //               right: 16,
          //             ),
          //             padding: const EdgeInsets.symmetric(
          //               horizontal: 24,
          //               vertical: 8,
          //             ),
          //             decoration: BoxDecoration(
          //               color: AppColor.buttonColor,
          //               borderRadius: BorderRadius.circular(9),
          //             ),
          //             child: Text("This is choose number $index",
          //               style: TextTheme.of(context).bodyMedium!.copyWith(
          //                 color: AppColor.onButton
          //               ),
          //             ),
          //           );
          //         },
          //       ),
          //     );
          //   },
          // ),
          AppBarWidget(),
        ],
      ),
    );
  }
}

class AppBarWidget extends ConsumerWidget {
  const AppBarWidget({
    super.key,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Positioned(
      top: 0,
      left: 0,
      right: 0,
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Row(
              children: [
                Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    AnimatedDefaultTextStyle(
                      style: TextTheme.of(context).titleLarge!.copyWith(),
                      duration: Duration(milliseconds: 500),
                      child: Text(
                        "Hi, Mate",
                        style: TextTheme.of(context).titleLarge,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      "Track your expneses",
                      style: TextTheme.of(context).labelLarge,
                    ),
                  ],
                ),
                Spacer(),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
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
