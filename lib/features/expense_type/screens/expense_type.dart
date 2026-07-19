import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/utils/app_color.dart';
import '../../../core/utils/app_const.dart';
import 'providers/expense_type_provider.dart';
import 'providers/expense_type_provider_state.dart';
import 'widgets/expense_type_widget.dart';

class ExpenseTypeScreen extends ConsumerStatefulWidget {
  const ExpenseTypeScreen({super.key});
  @override
  ConsumerState<ConsumerStatefulWidget> createState() =>
      _ExpenseTypeScreenState();
}

class _ExpenseTypeScreenState extends ConsumerState<ExpenseTypeScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      ref.read(expenseTypeProvider.notifier).getAllType();
    });
  }

  @override
  Widget build(BuildContext context) {
    final expenseTypeState = ref.watch(expenseTypeProvider);
    listenChanges();
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Expense Type",
          style: TextTheme.of(context).titleLarge,
        ),
      ),
      body: SafeArea(
        child: Stack(
          children: [
            RefreshIndicator(
              onRefresh: () {
                return ref.read(expenseTypeProvider.notifier).getAllType();
              },
              child: CustomScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                slivers: [
                  if (expenseTypeState is ExpenseTypeReadyState &&
                      expenseTypeState.expenseList.isNotEmpty)
                    SliverList(
                      delegate: SliverChildBuilderDelegate(
                        (context, index) {
                          final expenseType =
                              expenseTypeState.expenseList[index];
                          return ExpenseTypeWidget(expenseType: expenseType);
                        },
                        childCount: expenseTypeState.expenseList.length,
                      ),
                    )
                  else if (expenseTypeState is ExpenseTypeReadyState)
                    SliverFillRemaining(
                      hasScrollBody: false,
                      child: Center(
                        child: Text(
                          "There is no data",
                          style: TextTheme.of(context).labelLarge,
                        ),
                      ),
                    ),
                ],
              ),
            ),
            expenseTypeState is ExpenseTypeLoadingState && expenseTypeState.type == "getAllType"
                ? Center(
                    child: Container(
                      height: 120,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 24,
                        vertical: 24,
                      ),
                      decoration: BoxDecoration(
                        color: AppColor.placeholderColor,
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Column(
                        children: [
                          SizedBox(
                            width: 25,
                            height: 25,
                            child: CircularProgressIndicator.adaptive(),
                          ),
                          const SizedBox(height: 8),
                          Text("Fetching Types..."),
                        ],
                      ),
                    ),
                  )
                : const SizedBox(),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          ref.read(expneseIconColor.notifier).state = Colors.yellow;
          ref.read(expneseIconProvider.notifier).state = "accommodation";
          context.goNamed(AppConst.expenseTypeCreate);
        },
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
        child: Icon(Icons.add),
      ),
    );
  }
  void listenChanges(){
    ref.listen(expenseTypeProvider, (p, next) {
      if(next is ExpenseTypeReadyState){
        String message = next.message;
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(message)));
      }else if(next is ExpenseTypeErrorState){
        String message = next.errorMessage;
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(message)));
      }
    });
  }
}
