import 'dart:io';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:firebase_ui_auth/firebase_ui_auth.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../controller/diary_entry_service.dart';
import '../model/diary_entry_model.dart';

class AddEditEntryView extends StatefulWidget {
  final bool editing;
  final DiaryEntry? entry;
  final DiaryService diaryService;
  AddEditEntryView(
      {Key? key, required this.diaryService, this.editing = false, this.entry})
      : super(key: key);

  @override
  State<AddEditEntryView> createState() => AddEditEntryViewState();
}

class AddEditEntryViewState extends State<AddEditEntryView> {
  final formKey = GlobalKey<FormState>();
  final DiaryService diaryService = DiaryService();
  String desc = '';
  int rating = 3;
  DateTime selectedDate =
      DateTime(DateTime.now().year, DateTime.now().month, DateTime.now().day);
  final ImagePicker picker = ImagePicker();
  XFile? selectedImage;
  String? imageLink;

  Future<void> selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: selectedDate,
      firstDate: DateTime(2000),
      lastDate: DateTime.now(),
    );
    if (picked != null && picked != selectedDate) {
      setState(() {
        selectedDate = picked;
      });
    }
  }

  Future<void> pickImageFromGallery() async {
    final XFile? chosen = await picker.pickImage(source: ImageSource.gallery);
    setState(() {
      selectedImage = chosen;
    });
    print(selectedImage);
  }

  Future<void> pickImageFromCamera() async {
    final XFile? chosen = await picker.pickImage(source: ImageSource.camera);
    setState(() {
      selectedImage = chosen;
    });
  }

  Future<void> saveNewEntry() async {
    if (formKey.currentState!.validate()) {
      formKey.currentState!.save();
    }
    if (widget.editing == false) {
      if (selectedImage != null) {
        imageLink = await diaryService.uploadImageToFirebase(selectedImage);
      }
      final newEntry = DiaryEntry(
          date: selectedDate, desc: desc, rating: rating, image: imageLink);
      await diaryService.addNewEntry(newEntry).then((value) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
            backgroundColor: Color.fromARGB(255, 98, 119, 73),
            content: Text(
              'New diary entry added',
              style: TextStyle(color: Colors.white),
            )));
      }).catchError((err) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            backgroundColor: Color.fromARGB(82, 169, 209, 246),
            content: Text(err.toString(),
                style: const TextStyle(color: Colors.white))));
      });
    } else if (widget.editing == true) {
      if (widget.entry!.image != null) {
        imageLink = widget.entry!.image;
      }
      if (selectedImage != null) {
        imageLink = await diaryService.uploadImageToFirebase(selectedImage);
      }
      final updatedEntry = DiaryEntry(
          date: selectedDate, desc: desc, rating: rating, image: imageLink);
      await diaryService
          .updateEntry(widget.entry!.id!, updatedEntry)
          .then((value) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
            backgroundColor: Color.fromARGB(255, 98, 119, 73),
            content: Text(
              'Diary entry updated',
              style: TextStyle(color: Colors.white),
            )));
      }).catchError((err) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            backgroundColor: Color.fromARGB(82, 169, 209, 246),
            content: Text(
              err.toString(),
              style: const TextStyle(color: Colors.white),
            )));
      });
    }
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: widget.editing == false
          ? const Text('Add Diary Entry')
          : const Text('Edit Diary Entry'),
      content: Form(
        key: formKey,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                initialValue: widget.editing ? widget.entry!.desc : '',
                maxLength: 140,
                maxLines: 4,
                keyboardType: TextInputType.multiline,
                decoration: const InputDecoration(
                  labelText: 'Description',
                  hintText: 'Describe your day!',
                ),
                validator: (input) {
                  if (input == null || input.isEmpty) {
                    return 'Description cannot be empty';
                  }
                  return null;
                },
                onSaved: (input) {
                  desc = input!;
                },
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: kIsWeb
                    ? MediaQuery.of(context).size.width / 2
                    : MediaQuery.of(context).size.width,
                child: Row(
                  children: [
                    const Text('Rate your day:'),
                    Flexible(
                        child: Slider(
                            value: widget.editing
                                ? widget.entry!.rating.toDouble()
                                : rating.toDouble(),
                            min: 1,
                            max: 5,
                            divisions: 4,
                            onChanged: (double value) {
                              setState(() {
                                rating = value.toInt();
                              });
                            })),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              Row(
                children: [
                  Text(
                      "Date: ${selectedDate.toLocal().toString().split(' ')[0]}"),
                  IconButton(
                    icon: const Icon(Icons.calendar_today),
                    onPressed: () => selectDate(context),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  IconButton(
                    iconSize: 40,
                    color: Color.fromARGB(238, 70, 135, 247),
                    onPressed: pickImageFromGallery,
                    icon: const Icon(Icons.photo),
                    highlightColor: Color.fromARGB(255, 97, 106, 116),
                    tooltip: 'Pick Image from Gallery',
                  ),
                  SizedBox(width: MediaQuery.of(context).size.width / 10),
                  IconButton(
                    iconSize: 40,
                    color: Color.fromARGB(172, 116, 197, 229),
                    onPressed: pickImageFromCamera,
                    icon: const Icon(Icons.camera_alt),
                    highlightColor: Color.fromARGB(255, 97, 106, 116),
                    tooltip: 'Capture Image from Camera',
                  ),
                  SizedBox(width: MediaQuery.of(context).size.width / 10),
                  IconButton(
                    iconSize: 40,
                    color: Color.fromARGB(172, 218, 81, 95),
                    onPressed: () {
                      selectedImage = null;
                      widget.entry!.image = null;
                    },
                    icon: const Icon(Icons.hide_image_outlined),
                    highlightColor: Color.fromARGB(255, 97, 106, 116),
                    tooltip: 'Delete Image from Entry',
                  )
                ],
              ),
              const SizedBox(height: 10),
              if (selectedImage != null)
                Container(
                  margin: EdgeInsets.all(20),
                  height: 200,
                  width: 200,
                  child: Image.file(File(selectedImage!.path)),
                ),
              const SizedBox(
                height: 10,
              ),
              IconButton(
                  onPressed: saveNewEntry,
                  iconSize: 40,
                  hoverColor: const Color.fromARGB(255, 93, 136, 94),
                  icon: const Icon(Icons.check_rounded))
            ],
          ),
        ),
      ),
    );
  }
}
