import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class MoodService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  String get _uid {
    final user = _auth.currentUser;
    if (user == null) throw Exception("User not logged in");
    return user.uid;
  }

//add or update mood

  Future<void> saveMood({
    required String mood,
    required double intensity,
    required DateTime date,
  }) async {
    final startOfDay = DateTime(date.year, date.month, date.day);
    final endOfDay = startOfDay.add(const Duration(days: 1));

    final existing = await _db
        .collection('moods')
        .where('userId', isEqualTo: _uid)
        .where('date', isGreaterThanOrEqualTo: startOfDay)
        .where('date', isLessThan: endOfDay)
        .get();

    if (existing.docs.isNotEmpty) {
      //update existing mood
      await existing.docs.first.reference.update({
        'mood': mood,
        'intensity': intensity,
        'updatedAt': FieldValue.serverTimestamp(),
      });
    } else {
      // ➕ CREATE new mood
      await _db.collection('moods').add({
        'userId': _uid,
        'mood': mood,
        'intensity': intensity,
        'date': Timestamp.fromDate(date),
        'createdAt': FieldValue.serverTimestamp(),
      });
    }
  }

  //delete mood
  Future<void> deleteMood(String docId) async {
    await _db.collection('moods').doc(docId).delete();
  }

  //get all moods by date range
  Stream<QuerySnapshot> getMoodsByRange(DateTime start, DateTime end) {
    return _db
        .collection('moods')
        .where('userId', isEqualTo: _uid)
        .where('date', isGreaterThanOrEqualTo: start)
        .where('date', isLessThanOrEqualTo: end)
        .orderBy('date')
        .snapshots();
  }

  //weekly mood data
  Future<List<Map<String, dynamic>>> getWeeklyMoods() async {
    final now = DateTime.now();
    final weekAgo = now.subtract(const Duration(days: 7));

    final snapshot = await _db
        .collection('moods')
        .where('userId', isEqualTo: _uid)
        .where('date', isGreaterThanOrEqualTo: weekAgo)
        .orderBy('date')
        .get();

    return snapshot.docs.map((doc) {
      final data = doc.data();
      return {
        'mood': data['mood'],
        'intensity': data['intensity'],
        'date': (data['date'] as Timestamp).toDate(),
      };
    }).toList();
  }
}