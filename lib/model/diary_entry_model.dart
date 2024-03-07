import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:image_picker/image_picker.dart';

class DiaryEntry {
  final String? id;
  final DateTime date;
  final String desc;
  final int rating;
  String? image;

  DiaryEntry({
    this.id,
    required this.date,
    required this.desc,
    required this.rating,
    this.image,
  });

  Map<String, dynamic> toMap() {
    return {
      'date': date,
      'desc': desc,
      'rating': rating,
      'image': image,
    };
  }

  static DiaryEntry fromMap(DocumentSnapshot doc) {
    Map<String, dynamic> map = doc.data() as Map<String, dynamic>;
    return DiaryEntry(
      id: doc.id,
      date: DateTime.parse(map['date'].toDate().toString()) ?? DateTime.now(),
      desc: map['desc'] ?? '',
      rating: map['rating'] ?? 3,
      image: map['image'] ?? '',
    );
  }
}
