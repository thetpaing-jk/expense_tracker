import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/utils/app_color.dart';
import '../../data/models/expense_model.dart';

class ExpenseWidget extends ConsumerWidget {
  final ExpenseModel expenseType;
  const ExpenseWidget({super.key, required this.expenseType});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Container(
      margin: EdgeInsets.only(left: 24, right: 24, bottom: 8),
      decoration: BoxDecoration(
        color: AppColor.cardBackgroundColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColor.borderColor),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: 8,vertical: 8
            ),
            decoration: BoxDecoration(
              border: Border.all(
                color: AppColor.borderColor
              )
            ),
            child: Icon(Icons.book),
          )
        ]
      )
    );
  }
}