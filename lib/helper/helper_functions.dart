import 'package:intl/intl.dart';

String formatAmount(double amount) {
  return NumberFormat.currency(symbol: '¥', decimalDigits: 2).format(amount);
}

int calculateMonthCount(
    int startYear, int startMonth, int currentYear, int currentMonth) {
  return (currentYear - startYear) * 12 + currentMonth - startMonth + 1;
}

String getCurrentMonthName() {
  const months = [
    'JAN',
    'FEB',
    'MAR',
    'APR',
    'MAY',
    'JUN',
    'JUL',
    'AUG',
    'SEP',
    'OCT',
    'NOV',
    'DEC',
  ];
  return months[DateTime.now().month - 1];
}

String formatDate(DateTime date) {
  return '${date.year}/${date.month}/${date.day}';
}
