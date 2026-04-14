import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class MoodService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Get current user ID
  String? get userId => _auth.currentUser?.uid;

  //SAVE MOOD
  Future<bool> saveMood({
    required String moodName,
    required double intensity,
    String? notes,
    DateTime? date,
  }) async {
    try {
      if (userId == null) return false;

      final moodDate = date ?? DateTime.now();
      final normalizedDate = DateTime(moodDate.year, moodDate.month, moodDate.day);

      //Create unique ID using date
      String moodId = _dateToString(normalizedDate);

      await _firestore
          .collection('users')
          .doc(userId)
          .collection('moods')
          .doc(moodId)
          .set({
        'moodName': moodName,
        'intensity': intensity,
        'notes': notes ?? '',
        'date': Timestamp.fromDate(normalizedDate),
        'createdAt': FieldValue.serverTimestamp(),
      });

      print('Mood saved: $moodName at ${(intensity * 100).toInt()}%');
      return true;
    } catch (e) {
      print('Error saving mood: $e');
      return false;
    }
  }

  //GET MOOD FOR SPECIFIC DATE
  Future<Map<String, dynamic>?> getMoodForDate(DateTime date) async {
    try {
      if (userId == null) return null;

      final normalizedDate = DateTime(date.year, date.month, date.day);
      String moodId = _dateToString(normalizedDate);

      DocumentSnapshot doc = await _firestore
          .collection('users')
          .doc(userId)
          .collection('moods')
          .doc(moodId)
          .get();

      if (doc.exists) {
        return doc.data() as Map<String, dynamic>?;
      }
      return null;
    } catch (e) {
      print('Error getting mood: $e');
      return null;
    }
  }

  //GET MOODS FOR SPECIFIC MONTH
  Future<Map<String, Map<String, dynamic>>> getMoodsForMonth(DateTime month) async {
    try {
      if (userId == null) return {};

      DateTime startOfMonth = DateTime(month.year, month.month, 1);
      DateTime endOfMonth = DateTime(month.year, month.month + 1, 0, 23, 59, 59);

      QuerySnapshot snapshot = await _firestore
          .collection('users')
          .doc(userId)
          .collection('moods')
          .where('date', isGreaterThanOrEqualTo: Timestamp.fromDate(startOfMonth))
          .where('date', isLessThanOrEqualTo: Timestamp.fromDate(endOfMonth))
          .get();

      Map<String, Map<String, dynamic>> moods = {};

      for (var doc in snapshot.docs) {
        Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
        Timestamp timestamp = data['date'] as Timestamp;
        DateTime date = timestamp.toDate();
        String dateKey = _dateToString(date);

        moods[dateKey] = {
          'moodName': data['moodName'],
          'intensity': data['intensity'],
          'notes': data['notes'],
          'date': date,
        };
      }

      print('Loaded ${moods.length} moods for ${month.month}/${month.year}');
      return moods;
    } catch (e) {
      print('Error loading monthly moods: $e');
      return {};
    }
  }

  //GET MOOD HISTORY (Last N days)
  Future<List<Map<String, dynamic>>> getMoodHistory({int days = 30}) async {
    try {
      if (userId == null) return [];

      DateTime startDate = DateTime.now().subtract(Duration(days: days));
      DateTime normalizedStart = DateTime(startDate.year, startDate.month, startDate.day);

      QuerySnapshot snapshot = await _firestore
          .collection('users')
          .doc(userId)
          .collection('moods')
          .where('date', isGreaterThanOrEqualTo: Timestamp.fromDate(normalizedStart))
          .orderBy('date', descending: true)
          .get();

      List<Map<String, dynamic>> history = [];

      for (var doc in snapshot.docs) {
        Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
        Timestamp timestamp = data['date'] as Timestamp;

        history.add({
          'id': doc.id,
          'moodName': data['moodName'],
          'intensity': data['intensity'],
          'notes': data['notes'],
          'date': timestamp.toDate(),
        });
      }

      print('Loaded ${history.length} moods from last $days days');
      return history;
    } catch (e) {
      print('Error loading mood history: $e');
      return [];
    }
  }

  //GET MOOD STATISTICS
  Future<Map<String, dynamic>> getMoodStatistics({int days = 7}) async {
    try {
      List<Map<String, dynamic>> history = await getMoodHistory(days: days);

      if (history.isEmpty) {
        return {
          'totalEntries': 0,
          'averageIntensity': 0.0,
          'mostCommonMood': null,
          'moodCounts': {},
        };
      }

      //Calculate statistics
      double totalIntensity = 0;
      Map<String, int> moodCounts = {};

      for (var entry in history) {
        totalIntensity += (entry['intensity'] as double);
        String mood = entry['moodName'] as String;
        moodCounts[mood] = (moodCounts[mood] ?? 0) + 1;
      }

      //Find most common mood
      String? mostCommon;
      int maxCount = 0;
      moodCounts.forEach((mood, count) {
        if (count > maxCount) {
          maxCount = count;
          mostCommon = mood;
        }
      });

      return {
        'totalEntries': history.length,
        'averageIntensity': totalIntensity / history.length,
        'mostCommonMood': mostCommon,
        'moodCounts': moodCounts,
      };
    } catch (e) {
      print('Error calculating statistics: $e');
      return {
        'totalEntries': 0,
        'averageIntensity': 0.0,
        'mostCommonMood': null,
        'moodCounts': {},
      };
    }
  }

  // 🗑️ DELETE MOOD
  Future<bool> deleteMood(DateTime date) async {
    try {
      if (userId == null) return false;

      final normalizedDate = DateTime(date.year, date.month, date.day);
      String moodId = _dateToString(normalizedDate);

      await _firestore
          .collection('users')
          .doc(userId)
          .collection('moods')
          .doc(moodId)
          .delete();

      print('Mood deleted for $moodId');
      return true;
    } catch (e) {
      print('Error deleting mood: $e');
      return false;
    }
  }

  //UPDATE MOOD
  Future<bool> updateMood({
    required DateTime date,
    String? moodName,
    double? intensity,
    String? notes,
  }) async {
    try {
      if (userId == null) return false;

      final normalizedDate = DateTime(date.year, date.month, date.day);
      String moodId = _dateToString(normalizedDate);

      Map<String, dynamic> updates = {};
      if (moodName != null) updates['moodName'] = moodName;
      if (intensity != null) updates['intensity'] = intensity;
      if (notes != null) updates['notes'] = notes;
      updates['updatedAt'] = FieldValue.serverTimestamp();

      await _firestore
          .collection('users')
          .doc(userId)
          .collection('moods')
          .doc(moodId)
          .update(updates);

      print('Mood updated for $moodId');
      return true;
    } catch (e) {
      print('Error updating mood: $e');
      return false;
    }
  }

  //Convert date to string key
  String _dateToString(DateTime date) {
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
  }
}
