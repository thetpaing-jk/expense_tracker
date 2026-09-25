import 'package:expense_tracker/features/expense_type/data/models/expense_type_model.dart';
import 'package:expense_tracker/features/expense_type/screens/widgets/expense_type_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

final _type = ExpenseTypeModel(
  id: 1,
  title: 'Food',
  subtitle: '',
  iconColor: 0,
  icon: 0,
);

Widget _appWithType({required int expenseCount}) {
  return ProviderScope(
    child: MaterialApp(
      home: Scaffold(
        body: ExpenseTypeWidget(expenseType: _type, expenseCount: expenseCount),
      ),
    ),
  );
}

void main() {
  testWidgets('used expense type cannot be deleted', (tester) async {
    await tester.pumpWidget(_appWithType(expenseCount: 2));

    await tester.tap(find.byTooltip('Delete expense type'));
    await tester.pumpAndSettle();

    expect(find.text('Cannot delete expense type'), findsOneWidget);
    expect(find.textContaining('used by 2 expenses'), findsOneWidget);
    expect(find.text('Delete'), findsNothing);
  });

  testWidgets('unused expense type asks for confirmation', (tester) async {
    await tester.pumpWidget(_appWithType(expenseCount: 0));

    await tester.tap(find.byTooltip('Delete expense type'));
    await tester.pumpAndSettle();

    expect(find.text('Delete expense type?'), findsOneWidget);
    expect(find.text('Cancel'), findsOneWidget);
    expect(find.text('Delete'), findsOneWidget);
  });
}
