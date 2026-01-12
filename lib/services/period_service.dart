import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class PeriodService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  //get user ID
  String? get userId => _auth.currentUser?.uid;


  //to save period date
  Future<bool> savePeriodDate(DateTime date) async {
    try {
      if (userId == null) return false;

      //to normalize date(removing time)
      DateTime normalizedDate = DateTime(date.year, date.month, date.day);
      String dateKey = _dateToString(normalizedDate);

      await _firestore
          .collection('users')
          .doc(userId)
          .collection('periodDates')
          .doc(dateKey)
          .set({
            'date': Timestamp.fromDate(normalizedDate),
            'createdAt': FieldValue.serverTimestamp(),
          });
      print('✅ Period date saved: $dateKey');
      return true;
    } catch (e) {
      print('❌ Error saving period date: $e');
      return false;
    }
  }

  //remove period date
  Future<bool> removePeriodDate(DateTime date) async {
    try {
      if (userId == null) return false;

      DateTime normalizedDate = DateTime(date.year, date.month, date.day);
      String dateKey = _dateToString(normalizedDate);

      await _firestore
          .collection('users')
          .doc(userId)
          .collection('periodDates')
          .doc(dateKey)
          .delete();

      print('✅ Period date removed: $dateKey');
      return true;
    } catch (e) {
      print('❌ Error removing period date: $e');
      return false;
    }
  }

  //load all period dates for user
  Future<Set<DateTime>> loadPeriodDates() async {
    try {
      if (userId == null) return {};

      QuerySnapshot snapshot = await _firestore
          .collection('users')
          .doc(userId)
          .collection('periodDates')
          .get();

      Set<DateTime> dates = {};
      for (var doc in snapshot.docs) {
        Timestamp timestamp = doc['date'] as Timestamp;
        DateTime date = timestamp.toDate();
        dates.add(DateTime(date.year, date.month, date.day));
      }
      print('✅ Loaded ${dates.length} period dates');
      return dates;
    } catch (e) {
      print('❌ Error loading period dates: $e');
      return {};
    }
  }

  //load period dates for specific month
  Future<Set<DateTime>> loadPeriodDatesForMonth(DateTime month) async {
    try{
      if(userId == null) return {};

      DateTime startOfMonth = DateTime(month.year, month.month, 1);
      DateTime endOfMonth = DateTime(month.year, month.month + 1, 0, 23, 59, 59);

      QuerySnapshot snapshot = await _firestore
          .collection('users')
          .doc(userId)
          .collection('periodDates')
          .where('date', isGreaterThanOrEqualTo: Timestamp.fromDate(startOfMonth))
          .where('date', isLessThanOrEqualTo: Timestamp.fromDate(endOfMonth))
          .get();

      Set<DateTime> dates = {};
      for (var doc in snapshot.docs) {
        Timestamp timestamp = doc['date'] as Timestamp;
        DateTime date = timestamp.toDate();
        dates.add(DateTime(date.year, date.month, date.day));
      }

      return dates;
    } catch (e) {
      print('❌ Error loading month dates: $e');
      return {};
    }
  }

  //SAVE cycle settings
  Future<bool> saveCycleSettings({
    required int cycleLength,
    required int periodLength,
  }) async {
    try {
      if (userId == null) return false;

      await _firestore.collection('users').doc(userId).set({
        'cycleLength': cycleLength,
        'periodLength': periodLength,
        'updatedAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));

      print('✅ Cycle settings saved');
      return true;
    } catch (e) {
      print('❌ Error saving cycle settings: $e');
      return false;
    }
  }

  //LOAD cycle settings
  Future<Map<String, int>?> loadCycleSettings() async {
    try {
      if (userId == null) return null;

      DocumentSnapshot doc = await _firestore
          .collection('users')
          .doc(userId)
          .get();
      if (doc.exists && doc.data() != null) {
        Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
        return {
          'cycleLength': data['cycleLength'] ?? 28,
          'periodLength': data['periodLength'] ?? 5,
        };
      }
      return {'cycleLength': 28, 'periodLength': 5};
    } catch (e) {
      print('❌ Error loading cycle settings: $e');
      return {'cycleLength': 28, 'periodLength': 5};
    }
  }

  //to convert datetime to string key
  String _dateToString(DateTime date) {
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
  }
  //get last period start date
  Future<DateTime?> getLastPeriodStart() async{
    try{
      if(userId == null) return null;

      QuerySnapshot snapshot = await _firestore
          .collection('users')
          .doc(userId)
          .collection('periodDates')
          .orderBy('date', descending: true)
          .limit(1)
          .get();

      if (snapshot.docs.isEmpty) return null;
      Timestamp timestamp = snapshot.docs.first['date'] as Timestamp;
      return timestamp.toDate();
    }catch (e) {
      print('❌ Error getting last period: $e');
      return null;
  }
  }

  //get period history(last 6 months)
  Future<List<Map<String, dynamic>>> getPeriodHistory() async {
    try {
      if (userId == null) return [];

      DateTime sixMonthsAgo = DateTime.now().subtract(
        const Duration(days: 180),
      );

      QuerySnapshot snapshot = await _firestore
          .collection('users')
          .doc(userId)
          .collection('periodDates')
          .where(
        'date',
        isGreaterThanOrEqualTo: Timestamp.fromDate(sixMonthsAgo),
      )
          .orderBy('date', descending: true)
          .get();

      List<Map<String, dynamic>> history = [];
      for (var doc in snapshot.docs) {
        Timestamp timestamp = doc['date'] as Timestamp;
        history.add({'date': timestamp.toDate(), 'id': doc.id});
      }

      return history;
    } catch (e) {
      print('❌ Error getting history: $e');
      return [];
    }
  }

}
