import 'package:expense_log/database/expense_database.dart';
import 'package:expense_log/pages/home_page.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // initialize db
  await ExpenseDatabase.initialize();
  runApp(
    ChangeNotifierProvider(
      create: (context)=>ExpenseDatabase(),
      child: const MyApp(),
      )
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home:HomePage(),
    );
  }
}