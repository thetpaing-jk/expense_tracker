import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/utils/app_color.dart';
import '../../../../core/utils/app_const.dart';
import '../../data/models/expense_type_model.dart';
import '../providers/expense_type_provider.dart';

class ExpenseTypeWidget extends ConsumerWidget {
  final ExpenseTypeModel expenseType;
  const ExpenseTypeWidget({super.key, required this.expenseType});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Container(
      margin: EdgeInsets.only(left: 24, right: 24, bottom: 8),
      decoration: BoxDecoration(
        color: AppColor.cardBackgroundColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColor.borderColor),
      ),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: AppConst.colorList[expenseType.iconColor].withValues(
                      alpha: .3,
                    ),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: AppConst.colorList[expenseType.iconColor],
                    ),
                  ),
                  child: Image.asset(
                    "${AppConst.expneseTypeUrl}${AppConst.iconList[expenseType.icon]}.png",
                    width: 25,
                  ),
                ),
                const SizedBox(width: 16),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      expenseType.title,
                      style: TextTheme.of(context).bodyLarge,
                    ),
                    Text(
                      "${expenseType.subtitle} Expenses",
                      style: TextTheme.of(context).labelLarge,
                    ),
                  ],
                ),
                Spacer(),
                IconButton(
                  onPressed: () {
                    ref.read(expneseIconColor.notifier).state = AppConst.colorList[expenseType.iconColor];
                    ref.read(expneseIconProvider.notifier).state = AppConst.iconList[expenseType.icon];
                    context.goNamed(AppConst.expenseTypeCreate, extra: expenseType);
                  },
                  icon: Icon(Icons.edit),
                  color: AppColor.warrningColor,
                ),
                IconButton(
                  onPressed: () {
                    ref.read(expenseTypeProvider.notifier).deleteType(expenseType.id!);
                  },
                  icon: Icon(Icons.delete),
                  color: AppColor.dangerColor,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}