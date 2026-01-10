import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

class PeriodService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  //get user ID
  String? get userId => _auth.currentUser?.uid;

  Future<bool> savePeriodDate(DateTime data) async {
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

  String _dateToString(DateTime date) {
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
  }

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
}
