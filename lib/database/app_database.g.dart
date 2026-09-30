// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'app_database.dart';

// ignore_for_file: type=lint
class $ExpenseEntriesTable extends ExpenseEntries
    with TableInfo<$ExpenseEntriesTable, ExpenseRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ExpenseEntriesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
      'id', aliasedName, false,
      hasAutoIncrement: true,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('PRIMARY KEY AUTOINCREMENT'));
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
      'name', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _amountMeta = const VerificationMeta('amount');
  @override
  late final GeneratedColumn<double> amount = GeneratedColumn<double>(
      'amount', aliasedName, false,
      type: DriftSqlType.double, requiredDuringInsert: true);
  static const VerificationMeta _dateMeta = const VerificationMeta('date');
  @override
  late final GeneratedColumn<DateTime> date = GeneratedColumn<DateTime>(
      'date', aliasedName, false,
      type: DriftSqlType.dateTime, requiredDuringInsert: true);
  @override
  List<GeneratedColumn> get $columns => [id, name, amount, date];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'expense_entries';
  @override
  VerificationContext validateIntegrity(Insertable<ExpenseRow> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('name')) {
      context.handle(
          _nameMeta, name.isAcceptableOrUnknown(data['name']!, _nameMeta));
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('amount')) {
      context.handle(_amountMeta,
          amount.isAcceptableOrUnknown(data['amount']!, _amountMeta));
    } else if (isInserting) {
      context.missing(_amountMeta);
    }
    if (data.containsKey('date')) {
      context.handle(
          _dateMeta, date.isAcceptableOrUnknown(data['date']!, _dateMeta));
    } else if (isInserting) {
      context.missing(_dateMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  ExpenseRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return ExpenseRow(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}id'])!,
      name: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}name'])!,
      amount: attachedDatabase.typeMapping
          .read(DriftSqlType.double, data['${effectivePrefix}amount'])!,
      date: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}date'])!,
    );
  }

  @override
  $ExpenseEntriesTable createAlias(String alias) {
    return $ExpenseEntriesTable(attachedDatabase, alias);
  }
}

class ExpenseRow extends DataClass implements Insertable<ExpenseRow> {
  final int id;
  final String name;
  final double amount;
  final DateTime date;
  const ExpenseRow(
      {required this.id,
      required this.name,
      required this.amount,
      required this.date});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['name'] = Variable<String>(name);
    map['amount'] = Variable<double>(amount);
    map['date'] = Variable<DateTime>(date);
    return map;
  }

  ExpenseEntriesCompanion toCompanion(bool nullToAbsent) {
    return ExpenseEntriesCompanion(
      id: Value(id),
      name: Value(name),
      amount: Value(amount),
      date: Value(date),
    );
  }

  factory ExpenseRow.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return ExpenseRow(
      id: serializer.fromJson<int>(json['id']),
      name: serializer.fromJson<String>(json['name']),
      amount: serializer.fromJson<double>(json['amount']),
      date: serializer.fromJson<DateTime>(json['date']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'name': serializer.toJson<String>(name),
      'amount': serializer.toJson<double>(amount),
      'date': serializer.toJson<DateTime>(date),
    };
  }

  ExpenseRow copyWith(
          {int? id, String? name, double? amount, DateTime? date}) =>
      ExpenseRow(
        id: id ?? this.id,
        name: name ?? this.name,
        amount: amount ?? this.amount,
        date: date ?? this.date,
      );
  ExpenseRow copyWithCompanion(ExpenseEntriesCompanion data) {
    return ExpenseRow(
      id: data.id.present ? data.id.value : this.id,
      name: data.name.present ? data.name.value : this.name,
      amount: data.amount.present ? data.amount.value : this.amount,
      date: data.date.present ? data.date.value : this.date,
    );
  }

  @override
  String toString() {
    return (StringBuffer('ExpenseRow(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('amount: $amount, ')
          ..write('date: $date')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, name, amount, date);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is ExpenseRow &&
          other.id == this.id &&
          other.name == this.name &&
          other.amount == this.amount &&
          other.date == this.date);
}

class ExpenseEntriesCompanion extends UpdateCompanion<ExpenseRow> {
  final Value<int> id;
  final Value<String> name;
  final Value<double> amount;
  final Value<DateTime> date;
  const ExpenseEntriesCompanion({
    this.id = const Value.absent(),
    this.name = const Value.absent(),
    this.amount = const Value.absent(),
    this.date = const Value.absent(),
  });
  ExpenseEntriesCompanion.insert({
    this.id = const Value.absent(),
    required String name,
    required double amount,
    required DateTime date,
  })  : name = Value(name),
        amount = Value(amount),
        date = Value(date);
  static Insertable<ExpenseRow> custom({
    Expression<int>? id,
    Expression<String>? name,
    Expression<double>? amount,
    Expression<DateTime>? date,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (name != null) 'name': name,
      if (amount != null) 'amount': amount,
      if (date != null) 'date': date,
    });
  }

  ExpenseEntriesCompanion copyWith(
      {Value<int>? id,
      Value<String>? name,
      Value<double>? amount,
      Value<DateTime>? date}) {
    return ExpenseEntriesCompanion(
      id: id ?? this.id,
      name: name ?? this.name,
      amount: amount ?? this.amount,
      date: date ?? this.date,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (amount.present) {
      map['amount'] = Variable<double>(amount.value);
    }
    if (date.present) {
      map['date'] = Variable<DateTime>(date.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ExpenseEntriesCompanion(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('amount: $amount, ')
          ..write('date: $date')
          ..write(')'))
        .toString();
  }
}

abstract class _$AppDatabase extends GeneratedDatabase {
  _$AppDatabase(QueryExecutor e) : super(e);
  $AppDatabaseManager get managers => $AppDatabaseManager(this);
  late final $ExpenseEntriesTable expenseEntries = $ExpenseEntriesTable(this);
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [expenseEntries];
}

typedef $$ExpenseEntriesTableCreateCompanionBuilder = ExpenseEntriesCompanion
    Function({
  Value<int> id,
  required String name,
  required double amount,
  required DateTime date,
});
typedef $$ExpenseEntriesTableUpdateCompanionBuilder = ExpenseEntriesCompanion
    Function({
  Value<int> id,
  Value<String> name,
  Value<double> amount,
  Value<DateTime> date,
});

class $$ExpenseEntriesTableFilterComposer
    extends Composer<_$AppDatabase, $ExpenseEntriesTable> {
  $$ExpenseEntriesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get name => $composableBuilder(
      column: $table.name, builder: (column) => ColumnFilters(column));

  ColumnFilters<double> get amount => $composableBuilder(
      column: $table.amount, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get date => $composableBuilder(
      column: $table.date, builder: (column) => ColumnFilters(column));
}

class $$ExpenseEntriesTableOrderingComposer
    extends Composer<_$AppDatabase, $ExpenseEntriesTable> {
  $$ExpenseEntriesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get name => $composableBuilder(
      column: $table.name, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<double> get amount => $composableBuilder(
      column: $table.amount, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get date => $composableBuilder(
      column: $table.date, builder: (column) => ColumnOrderings(column));
}

class $$ExpenseEntriesTableAnnotationComposer
    extends Composer<_$AppDatabase, $ExpenseEntriesTable> {
  $$ExpenseEntriesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<double> get amount =>
      $composableBuilder(column: $table.amount, builder: (column) => column);

  GeneratedColumn<DateTime> get date =>
      $composableBuilder(column: $table.date, builder: (column) => column);
}

class $$ExpenseEntriesTableTableManager extends RootTableManager<
    _$AppDatabase,
    $ExpenseEntriesTable,
    ExpenseRow,
    $$ExpenseEntriesTableFilterComposer,
    $$ExpenseEntriesTableOrderingComposer,
    $$ExpenseEntriesTableAnnotationComposer,
    $$ExpenseEntriesTableCreateCompanionBuilder,
    $$ExpenseEntriesTableUpdateCompanionBuilder,
    (
      ExpenseRow,
      BaseReferences<_$AppDatabase, $ExpenseEntriesTable, ExpenseRow>
    ),
    ExpenseRow,
    PrefetchHooks Function()> {
  $$ExpenseEntriesTableTableManager(
      _$AppDatabase db, $ExpenseEntriesTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$ExpenseEntriesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$ExpenseEntriesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$ExpenseEntriesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<int> id = const Value.absent(),
            Value<String> name = const Value.absent(),
            Value<double> amount = const Value.absent(),
            Value<DateTime> date = const Value.absent(),
          }) =>
              ExpenseEntriesCompanion(
            id: id,
            name: name,
            amount: amount,
            date: date,
          ),
          createCompanionCallback: ({
            Value<int> id = const Value.absent(),
            required String name,
            required double amount,
            required DateTime date,
          }) =>
              ExpenseEntriesCompanion.insert(
            id: id,
            name: name,
            amount: amount,
            date: date,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ));
}

typedef $$ExpenseEntriesTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $ExpenseEntriesTable,
    ExpenseRow,
    $$ExpenseEntriesTableFilterComposer,
    $$ExpenseEntriesTableOrderingComposer,
    $$ExpenseEntriesTableAnnotationComposer,
    $$ExpenseEntriesTableCreateCompanionBuilder,
    $$ExpenseEntriesTableUpdateCompanionBuilder,
    (
      ExpenseRow,
      BaseReferences<_$AppDatabase, $ExpenseEntriesTable, ExpenseRow>
    ),
    ExpenseRow,
    PrefetchHooks Function()>;

class $AppDatabaseManager {
  final _$AppDatabase _db;
  $AppDatabaseManager(this._db);
  $$ExpenseEntriesTableTableManager get expenseEntries =>
      $$ExpenseEntriesTableTableManager(_db, _db.expenseEntries);
}
