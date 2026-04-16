import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class MoodService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Get current user ID
  String? get userId => _auth.currentUser?.uid;

  // SAVE MOOD ENTRY
  Future<bool> saveMood({
    required String moodName,
    required double intensity,
    String? notes,
    DateTime? date,
  }) async {
    try {
      if (userId == null) return false;

      // Use provided date or current date
      DateTime moodDate = date ?? DateTime.now();
      DateTime normalizedDate = DateTime(moodDate.year, moodDate.month, moodDate.day);

      // Create unique ID for the mood entry
      String moodId = '${normalizedDate.millisecondsSinceEpoch}';

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

      print('✅ Mood saved: $moodName with intensity ${(intensity * 100).toInt()}%');
      return true;
    } catch (e) {
      print('❌ Error saving mood: $e');
      return false;
    }
  }

  //GET MOOD FOR SPECIFIC DATE
  Future<Map<String, dynamic>?> getMoodForDate(DateTime date) async {
    try {
      if (userId == null) return null;

      DateTime normalizedDate = DateTime(date.year, date.month, date.day);
      String moodId = '${normalizedDate.millisecondsSinceEpoch}';

      DocumentSnapshot doc = await _firestore
          .collection('users')
          .doc(userId)
          .collection('moods')
          .doc(moodId)
          .get();

      if (doc.exists && doc.data() != null) {
        Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
        return {
          'moodName': data['moodName'],
          'intensity': data['intensity'],
          'notes': data['notes'] ?? '',
          'date': (data['date'] as Timestamp).toDate(),
        };
      }
      return null;
    } catch (e) {
      print('❌ Error getting mood for date: $e');
      return null;
    }
  }

  // GET MOOD HISTORY (last N days)
  Future<List<Map<String, dynamic>>> getMoodHistory({int days = 30}) async {
    try {
      if (userId == null) return [];

      DateTime startDate = DateTime.now().subtract(Duration(days: days));

      QuerySnapshot snapshot = await _firestore
          .collection('users')
          .doc(userId)
          .collection('moods')
          .where('date', isGreaterThanOrEqualTo: Timestamp.fromDate(startDate))
          .orderBy('date', descending: true)
          .get();

      List<Map<String, dynamic>> history = [];
      for (var doc in snapshot.docs) {
        Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
        history.add({
          'id': doc.id,
          'moodName': data['moodName'],
          'intensity': data['intensity'],
          'notes': data['notes'] ?? '',
          'date': (data['date'] as Timestamp).toDate(),
        });
      }

      print('✅ Loaded ${history.length} mood entries');
      return history;
    } catch (e) {
      print('❌ Error loading mood history: $e');
      return [];
    }
  }

  // GET MOOD STATISTICS (for a specific month)
  Future<Map<String, dynamic>> getMoodStats(DateTime month) async {
    try {
      if (userId == null) {
        return {'error': 'User not logged in'};
      }

      DateTime startOfMonth = DateTime(month.year, month.month, 1);
      DateTime endOfMonth = DateTime(month.year, month.month + 1, 0, 23, 59, 59);

      QuerySnapshot snapshot = await _firestore
          .collection('users')
          .doc(userId)
          .collection('moods')
          .where('date', isGreaterThanOrEqualTo: Timestamp.fromDate(startOfMonth))
          .where('date', isLessThanOrEqualTo: Timestamp.fromDate(endOfMonth))
          .get();

      if (snapshot.docs.isEmpty) {
        return {
          'totalEntries': 0,
          'averageIntensity': 0.0,
          'mostCommonMood': 'No data',
        };
      }

      // Calculate stats
      int totalEntries = snapshot.docs.length;
      double totalIntensity = 0;
      Map<String, int> moodCounts = {};

      for (var doc in snapshot.docs) {
        Map<String, dynamic> data = doc.data() as Map<String, dynamic>;

        totalIntensity += data['intensity'] as double;

        String mood = data['moodName'] as String;
        moodCounts[mood] = (moodCounts[mood] ?? 0) + 1;
      }

      double averageIntensity = totalIntensity / totalEntries;

      // Find most common mood
      String mostCommonMood = 'Neutral';
      int maxCount = 0;
      moodCounts.forEach((mood, count) {
        if (count > maxCount) {
          maxCount = count;
          mostCommonMood = mood;
        }
      });

      return {
        'totalEntries': totalEntries,
        'averageIntensity': averageIntensity,
        'mostCommonMood': mostCommonMood,
        'moodBreakdown': moodCounts,
      };
    } catch (e) {
      print('❌ Error calculating mood stats: $e');
      return {'error': e.toString()};
    }
  }

  // DELETE MOOD ENTRY
  Future<bool> deleteMood(DateTime date) async {
    try {
      if (userId == null) return false;

      DateTime normalizedDate = DateTime(date.year, date.month, date.day);
      String moodId = '${normalizedDate.millisecondsSinceEpoch}';

      await _firestore
          .collection('users')
          .doc(userId)
          .collection('moods')
          .doc(moodId)
          .delete();

      print('✅ Mood deleted for date: $date');
      return true;
    } catch (e) {
      print('❌ Error deleting mood: $e');
      return false;
    }
  }

  // GET WEEKLY MOOD DATA (for chart)
  Future<List<Map<String, dynamic>>> getWeeklyMoodData() async {
    try {
      if (userId == null) return [];

      // Get last 7 days
      DateTime today = DateTime.now();
      List<Map<String, dynamic>> weeklyData = [];

      for (int i = 6; i >= 0; i--) {
        DateTime day = today.subtract(Duration(days: i));
        DateTime normalizedDay = DateTime(day.year, day.month, day.day);

        Map<String, dynamic>? moodData = await getMoodForDate(normalizedDay);

        weeklyData.add({
          'date': normalizedDay,
          'dayName': _getDayName(normalizedDay.weekday),
          'moodName': moodData?['moodName'] ?? 'No data',
          'intensity': moodData?['intensity'] ?? 0.0,
        });
      }

      return weeklyData;
    } catch (e) {
      print('❌ Error getting weekly mood data: $e');
      return [];
    }
  }

  // UPDATE MOOD ENTRY
  Future<bool> updateMood({
    required DateTime date,
    String? moodName,
    double? intensity,
    String? notes,
  }) async {
    try {
      if (userId == null) return false;

      DateTime normalizedDate = DateTime(date.year, date.month, date.day);
      String moodId = '${normalizedDate.millisecondsSinceEpoch}';

      Map<String, dynamic> updates = {};
      if (moodName != null) updates['moodName'] = moodName;
      if (intensity != null) updates['intensity'] = intensity;
      if (notes != null) updates['notes'] = notes;

      if (updates.isEmpty) return false;

      await _firestore
          .collection('users')
          .doc(userId)
          .collection('moods')
          .doc(moodId)
          .update(updates);

      print('✅ Mood updated successfully');
      return true;
    } catch (e) {
      print('❌ Error updating mood: $e');
      return false;
    }
  }

  // Helper: Get day name from weekday number
  String _getDayName(int weekday) {
    const days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    return days[weekday - 1];
  }
}
