import 'package:cloud_firestore/cloud_firestore.dart';

class FirestoreService {
  final CollectionReference appointments = FirebaseFirestore.instance
      .collection('appointments');
  final CollectionReference therapistsCollection = FirebaseFirestore.instance
      .collection('therapists');
  final CollectionReference childrenCollection = FirebaseFirestore.instance
      .collection('children');
      final CollectionReference parentsCollection = FirebaseFirestore.instance
      .collection('parents');

  Future<void> addAppointment(Map<String, dynamic> data) async {
    try {
      await appointments.add(data);
    } catch (e) {
      print("Error adding appointment: $e");
      throw e;
    }
  }

  Future<void> updateAppointment(
    String appointmentId,
    Map<String, dynamic> data,
  ) async {
    if (appointmentId.isEmpty) {
      print('Appointment ID is empty');
      return;
    }
    try {
      await appointments.doc(appointmentId).update(data);
    } catch (e) {
      print("Error updating appointment: $e");
      throw e;
    }
  }

  Future<DocumentSnapshot> getAppointment(String appointmentId) async {
    if (appointmentId.isEmpty) {
      print('Appointment ID is empty');
      throw Exception("Appointment ID is empty");
    }
    try {
      return await appointments.doc(appointmentId).get();
    } catch (e) {
      print("Error fetching appointment: $e");
      throw e;
    }
  }

  Future<void> deleteAppointment(String appointmentId) async {
    if (appointmentId.isEmpty) {
      print('Appointment ID is empty');
      return;
    }
    try {
      await appointments.doc(appointmentId).delete();
    } catch (e) {
      print("Error deleting appointment: $e");
      throw e;
    }
  }

  Stream<List<Map<String, dynamic>>> getAppointments() {
    return appointments.snapshots().map(
      (snapshot) =>
          snapshot.docs
              .map((doc) => doc.data() as Map<String, dynamic>)
              .toList(),
    );
  }

  Future<List<Map<String, dynamic>>> getTherapists() async {
    List<Map<String, dynamic>> therapists = [];
    try {
      QuerySnapshot snapshot = await therapistsCollection.get();
      for (var doc in snapshot.docs) {
        therapists.add(doc.data() as Map<String, dynamic>);
      }
    } catch (e) {
      print("Error fetching therapists: $e");
    }
    return therapists;
  }

  Future<Map<String, dynamic>> getTherapistData(String uid) async {
    if (uid.isEmpty) {
      print('UID is empty');
      throw Exception("UID is empty");
    }
    try {
      DocumentSnapshot doc = await therapistsCollection.doc(uid).get();
      if (doc.exists) {
        return doc.data() as Map<String, dynamic>;
      } else {
        throw Exception("Therapist not found");
      }
    } catch (e) {
      print("Error fetching therapist data: $e");
      throw e;
    }
  }

 Future<List<Map<String, dynamic>>> getchildren() async {
   List<Map<String, dynamic>> children = [];
    try {
      QuerySnapshot snapshot = await childrenCollection.get();
      for (var doc in snapshot.docs) {
        children.add(doc.data() as Map<String, dynamic>);
      }
    } catch (e) {
      print("Error fetching therapists: $e");
    }
    return children;
}
 Future<Map<String, dynamic>> getChildrenData(String childId) async {
    if (childId.isEmpty) {
      print('childId is empty');
      throw Exception("childId is empty");
    }
    try {
      DocumentSnapshot doc = await childrenCollection.doc(childId).get();
      if (doc.exists) {
        return doc.data() as Map<String, dynamic>;
      } else {
        throw Exception("children not found");
      }
    } catch (e) {
      print("Error fetching children data: $e");
      throw e;
    }
  }
}
