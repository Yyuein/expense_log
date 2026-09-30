import 'package:board_datetime_picker/board_datetime_picker.dart';
import 'package:expense_log/bar%20graph/bar_graph.dart';
import 'package:expense_log/components/my_list_tile.dart';
import 'package:expense_log/components/picker_item_widget.dart';
import 'package:expense_log/database/expense_database.dart';
import 'package:expense_log/helper/helper_functions.dart';
import 'package:expense_log/models/expense.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  static const _ink = Color.fromARGB(255, 70, 75, 65);

  Future<void> _showExpenseDialog(BuildContext context, {Expense? expense}) {
    return showDialog<void>(
      context: context,
      builder: (_) => _ExpenseEditorDialog(expense: expense),
    );
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
        final start = database.startMonth;
        final latest = database.allExpense.fold<DateTime>(
          now,
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
        final currentExpenses = database.allExpense
            .where((expense) =>
                expense.date.year == now.year &&
                expense.date.month == now.month)
            .toList()
          ..sort((a, b) => b.date.compareTo(a.date));

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
            title: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(formatAmount(database.currentMonthTotal),
                    style: const TextStyle(
                        color: _ink, fontFamily: 'GapSansBold')),
                Text(getCurrentMonthName(),
                    style: const TextStyle(
                        color: _ink, fontFamily: 'GapSansBold')),
              ],
            ),
          ),
          body: SafeArea(
            child: Column(
              children: [
                SizedBox(
                  height: 250,
                  child: MyBarGraph(
                    monthlySummary: monthlySummary,
                    startMonth: start.month,
                  ),
                ),
                const SizedBox(height: 25),
                Expanded(
                  child: ListView.builder(
                    itemCount: currentExpenses.length,
                    itemBuilder: (context, index) {
                      final expense = currentExpenses[index];
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
  const _ExpenseEditorDialog({this.expense});

  final Expense? expense;

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
    _selectedDate = ValueNotifier(widget.expense?.date ?? DateTime.now());
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
      if (mounted) Navigator.pop(context);
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
