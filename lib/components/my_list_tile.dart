import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';

class MyListTile extends StatelessWidget {
  final String title;
  final String trailing;
  final void Function(BuildContext)? onEditPressed;
  final void Function(BuildContext)? onDeletePressed;
  
  const MyListTile({
    super.key,
    required this.title,
    required this.trailing,
    required this.onDeletePressed,
    required this.onEditPressed,
    });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5,horizontal: 25),
      child: Slidable(
        endActionPane: ActionPane(
          motion: const StretchMotion(), 
        children: [
          SlidableAction(
            onPressed: onEditPressed,
            icon: Icons.settings,
            backgroundColor: Colors.white,
            foregroundColor: Color.fromARGB(255, 75, 70, 65),
            borderRadius: BorderRadius.circular(4),
          ),
          SlidableAction(
            onPressed: onDeletePressed,
            icon: Icons.delete,
            backgroundColor: Color.fromARGB(255, 180, 137, 125),
            foregroundColor: Color.fromARGB(255, 75, 70, 65),
            borderRadius: BorderRadius.circular(4),
          ),
        ],
        ),
        child: Container(
          decoration: BoxDecoration(
            color: Color.fromARGB(255, 150, 159, 168),
            borderRadius: BorderRadius.circular(8),
          ),
          child: ListTile(
            title: Text(title),
            trailing: Text(trailing),
          ),
        ),
      ),
    );
  }
}