import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

// Firebase structure:
// users/{userId}/symptoms/{dateKey}/
// - symptoms: List<String>   e.g. ["Cramps", "Fatigue"]
// - notes: String
// - date: Timestamp
// - createdAt: Timestamp

class SymptomService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  String? get userId => _auth.currentUser?.uid;

  //Consistent date key: "YYYY-MM-DD"
  String _dateKey(DateTime date) =>
      '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';

  //save
  Future<bool> saveSymptoms({
    required List<String> symptoms,
    String notes = '',
    DateTime? date,
  }) async {
    try {
      if (userId == null) return false;

      final normalized = _normalize(date ?? DateTime.now());

      await _firestore
          .collection('users')
          .doc(userId)
          .collection('symptoms')
          .doc(_dateKey(normalized))
          .set({
        'symptoms': symptoms,
        'notes': notes,
        'date': Timestamp.fromDate(normalized),
        'createdAt': FieldValue.serverTimestamp(),
      });

      print('✅ Symptoms saved: $symptoms');
      return true;
    } catch (e) {
      print('❌ Error saving symptoms: $e');
      return false;
    }
  }

  //get for date
  Future<Map<String, dynamic>?> getSymptomsForDate(DateTime date) async {
    try {
      if (userId == null) return null;

      final doc = await _firestore
          .collection('users')
          .doc(userId)
          .collection('symptoms')
          .doc(_dateKey(_normalize(date)))
          .get();

      if (!doc.exists || doc.data() == null) return null;

      final data = doc.data()!;
      return {
        'symptoms': List<String>.from(data['symptoms'] ?? []),
        'notes': data['notes'] ?? '',
        'date': (data['date'] as Timestamp).toDate(),
      };
    } catch (e) {
      print('❌ Error getting symptoms for date: $e');
      return null;
    }
  }


  //delete
  Future<bool> deleteSymptoms(DateTime date) async {
    try {
      if (userId == null) return false;

      await _firestore
          .collection('users')
          .doc(userId)
          .collection('symptoms')
          .doc(_dateKey(_normalize(date)))
          .delete();

      print('✅ Symptoms deleted for ${_dateKey(date)}');
      return true;
    } catch (e) {
      print('❌ Error deleting symptoms: $e');
      return false;
    }
  }

  //helper
  DateTime _normalize(DateTime d) => DateTime(d.year, d.month, d.day);
}