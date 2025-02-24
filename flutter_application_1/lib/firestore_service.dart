import 'package:cloud_firestore/cloud_firestore.dart';

class FirestoreService {
  final CollectionReference appointments = FirebaseFirestore.instance
      .collection('appointments');

  Future<void> addAppointment(Map<String, dynamic> data) {
    return appointments.add(data);
  }

  Future<void> updateAppointment(String id, Map<String, dynamic> data) {
    return appointments.doc(id).update(data);
  }

  Future<void> deleteAppointment(String id) {
    return appointments.doc(id).delete();
  }

  Stream<List<Map<String, dynamic>>> getAppointments() {
    return appointments.snapshots().map(
      (snapshot) =>
          snapshot.docs
              .map((doc) => doc.data() as Map<String, dynamic>)
              .toList(),
    );
  }
}
