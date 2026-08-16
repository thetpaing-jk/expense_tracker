import 'package:expense_tracker/features/expense/screens/widgets/expense_widget.dart';
import 'package:expense_tracker/features/expense_type/data/models/expense_type_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/services/app_number_formatter.dart';
import '../../../core/utils/app_const.dart';

class ExpenseScreen extends ConsumerStatefulWidget {
  const ExpenseScreen({super.key});
  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _ExpenseScreenState();
}
class _ExpenseScreenState extends ConsumerState<ExpenseScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: Text("Expenses",
              style: TextTheme.of(context).titleLarge,
            ),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: 24,
            vertical: 8
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text("Total Expense",
                style: TextTheme.of(context).bodyMedium,
              ),
              const SizedBox(height: 8,),
              Text(NumberFormatService.formatCurrency(1000), style: TextTheme.of(context).titleLarge!.copyWith(
                fontSize: 20,
                fontWeight: FontWeight.bold                
              ),),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(onPressed: (){
        context.goNamed(AppConst.addExpenseScreen);
      },
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(30)
      ),
      child: Icon(Icons.add),
      ),
    );
  }
}