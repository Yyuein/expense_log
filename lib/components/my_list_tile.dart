import 'package:expense_log/helper/helper_functions.dart';
import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';

class MyListTile extends StatelessWidget {
  const MyListTile({
    super.key,
    required this.title,
    required this.trailing,
    required this.date,
    required this.onEditPressed,
    required this.onDeletePressed,
  });

  final String title;
  final String trailing;
  final DateTime date;
  final void Function(BuildContext)? onEditPressed;
  final void Function(BuildContext)? onDeletePressed;

  @override
  Widget build(BuildContext context) {
    const ink = Color.fromARGB(255, 70, 75, 65);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5, horizontal: 25),
      child: Slidable(
        endActionPane: ActionPane(
          motion: const StretchMotion(),
          children: [
            SlidableAction(
              onPressed: onEditPressed,
              icon: Icons.settings,
              backgroundColor: Colors.white,
              foregroundColor: ink,
              borderRadius: BorderRadius.circular(4),
            ),
            SlidableAction(
              onPressed: onDeletePressed,
              icon: Icons.delete,
              backgroundColor: const Color.fromARGB(255, 180, 137, 125),
              foregroundColor: ink,
              borderRadius: BorderRadius.circular(4),
            ),
          ],
        ),
        child: Container(
          decoration: BoxDecoration(
            color: const Color.fromARGB(255, 150, 159, 168),
            borderRadius: BorderRadius.circular(8),
          ),
          child: ListTile(
            title: Text(title,
                style: const TextStyle(color: ink, fontFamily: 'GapSansBold')),
            trailing: Text(trailing,
                style: const TextStyle(
                    color: ink, fontFamily: 'GapSansBold', fontSize: 15)),
            subtitle: Text(formatDate(date),
                style: const TextStyle(color: ink, fontSize: 12)),
          ),
        ),
      ),
    );
  }
}
