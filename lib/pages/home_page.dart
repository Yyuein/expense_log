import 'package:expense_log/bar%20graph/bar_graph.dart';
import 'package:expense_log/components/my_list_tile.dart';
import 'package:expense_log/database/expense_database.dart';
import 'package:expense_log/helper/helper_functions.dart';
import 'package:expense_log/models/expense.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
// text controllers
  TextEditingController nameController = TextEditingController();
  TextEditingController amountController = TextEditingController();

// futures to load graph data & monthly total
  Future<Map<String, double>>? _monthlyTotalsFuture;
  Future<double>? _calculateCurrentMonthTotal;

  @override
  void initState() {
    // read db on initial startup
    Provider.of<ExpenseDatabase>(context, listen: false).readExpenses();

    // load futures
    refreshData();

    super.initState();
  }

// refresh graph data
  void refreshData() {
    _monthlyTotalsFuture = Provider.of<ExpenseDatabase>(context, listen: false)
        .calculateMonthlyTotals();
    _calculateCurrentMonthTotal =
        Provider.of<ExpenseDatabase>(context, listen: false)
            .calculateCurrentMonthTotal();
  }

// open new expense box
  void openNewExpenseBox() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.white,
        title: Text(
          "New expense",
          style: TextStyle(
              color: Color.fromARGB(255, 70, 75, 65),
              fontFamily: 'GapSansBold'),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nameController,
              decoration: const InputDecoration(
                hintText: "Name",
                hintStyle: TextStyle(
                  color: Color.fromARGB(255, 150, 159, 168),
                ),
              ),
              style: TextStyle(fontFamily: 'GapSansBold'),
            ),
            TextField(
              controller: amountController,
              decoration: const InputDecoration(
                hintText: "Amount",
                hintStyle: TextStyle(
                    color: Color.fromARGB(255, 150, 159, 168),
                    fontFamily: 'GapSansBold'),
              ),
              style: TextStyle(fontFamily: 'GapSansBold'),
            ),
          ],
        ),
        actions: [
          // cancel button
          _cancelButton(),
          // save button
          _creatNewExpenseButton()
        ],
      ),
    );
  }

// open edit box
  void openEditBox(Expense expense) {
    String existingName = expense.name;
    String existingAmount = expense.amount.toString();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.white,
        title: const Text(
          "Edit expense",
          style: TextStyle(
              color: Color.fromARGB(255, 70, 75, 65),
              fontFamily: 'GapSansBold'),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nameController,
              decoration: InputDecoration(
                hintText: existingName,
                hintStyle: TextStyle(
                    color: Color.fromARGB(255, 150, 159, 168),
                    fontFamily: 'GapSansBold'),
              ),
            ),
            TextField(
              controller: amountController,
              decoration: InputDecoration(
                hintText: existingAmount,
                hintStyle: TextStyle(
                    color: Color.fromARGB(255, 150, 159, 168),
                    fontFamily: 'GapSansBold'),
              ),
            ),
          ],
        ),
        actions: [
          // cancel button
          _cancelButton(),
          // save button
          _editExpenseButton(expense),
        ],
      ),
    );
  }

// open delete box
  void openDeleteBox(Expense expense) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.white,
        title: const Text(
          "Delete expense",
          style: TextStyle(
              color: Color.fromARGB(255, 70, 75, 65),
              fontFamily: 'GapSansBold'),
        ),
        actions: [
          // cancel button
          _cancelButton(),
          // save button
          _deleteExpenseButton(expense.id),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<ExpenseDatabase>(
      builder: (context, value, child) {
        // get dates
        int startMonth = value.getStarMonth();
        int startYear = value.getStarYear();
        int currentMonth = DateTime.now().month;
        int currentYear = DateTime.now().year;

        //calculate the number of months since the first month
        int monthCount = calculateMonthCount(
            startYear, startMonth, currentYear, currentMonth);

        // only display the expenses for the current month
        List<Expense> currentMonthExpenses = value.allExpense.where((expense) {
          return expense.date.year == currentYear &&
              expense.date.month == currentMonth;
        }).toList();

        // return UI
        return Scaffold(
          backgroundColor: Color.fromARGB(255, 213, 217, 222),
          floatingActionButton: FloatingActionButton(
            backgroundColor: Color.fromARGB(255, 70, 75, 65),
            foregroundColor: Colors.white,
            onPressed: openNewExpenseBox,
            child: Icon(Icons.add),
          ),
          appBar: AppBar(
            backgroundColor: Colors.transparent,
            title: FutureBuilder<double>(
                future: _calculateCurrentMonthTotal,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.done) {
                    return Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        // amount total
                        Text(
                          "￥${snapshot.data!.toStringAsFixed(2)}",
                          style: TextStyle(
                              color: Color.fromARGB(255, 70, 75, 65),
                              fontFamily: 'GapSansBold'),
                        ),
                        // month
                        Text(
                          getCurrentMonthName(),
                          style: TextStyle(
                              color: Color.fromARGB(255, 70, 75, 65),
                              fontFamily: 'GapSansBold'),
                        ),
                      ],
                    );
                  } else {
                    return const Text(
                      "loading...",
                      style: TextStyle(
                          color: Color.fromARGB(255, 70, 75, 65),
                          fontFamily: 'GapSansBold'),
                    );
                  }
                }),
          ),
          body: SafeArea(
            child: Column(
              children: [
                // graph ui
                SizedBox(
                  height: 250,
                  child: FutureBuilder(
                    future: _monthlyTotalsFuture,
                    builder: (context, snapshot) {
                      // data is loaded
                      if (snapshot.connectionState == ConnectionState.done) {
                        Map<String, double> monthlyTotals = snapshot.data ?? {};

                        // create the list of monthly summary
                        List<double> monthlySummary = List.generate(
                          monthCount,
                          (index) {
                            // calculate year-month considering startMonth & index
                            int year =
                                startYear + (startMonth + index - 1) ~/ 12;
                            int month = (startMonth + index - 1) % 12 + 1;

                            // create the key in the format "year-month"
                            String yearMonthKey =
                                year.toString() + "." + month.toString();

                            // return the total for year-month or 0.0 if non-existent
                            return monthlyTotals[yearMonthKey] ?? 0.0;
                          },
                        );

                        return MyBarGraph(
                            monthlySummary: monthlySummary,
                            startMonth: startMonth);
                      }

                      // loading..
                      else {
                        return const Center(
                          child: Text(
                            "loading...",
                            style: TextStyle(
                                color: Color.fromARGB(255, 70, 75, 65),
                                fontFamily: 'GapSansBold'),
                          ),
                        );
                      }
                    },
                  ),
                ),

                const SizedBox(height: 25),

                // expense list ui
                Expanded(
                  child: ListView.builder(
                      itemCount: currentMonthExpenses.length,
                      itemBuilder: (context, index) {
                        // reverse the index to show latest item first
                        int reversedIndex =
                            currentMonthExpenses.length - 1 - index;
                        // get individual expense
                        Expense individualExpense =
                            currentMonthExpenses[reversedIndex];

                        // return list tile UI
                        return MyListTile(
                          title: individualExpense.name,
                          trailing: formatAmount(individualExpense.amount),
                          onEditPressed: (context) =>
                              openEditBox(individualExpense),
                          onDeletePressed: (context) =>
                              openDeleteBox(individualExpense),
                        );
                      }),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

// cancel button
  Widget _cancelButton() {
    return MaterialButton(
      onPressed: () {
        Navigator.pop(context);

        nameController.clear();
        amountController.clear();
      },
      child: const Text(
        "Cancel",
        style: TextStyle(
            color: Color.fromARGB(255, 70, 75, 65), fontFamily: 'GapSansBold'),
      ),
    );
  }

// save button
  Widget _creatNewExpenseButton() {
    return MaterialButton(
      onPressed: () async {
        if (nameController.text.isNotEmpty &&
            amountController.text.isNotEmpty) {
          Navigator.pop(context);

          Expense newExpense = Expense(
            name: nameController.text,
            amount: convertStringToDouble(amountController.text),
            date: DateTime.now(),
          );

          await context.read<ExpenseDatabase>().createNewExpense(newExpense);

          refreshData();

          nameController.clear();
          amountController.clear();
        }
      },
      child: const Text(
        "Save",
        style: TextStyle(
            color: Color.fromARGB(255, 70, 75, 65), fontFamily: 'GapSansBold'),
      ),
    );
  }

// save button -> Edit existing expense
  Widget _editExpenseButton(Expense expense) {
    return MaterialButton(
      onPressed: () async {
        if (nameController.text.isNotEmpty ||
            amountController.text.isNotEmpty) {
          Navigator.pop(context);

          Expense updatedExpense = Expense(
              name: nameController.text.isNotEmpty
                  ? nameController.text
                  : expense.name,
              amount: amountController.text.isNotEmpty
                  ? convertStringToDouble(amountController.text)
                  : expense.amount,
              date: DateTime.now());

          int existingId = expense.id;

          await context
              .read<ExpenseDatabase>()
              .updateExpense(existingId, updatedExpense);

          refreshData();
        }
      },
      child: const Text(
        "Save",
        style: TextStyle(
            color: Color.fromARGB(255, 70, 75, 65), fontFamily: 'GapSansBold'),
      ),
    );
  }

// delete button
  Widget _deleteExpenseButton(int id) {
    return MaterialButton(
      onPressed: () async {
        Navigator.pop(context);

        await context.read<ExpenseDatabase>().deleteExpense(id);

        refreshData();
      },
      child: const Text(
        "Delete",
        style: TextStyle(
            color: Color.fromARGB(255, 70, 75, 65), fontFamily: 'GapSansBold'),
      ),
    );
  }
}
