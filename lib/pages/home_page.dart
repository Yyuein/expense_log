import 'package:board_datetime_picker/board_datetime_picker.dart';
import 'package:expense_log/bar%20graph/bar_graph.dart';
import 'package:expense_log/components/my_list_tile.dart';
import 'package:expense_log/components/picker_item_widget.dart';
import 'package:expense_log/database/expense_database.dart';
import 'package:expense_log/helper/helper_functions.dart';
import 'package:expense_log/models/expense.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  static const _ink = Color.fromARGB(255, 70, 75, 65);
  late DateTime _selectedMonth;

  @override
  void initState() {
    super.initState();
    final now = DateTime.now();
    _selectedMonth = DateTime(now.year, now.month);
  }

  Future<void> _showExpenseDialog(BuildContext context,
      {Expense? expense}) async {
    final now = DateTime.now();
    final initialDate = expense?.date ??
        (_selectedMonth.year == now.year && _selectedMonth.month == now.month
            ? now
            : DateTime(_selectedMonth.year, _selectedMonth.month));
    final savedDate = await showDialog<DateTime>(
      context: context,
      builder: (_) =>
          _ExpenseEditorDialog(expense: expense, initialDate: initialDate),
    );
    if (expense == null && savedDate != null && mounted) {
      setState(
          () => _selectedMonth = DateTime(savedDate.year, savedDate.month));
    }
  }

  Future<void> _showDeleteDialog(BuildContext context, Expense expense) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Delete expense'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
    if (confirmed != true || !context.mounted) return;
    try {
      await context.read<ExpenseDatabase>().deleteExpense(expense.id);
    } catch (_) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text('删除失败，请重试'),
        ));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<ExpenseDatabase>(
      builder: (context, database, child) {
        final now = DateTime.now();
        final firstExpenseMonth = database.startMonth;
        final start = _selectedMonth.isBefore(firstExpenseMonth)
            ? _selectedMonth
            : firstExpenseMonth;
        final latest = database.allExpense.fold<DateTime>(
          _selectedMonth.isAfter(now) ? _selectedMonth : now,
          (date, expense) => expense.date.isAfter(date) ? expense.date : date,
        );
        final monthCount = calculateMonthCount(
          start.year,
          start.month,
          latest.year,
          latest.month,
        );
        final totals = database.monthlyTotals;
        final monthlySummary = List<double>.generate(monthCount, (index) {
          final year = start.year + (start.month + index - 1) ~/ 12;
          final month = (start.month + index - 1) % 12 + 1;
          return totals['$year.$month'] ?? 0.0;
        });
        final selectedExpenses = database.allExpense
            .where((expense) =>
                expense.date.year == _selectedMonth.year &&
                expense.date.month == _selectedMonth.month)
            .toList()
          ..sort((a, b) => b.date.compareTo(a.date));
        final selectedTotal =
            totals['${_selectedMonth.year}.${_selectedMonth.month}'] ?? 0.0;
        final selectedIndex = calculateMonthCount(start.year, start.month,
                _selectedMonth.year, _selectedMonth.month) -
            1;

        return Scaffold(
          backgroundColor: const Color.fromARGB(255, 213, 217, 222),
          floatingActionButton: FloatingActionButton(
            backgroundColor: _ink,
            foregroundColor: Colors.white,
            onPressed: () => _showExpenseDialog(context),
            child: const Icon(Icons.add),
          ),
          appBar: AppBar(
            backgroundColor: Colors.transparent,
            title: Text(formatAmount(selectedTotal),
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(color: _ink, fontFamily: 'GapSansBold')),
            actions: [
              IconButton(
                key: const Key('previous_month'),
                tooltip: 'Previous month',
                onPressed: _selectedMonth.isAfter(start)
                    ? () => setState(() => _selectedMonth =
                        DateTime(_selectedMonth.year, _selectedMonth.month - 1))
                    : null,
                icon: const Icon(Icons.chevron_left),
              ),
              Center(
                child: Text(DateFormat('MMM yyyy').format(_selectedMonth),
                    style: const TextStyle(
                        color: _ink, fontFamily: 'GapSansBold')),
              ),
              IconButton(
                key: const Key('next_month'),
                tooltip: 'Next month',
                onPressed: DateTime(_selectedMonth.year, _selectedMonth.month)
                        .isBefore(DateTime(latest.year, latest.month))
                    ? () => setState(() => _selectedMonth =
                        DateTime(_selectedMonth.year, _selectedMonth.month + 1))
                    : null,
                icon: const Icon(Icons.chevron_right),
              ),
            ],
          ),
          body: SafeArea(
            child: Column(
              children: [
                SizedBox(
                  height: 250,
                  child: MyBarGraph(
                    monthlySummary: monthlySummary,
                    startMonth: start.month,
                    selectedIndex: selectedIndex,
                    onMonthSelected: (index) => setState(() => _selectedMonth =
                        DateTime(start.year, start.month + index)),
                  ),
                ),
                const SizedBox(height: 25),
                Expanded(
                  child: selectedExpenses.isEmpty
                      ? const Center(child: Text('No expenses this month'))
                      : ListView.builder(
                          itemCount: selectedExpenses.length,
                          itemBuilder: (context, index) {
                            final expense = selectedExpenses[index];
                            return MyListTile(
                              title: expense.name,
                              trailing: formatAmount(expense.amount),
                              date: expense.date,
                              onEditPressed: (_) =>
                                  _showExpenseDialog(context, expense: expense),
                              onDeletePressed: (_) =>
                                  _showDeleteDialog(context, expense),
                            );
                          },
                        ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _ExpenseEditorDialog extends StatefulWidget {
  const _ExpenseEditorDialog({this.expense, required this.initialDate});

  final Expense? expense;
  final DateTime initialDate;

  @override
  State<_ExpenseEditorDialog> createState() => _ExpenseEditorDialogState();
}

class _ExpenseEditorDialogState extends State<_ExpenseEditorDialog> {
  late final TextEditingController _nameController;
  late final TextEditingController _amountController;
  late final ValueNotifier<DateTime> _selectedDate;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.expense?.name);
    _amountController =
        TextEditingController(text: widget.expense?.amount.toString());
    _selectedDate = ValueNotifier(widget.initialDate);
  }

  @override
  void dispose() {
    _nameController.dispose();
    _amountController.dispose();
    _selectedDate.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    final name = _nameController.text.trim();
    final amount = double.tryParse(_amountController.text.trim());
    if (name.isEmpty || amount == null || !amount.isFinite) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text('请输入名称和有效金额'),
      ));
      return;
    }

    setState(() => _saving = true);
    try {
      final entry =
          Expense(name: name, amount: amount, date: _selectedDate.value);
      final database = context.read<ExpenseDatabase>();
      if (widget.expense == null) {
        await database.createNewExpense(entry);
      } else {
        await database.updateExpense(widget.expense!.id, entry);
      }
      if (mounted) Navigator.pop(context, entry.date);
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text('保存失败，请重试'),
        ));
        setState(() => _saving = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: Colors.white,
      title: Text(widget.expense == null ? 'New expense' : 'Edit expense'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextField(
            controller: _nameController,
            decoration: const InputDecoration(hintText: 'Name'),
          ),
          TextField(
            controller: _amountController,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            decoration: const InputDecoration(hintText: 'Amount'),
          ),
          PickerItemWidget(
            pickerType: DateTimePickerType.date,
            date: _selectedDate,
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: _saving ? null : () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        TextButton(
          onPressed: _saving ? null : _save,
          child: const Text('Save'),
        ),
      ],
    );
  }
}
