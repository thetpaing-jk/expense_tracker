import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers/budget_provider.dart';

class BudgetPeriodWidget extends ConsumerWidget {
  final int index;
  final String name;
  const BudgetPeriodWidget({
    super.key,
    required this.name,
    required this.index,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final periodValue = ref.watch(periodProvider);
    return Padding(
      padding: const EdgeInsets.only(right: 8.0),
      child: Material(
        clipBehavior: Clip.antiAlias,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: InkWell(
          onTap: () {
            ref.read(periodProvider.notifier).state = index;
          },
          child: Container(
            alignment: Alignment.center,
            width: MediaQuery.of(context).size.width / 3.8,
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 10),
            decoration: BoxDecoration(
              color: periodValue == index
                  ? Theme.of(context).colorScheme.primary
                  : Theme.of(context).colorScheme.surfaceContainerHighest,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              name,
              style: TextTheme.of(context).bodyMedium!.copyWith(
                color: periodValue == index
                    ? Theme.of(context).colorScheme.onPrimary
                    : Theme.of(context).colorScheme.onSecondary,
                fontWeight: periodValue == index ? FontWeight.w500 : null,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ),
      ),
    );
  }
}
