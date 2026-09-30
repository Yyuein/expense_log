class Expense {
  final int id;
  final String name;
  final double amount;
  final DateTime date;

  const Expense({
    this.id = 0,
    required this.name,
    required this.amount,
    required this.date,
  });
}
