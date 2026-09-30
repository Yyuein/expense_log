import 'package:drift/drift.dart';
import 'package:drift_flutter/drift_flutter.dart';

Future<QueryExecutor> openDatabase() async {
  return driftDatabase(name: 'expense_log');
}
