import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/utils/app_const.dart';
import '../../data/models/expense_type_model.dart';
import '../providers/expense_type_provider.dart';
import '../providers/expense_type_provider_state.dart';

class ExpenseTypeWidget extends ConsumerWidget {
  final ExpenseTypeModel expenseType;
  final int expenseCount;
  final VoidCallback? onTap;
  const ExpenseTypeWidget({
    super.key,
    required this.expenseType,
    required this.expenseCount,
    this.onTap,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.only(left: 24, right: 24, bottom: 8),
      child: Material(
        color: colors.surface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: BorderSide(color: colors.outline),
        ),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onTap,
          child: Padding(
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
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        expenseType.title,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextTheme.of(context).bodyLarge,
                      ),
                      Text(
                        "$expenseCount Expenses",
                        style: TextTheme.of(context).labelLarge,
                      ),
                    ],
                  ),
                ),
                Hero(
                  tag: "expense-type-add-fab${expenseType.id}",
                  child: IconButton(
                    onPressed: () {
                      ref.read(expneseIconColor.notifier).state =
                          AppConst.colorList[expenseType.iconColor];
                      ref.read(expneseIconProvider.notifier).state =
                          AppConst.iconList[expenseType.icon];
                      context.goNamed(
                        AppConst.expenseTypeCreate,
                        extra: expenseType,
                      );
                    },
                    icon: Icon(Icons.edit),
                    color: colors.tertiary,
                  ),
                ),
                IconButton(
                  tooltip: 'Delete expense type',
                  onPressed: expenseType.id == null
                      ? null
                      : () => _requestDelete(context, ref),
                  icon: Icon(Icons.delete),
                  color: colors.error,
                ),
                // Icon(Icons.chevron_right, color: colors.onSurfaceVariant),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _requestDelete(BuildContext context, WidgetRef ref) async {
    if (expenseCount > 0) {
      await showDialog<void>(
        context: context,
        builder: (dialogContext) => AlertDialog(
          title: const Text('Cannot delete expense type'),
          content: Text(
            '“${expenseType.title}” is used by $expenseCount '
            'expense${expenseCount == 1 ? '' : 's'}. '
            'Change or delete those expenses first.',
          ),
          actions: [
            FilledButton(
              onPressed: () => dialogContext.pop(),
              child: const Text('OK'),
            ),
          ],
        ),
      );
      return;
    }

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Delete expense type?'),
        content: Text(
          'Are you sure you want to delete “${expenseType.title}”?',
        ),
        actions: [
          TextButton(
            onPressed: () => dialogContext.pop(false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => dialogContext.pop(true),
            style: FilledButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.error,
              foregroundColor: Theme.of(context).colorScheme.onError,
            ),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
    if (confirmed != true || !context.mounted) return;

    await ref.read(expenseTypeProvider.notifier).deleteType(expenseType.id!);
    if (!context.mounted) return;

    final state = ref.read(expenseTypeProvider);
    final message = switch (state) {
      ExpenseTypeReadyState() => state.message,
      ExpenseTypeErrorState() => state.errorMessage,
      _ => '',
    };
    if (message.isNotEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(message)));
    }
  }
}
