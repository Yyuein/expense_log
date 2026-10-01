import 'package:expense_log/database/app_database.dart';
import 'package:expense_log/database/database_connection.dart';
import 'package:expense_log/database/expense_database.dart';
import 'package:expense_log/pages/home_page.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  try {
    final expenses = ExpenseDatabase(AppDatabase(await openDatabase()));
    await expenses.readExpenses();
    runApp(ChangeNotifierProvider.value(value: expenses, child: const MyApp()));
  } catch (error) {
    runApp(MaterialApp(
      home: Scaffold(
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Text('无法打开本地账本：$error', textAlign: TextAlign.center),
          ),
        ),
      ),
    ));
  }
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: const HomePage(),
    );
  }
}
