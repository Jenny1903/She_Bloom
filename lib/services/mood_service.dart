import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class MoodService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  //add mood entry
  Future<void> addMood({
    required String mood,
    required double intensity,
    required DateTime date,
  }) async {
    final user = _auth.currentUser;

    if (user == null) throw Exception("User not logged in");

    await _db.collection('moods').add({
      'userId': user.uid,
      'mood': mood,
      'intensity': intensity,
      'date': Timestamp.fromDate(date),
      'createdAt': FieldValue.serverTimestamp(),
    });
  }

  //get user moods
  Stream<QuerySnapshot> getUserMoods() {
    final user = _auth.currentUser;

    if (user == null) {
      throw Exception("User not logged in");
    }

    return _db
        .collection('moods')
        .where('userId', isEqualTo: user.uid)
        .orderBy('date', descending: true)
        .snapshots();
  }
}