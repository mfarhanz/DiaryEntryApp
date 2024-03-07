import 'dart:io';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../model/diary_entry_model.dart';

class DiaryEntryWidget extends StatelessWidget {
  final DiaryEntry entry;
  final Function onDelete;

  DiaryEntryWidget({required this.entry, required this.onDelete});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      child: Container(
        padding: EdgeInsets.all(10.0),
        margin: EdgeInsets.symmetric(vertical: 10.0, horizontal: 5.0),
        decoration: BoxDecoration(
            color: Color.fromARGB(255, 86, 88, 104).withOpacity(0.3),
            borderRadius: BorderRadius.circular(10),
            image: DecorationImage(
              fit: BoxFit.cover,
              opacity: 0.4,
              image: NetworkImage(entry.image!),
            )),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  DateFormat('EE / MMM d / y').format(entry.date.toLocal()),
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                Row(
                  children: List.generate(
                    5,
                    (index) => Icon(
                      Icons.star,
                      color: index < entry.rating
                          ? Color.fromARGB(255, 123, 68, 217)
                          : Colors.grey,
                    ),
                  ),
                ),
                IconButton(
                  color: const Color.fromARGB(255, 195, 191, 191),
                  icon: Icon(Icons.delete),
                  onPressed: () => onDelete(),
                ),
              ],
            ),
            SizedBox(height: 22),
            Text(
              entry.desc,
              style: TextStyle(fontSize: 16),
            ),
            SizedBox(height: 40),
          ],
        ),
      ),
    );
  }
}
