import 'package:cloud_firestore/cloud_firestore.dart';

class FirestoreService {
  final CollectionReference appointments = FirebaseFirestore.instance
      .collection('appointments');

  Future<String> addAppointment(Map<String, dynamic> data) async {
    DocumentReference docRef = await appointments.add(data);
    return docRef.id;
  }

  Future<void> updateAppointment(
    String appointmentId,
    Map<String, dynamic> data,
  ) async {
    await appointments.doc(appointmentId).update(data);
  }

  Future<DocumentSnapshot> getAppointment(String appointmentId) async {
    return await appointments.doc(appointmentId).get();
  }

  Future<void> deleteAppointment(String appointmentId) async {
    await appointments.doc(appointmentId).delete();
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
