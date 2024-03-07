import 'dart:io';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/services.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:path_provider/path_provider.dart';

import './add_edit_diary_entry_view.dart';
import '../model/diary_entry_model.dart';
import '../controller/diary_entry_service.dart';
import '../view/components/diary_entry_widget.dart';

class DiaryListView extends StatelessWidget {
  DiaryListView({
    Key? key,
  }) : super(key: key);
  final DiaryService diaryService = DiaryService();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text('Diary Entries'),
          actions: [
            IconButton(
              icon: Icon(Icons.logout),
              onPressed: () async {
                await FirebaseAuth.instance.signOut();
              },
            ),
          ],
        ),
        body: StreamBuilder<List<DiaryEntry>>(
          stream: diaryService.getUserEntries(),
          builder: ((context, snapshot) {
            if (!snapshot.hasData || snapshot.data == null) {
              print(snapshot);
              return const Center(child: CircularProgressIndicator());
            } else {
              print(snapshot);
              print(snapshot.hashCode);
              final entries = snapshot.data!;
              DateTime? lastDate;
              return ListView.builder(
                  itemCount: entries.length,
                  itemBuilder: (context, index) {
                    final entry = entries[index];
                    lastDate = entry.date;
                    return ListTile(
                        onLongPress: () {
                          showDialog(
                              context: context,
                              builder: (context) => AddEditEntryView(
                                    diaryService: diaryService,
                                    editing: true,
                                    entry: entry,
                                  ));
                        },
                        subtitle: DiaryEntryWidget(
                            entry: entry,
                            onDelete: () async {
                              await diaryService
                                  .deleteEntry(entry)
                                  .then((value) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                        backgroundColor:
                                            Color.fromARGB(255, 68, 84, 122)
                                                .withOpacity(0.4),
                                        content: const Text(
                                          'Diary entry deleted',
                                          style: TextStyle(color: Colors.white),
                                        )));
                              });
                            }));
                  });
            }
          }),
        ),
        bottomSheet: Padding(
          padding: const EdgeInsets.all(15),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              FloatingActionButton.extended(
                foregroundColor: Colors.white,
                backgroundColor:
                    const Color.fromARGB(115, 65, 62, 62), //255, 87, 115, 138
                icon: const Icon(Icons.picture_as_pdf),
                label: const Text('Save as PDF'),
                onPressed: () async {
                  List<DiaryEntry> lst =
                      await diaryService.getUserEntriesList();
                  var pdfTheme = pw.ThemeData.withFont(
                      base: pw.Font.ttf(
                          await rootBundle.load('fonts/OpenSans-Regular.ttf')));
                  final pw.Document pdf = pw.Document(theme: pdfTheme);
                  final page = pw.Page(
                    pageFormat: PdfPageFormat.a4,
                    build: (pw.Context context) {
                      return pw.Column(children: [
                        pw.Text('''Year : ${lst[0].date.year} \n
                                Date : ${lst[0].date.day} ${lst[0].date.month} \n
                              ''', style: const pw.TextStyle(fontSize: 20)),
                        pw.Text('Rating : ${lst[0].rating}',
                            style: const pw.TextStyle(fontSize: 20)),
                        pw.Text(lst[0].desc,
                            style: const pw.TextStyle(fontSize: 20)),
                      ]);
                    },
                  );
                  pdf.addPage(page);
                  final output = await getTemporaryDirectory();
                  var path = "${output.path}/test_dear_diary.pdf";
                  final file = File(path);
                  await file.writeAsBytes(await pdf.save());
                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                      backgroundColor: const Color.fromARGB(115, 65, 62, 62),
                      content: Text(
                        'PDF saved at $path',
                        style: const TextStyle(color: Colors.white),
                      )));
                },
              ),
              SizedBox(width: MediaQuery.of(context).size.width - 250),
              FloatingActionButton(
                backgroundColor: const Color.fromARGB(115, 65, 62, 62),
                onPressed: () {
                  showDialog(
                      context: context,
                      builder: (context) => AddEditEntryView(
                            diaryService: diaryService,
                          ));
                },
                child: const Icon(
                  Icons.add_rounded,
                  size: 40,
                  color: Colors.green,
                ),
              ),
            ],
          ),
        ));
  }
}
