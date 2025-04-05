import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

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
    // Retrieve the current user's ID
    User? user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      throw Exception("User not logged in");
    }

    // Filter appointments by the current user's ID
    return appointments
        .where('userId', isEqualTo: user.uid) // Filter by user ID
        .snapshots()
        .map(
          (snapshot) =>
              snapshot.docs
                  .map((doc) => doc.data() as Map<String, dynamic>)
                  .toList(),
        );
  }

  Stream<List<Map<String, dynamic>>> getAppointmentsByTherapistId(
    String therapistId,
  ) {
    return appointments
        .where('therapistUid', isEqualTo: therapistId)
        .snapshots()
        .map(
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
        Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
        children.add({
          "childId": doc.id,
          "childName": data["childName"],
          "childAge": data["childAge"],
          "childStatus": data["childStatus"],
          "parentId": data["parentId"],
        });
      }
    } catch (e) {
      print("Error fetching children: $e");
    }
    return children;
  }

  Future<List<Map<String, dynamic>>> getChildrenForCurrentUser() async {
    User? user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      throw Exception("المستخدم غير مسجل دخول");
    }

    List<Map<String, dynamic>> children = [];
    try {
      QuerySnapshot snapshot =
          await childrenCollection.where("parentId", isEqualTo: user.uid).get();
      for (var doc in snapshot.docs) {
        Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
        children.add({
          "childId": doc.id,
          "childName": data["childName"],
          "childAge": data["childAge"],
          "childStatus": data["childStatus"],
          "parentId": data["parentId"],
        });
      }
    } catch (e) {
      print("Error fetching children for current user: $e");
      throw e;
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
        Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
        return {
          "childId": doc.id,
          "childName": data["childName"],
          "childAge": data["childAge"],
          "childStatus": data["childStatus"],
          "parentId": data["parentId"],
        };
      } else {
        throw Exception("Child not found");
      }
    } catch (e) {
      print("Error fetching child data: $e");
      throw e;
    }
  }

  Future<Map<String, dynamic>> getChildByName(String childName) async {
    if (childName.isEmpty) {
      print('childName is empty');
      throw Exception("childName is empty");
    }
    try {
      QuerySnapshot snapshot =
          await childrenCollection
              .where('childName', isEqualTo: childName)
              .get();
      if (snapshot.docs.isNotEmpty) {
        Map<String, dynamic> data =
            snapshot.docs.first.data() as Map<String, dynamic>;
        return {
          "childId": snapshot.docs.first.id,
          "childName": data["childName"],
          "childAge": data["childAge"],
          "childStatus": data["childStatus"],
          "parentId": data["parentId"],
        };
      } else {
        throw Exception("Child not found");
      }
    } catch (e) {
      print("Error fetching child data: $e");
      throw e;
    }
  }

  final CollectionReference children = FirebaseFirestore.instance.collection(
    'children',
  );

  // Method to fetch children by parent ID
  Future<List<Map<String, dynamic>>> getChildrenByParentId(
    String parentId,
  ) async {
    List<Map<String, dynamic>> children = [];
    try {
      // Query the Firestore collection using the correct reference
      QuerySnapshot snapshot =
          await childrenCollection.where("parentId", isEqualTo: parentId).get();

      // Iterate over the documents in the snapshot
      for (var doc in snapshot.docs) {
        Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
        children.add({
          "childName": data["childName"],
          "parentId": data["parentId"],
        });
      }
    } catch (e) {
      print("Error fetching children for parent ID: $e");
    }
    return children;
  }

  // دالة لإضافة تقييم وتحديث متوسط التقييمات
  Future<void> addRating(String uid, double rating) async {
    try {
      // إضافة التقييم الجديد
      await therapistsCollection.doc(uid).collection('ratings').add({
        'rating': rating,
        'timestamp': FieldValue.serverTimestamp(),
      });

      // حساب متوسط التقييمات
      QuerySnapshot ratingsSnapshot =
          await therapistsCollection.doc(uid).collection('ratings').get();

      double totalRating = 0.0;
      for (var doc in ratingsSnapshot.docs) {
        totalRating += doc['rating'];
      }

      double averageRating = totalRating / ratingsSnapshot.docs.length;

      // تحديث متوسط التقييم في وثيقة المعالج
      await therapistsCollection.doc(uid).update({
        'averageRating': averageRating,
      });
    } catch (e) {
      print("Error adding rating: $e");
      throw e;
    }
  }
}
