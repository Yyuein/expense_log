import 'package:drift/native.dart';
import 'package:expense_log/database/app_database.dart';
import 'package:expense_log/database/expense_database.dart';
import 'package:expense_log/models/expense.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  late ExpenseDatabase expenses;

  setUp(() async {
    expenses = ExpenseDatabase(AppDatabase(NativeDatabase.memory()));
    await expenses.readExpenses();
  });

  tearDown(() => expenses.close());

  test('空账本汇总为零，起始月是当前月', () {
    final now = DateTime.now();
    expect(expenses.allExpense, isEmpty);
    expect(expenses.monthlyTotals, isEmpty);
    expect(expenses.currentMonthTotal, 0);
    expect(expenses.startMonth.year, now.year);
    expect(expenses.startMonth.month, now.month);
  });

  test('新增、修改、删除支出会更新列表和月度汇总', () async {
    final now = DateTime.now();
    final thisMonth = DateTime(now.year, now.month, 3);
    final previousMonth = DateTime(now.year, now.month - 1, 4);

    await expenses.createNewExpense(
      Expense(name: 'Coffee', amount: 12.5, date: thisMonth),
    );
    await expenses.createNewExpense(
      Expense(name: 'Train', amount: 30, date: previousMonth),
    );

    final id = expenses.allExpense.singleWhere((e) => e.name == 'Coffee').id;
    expect(id, greaterThan(0));
    expect(expenses.currentMonthTotal, 12.5);
    expect(expenses.monthlyTotals['${now.year}.${now.month}'], 12.5);
    expect(
        expenses.monthlyTotals['${previousMonth.year}.${previousMonth.month}'],
        30);
    expect(expenses.startMonth.month, previousMonth.month);

    await expenses.updateExpense(
      id,
      Expense(name: 'Lunch', amount: 20, date: thisMonth),
    );
    expect(expenses.allExpense.singleWhere((e) => e.id == id).name, 'Lunch');
    expect(expenses.currentMonthTotal, 20);

    await expenses.deleteExpense(id);
    expect(expenses.allExpense, hasLength(1));
    expect(expenses.currentMonthTotal, 0);
    expect(expenses.monthlyTotals.containsKey('${now.year}.${now.month}'),
        isFalse);
  });

  test('修改后重新读取数据库仍能取回相同记录', () async {
    final date = DateTime(2025, 5, 6);
    await expenses.createNewExpense(
      Expense(name: 'Book', amount: 8.75, date: date),
    );
    await expenses.readExpenses();

    expect(expenses.allExpense.single.name, 'Book');
    expect(expenses.allExpense.single.amount, 8.75);
    expect(expenses.allExpense.single.date.year, 2025);
    expect(expenses.allExpense.single.date.month, 5);
    expect(expenses.allExpense.single.date.day, 6);
  });
}
