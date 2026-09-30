import 'package:drift/native.dart';
import 'package:expense_log/database/app_database.dart';
import 'package:expense_log/database/expense_database.dart';
import 'package:expense_log/main.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';

void main() {
  testWidgets('可以在首页新增本月支出', (tester) async {
    final expenses = ExpenseDatabase(AppDatabase(NativeDatabase.memory()));
    await expenses.readExpenses();
    addTearDown(expenses.close);

    await tester.pumpWidget(
      ChangeNotifierProvider.value(value: expenses, child: const MyApp()),
    );
    await tester.pumpAndSettle();

    expect(find.text('Coffee'), findsNothing);
    await tester.tap(find.byIcon(Icons.add));
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextField).at(0), 'Coffee');
    await tester.enterText(find.byType(TextField).at(1), '12.50');
    await tester.tap(find.text('Save'));
    await tester.pumpAndSettle();

    expect(find.text('Coffee'), findsOneWidget);
    expect(expenses.currentMonthTotal, 12.5);
  });
}
