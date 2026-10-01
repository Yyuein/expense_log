import 'dart:ui' show PointerDeviceKind;

import 'package:drift/native.dart';
import 'package:expense_log/database/app_database.dart';
import 'package:expense_log/database/expense_database.dart';
import 'package:expense_log/helper/helper_functions.dart';
import 'package:expense_log/main.dart';
import 'package:expense_log/models/expense.dart';
import 'package:expense_log/components/picker_item_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';
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

  testWidgets('切换月份时更新记录和合计，跨年显示年份', (tester) async {
    final expenses = ExpenseDatabase(AppDatabase(NativeDatabase.memory()));
    addTearDown(expenses.close);
    final now = DateTime.now();
    final december = DateTime(now.year - 1, 12, 10);
    final january = DateTime(now.year, 1, 10);
    await expenses.createNewExpense(
      Expense(name: 'December', amount: 12, date: december),
    );
    await expenses.createNewExpense(
      Expense(name: 'January', amount: 34, date: january),
    );

    await tester.pumpWidget(
      ChangeNotifierProvider.value(value: expenses, child: const MyApp()),
    );
    await tester.pumpAndSettle();

    final chart = tester.widget<BarChart>(find.byType(BarChart));
    final bar = chart.data.barGroups.first;
    chart.data.barTouchData.touchCallback!(
      FlTapUpEvent(TapUpDetails(
          kind: PointerDeviceKind.touch, localPosition: Offset.zero)),
      BarTouchResponse(BarTouchedSpot(
        bar,
        0,
        bar.barRods.first,
        0,
        null,
        -1,
        const FlSpot(0, 1),
        Offset.zero,
      )),
    );
    await tester.pumpAndSettle();
    expect(find.text(DateFormat('MMM yyyy').format(december)), findsOneWidget);
    expect(find.text('December'), findsOneWidget);
    expect(
        find.descendant(
            of: find.byType(AppBar), matching: find.text(formatAmount(12))),
        findsOneWidget);
    expect(find.text('January'), findsNothing);

    await tester.tap(find.byKey(const Key('next_month')));
    await tester.pumpAndSettle();
    expect(find.text(DateFormat('MMM yyyy').format(january)), findsOneWidget);
    expect(find.text('January'), findsOneWidget);
    expect(
        find.descendant(
            of: find.byType(AppBar), matching: find.text(formatAmount(34))),
        findsOneWidget);
    expect(find.text('December'), findsNothing);

    await expenses.updateExpense(
      expenses.allExpense.singleWhere((entry) => entry.name == 'January').id,
      Expense(name: 'Moved', amount: 34, date: december),
    );
    await tester.pumpAndSettle();
    expect(find.text('No expenses this month'), findsOneWidget);
    expect(find.text('Moved'), findsNothing);
    expect(
        find.descendant(
            of: find.byType(AppBar), matching: find.text(formatAmount(0))),
        findsOneWidget);

    await tester.tap(find.byKey(const Key('previous_month')));
    await tester.pumpAndSettle();
    for (final entry in List<Expense>.of(expenses.allExpense)) {
      await expenses.deleteExpense(entry.id);
    }
    await tester.pumpAndSettle();
    expect(find.text(DateFormat('MMM yyyy').format(december)), findsOneWidget);
    expect(find.text('No expenses this month'), findsOneWidget);
  });

  testWidgets('空月份可以浏览且新增日期默认为选中月份', (tester) async {
    final expenses = ExpenseDatabase(AppDatabase(NativeDatabase.memory()));
    addTearDown(expenses.close);
    final now = DateTime.now();
    final twoMonthsAgo = DateTime(now.year, now.month - 2, 5);
    final previousMonth = DateTime(now.year, now.month - 1);
    await expenses.createNewExpense(
      Expense(name: 'Older', amount: 1, date: twoMonthsAgo),
    );

    await tester.pumpWidget(
      ChangeNotifierProvider.value(value: expenses, child: const MyApp()),
    );
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('previous_month')));
    await tester.pumpAndSettle();
    expect(find.text(DateFormat('MMM yyyy').format(previousMonth)),
        findsOneWidget);
    expect(find.text('No expenses this month'), findsOneWidget);

    await tester.tap(find.byIcon(Icons.add));
    await tester.pumpAndSettle();
    final picker =
        tester.widget<PickerItemWidget>(find.byType(PickerItemWidget));
    expect(picker.date.value.year, previousMonth.year);
    expect(picker.date.value.month, previousMonth.month);
    await tester.enterText(find.byType(TextField).at(0), 'New entry');
    await tester.enterText(find.byType(TextField).at(1), '7.50');
    await tester.tap(find.text('Save'));
    await tester.pumpAndSettle();
    expect(find.text('New entry'), findsOneWidget);
    expect(
        expenses.allExpense
            .singleWhere((e) => e.name == 'New entry')
            .date
            .month,
        previousMonth.month);
  });
}
