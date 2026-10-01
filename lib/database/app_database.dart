import 'package:drift/drift.dart';

part 'app_database.g.dart';

@DataClassName('ExpenseRow')
class ExpenseEntries extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get name => text()();
  RealColumn get amount => real()();
  DateTimeColumn get date => dateTime()();
}

@DriftDatabase(tables: [ExpenseEntries])
class AppDatabase extends _$AppDatabase {
  AppDatabase(super.executor);

  @override
  int get schemaVersion => 1;
}
