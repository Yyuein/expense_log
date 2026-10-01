import 'package:drift/drift.dart';
import 'package:expense_log/database/app_database.dart';
import 'package:expense_log/models/expense.dart';
import 'package:flutter/foundation.dart';

class ExpenseDatabase extends ChangeNotifier {
  ExpenseDatabase(this._database);

  final AppDatabase _database;
  List<Expense> _allExpenses = [];

  List<Expense> get allExpense => List.unmodifiable(_allExpenses);

  Future<void> readExpenses() async {
    final rows = await _database.select(_database.expenseEntries).get();
    _allExpenses = rows
        .map((row) => Expense(
              id: row.id,
              name: row.name,
              amount: row.amount,
              date: row.date,
            ))
        .toList();
    notifyListeners();
  }

  Future<void> createNewExpense(Expense expense) async {
    await _database.into(_database.expenseEntries).insert(
          ExpenseEntriesCompanion.insert(
            name: expense.name,
            amount: expense.amount,
            date: expense.date,
          ),
        );
    await readExpenses();
  }

  Future<void> updateExpense(int id, Expense expense) async {
    await (_database.update(_database.expenseEntries)
          ..where((row) => row.id.equals(id)))
        .write(ExpenseEntriesCompanion(
      name: Value(expense.name),
      amount: Value(expense.amount),
      date: Value(expense.date),
    ));
    await readExpenses();
  }

  Future<void> deleteExpense(int id) async {
    await (_database.delete(_database.expenseEntries)
          ..where((row) => row.id.equals(id)))
        .go();
    await readExpenses();
  }

  Map<String, double> get monthlyTotals {
    final totals = <String, double>{};
    for (final expense in _allExpenses) {
      final key = '${expense.date.year}.${expense.date.month}';
      totals.update(key, (value) => value + expense.amount,
          ifAbsent: () => expense.amount);
    }
    return totals;
  }

  double get currentMonthTotal {
    final now = DateTime.now();
    return _allExpenses
        .where((expense) =>
            expense.date.year == now.year && expense.date.month == now.month)
        .fold(0.0, (sum, expense) => sum + expense.amount);
  }

  DateTime get startMonth {
    if (_allExpenses.isEmpty) {
      final now = DateTime.now();
      return DateTime(now.year, now.month);
    }
    final earliest =
        _allExpenses.reduce((a, b) => a.date.isBefore(b.date) ? a : b);
    return DateTime(earliest.date.year, earliest.date.month);
  }

  Future<void> close() async {
    await _database.close();
    dispose();
  }
}
