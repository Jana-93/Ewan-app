import 'package:flutter/material.dart';
import 'package:flutter_application_1/screens/Stripe_payment/payment_manger.dart';
import 'package:flutter_stripe/flutter_stripe.dart';
import 'package:cloud_firestore/cloud_firestore.dart'; // استيراد Firestore
import 'package:flutter_application_1/screens/appointmentpage.dart'; // استيراد Appointmentpage

class PaymentPage extends StatelessWidget {
  final int amount;
  final String currency;
  final Map<String, dynamic> appointmentData; // بيانات الحجز

  PaymentPage({
    required this.amount,
    required this.currency,
    required this.appointmentData, // بيانات الحجز
  });

  @override
  Widget build(BuildContext context) {
    // متغيرات لإدارة حالة الحقول
    final cardNumberController = TextEditingController();
    final expiryDateController = TextEditingController();
    final cvcController = TextEditingController();

    // خدمة Firestore
    final firestoreService = FirestoreService();

    return Scaffold(
      appBar: AppBar(
        title: Text("الدفع"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "أدخل معلومات الدفع",
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 20),

            // حقل رقم البطاقة
            TextFormField(
              controller: cardNumberController,
              decoration: InputDecoration(
                labelText: "رقم البطاقة",
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.credit_card),
              ),
              keyboardType: TextInputType.number,
              maxLength: 16, 
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return "يرجى إدخال رقم البطاقة";
                }
                if (value.length != 16) {
                  return "رقم البطاقة يجب أن يتكون من 16 رقمًا";
                }
                return null;
              },
            ),
            SizedBox(height: 20),

            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    controller: expiryDateController,
                    decoration: InputDecoration(
                      labelText: "تاريخ الانتهاء (MM/YY)",
                      border: OutlineInputBorder(),
                      prefixIcon: IconButton(
                        icon: Icon(Icons.calendar_today),
                        onPressed: () async {
                          final DateTime? pickedDate = await showDatePicker(
                            context: context,
                            initialDate: DateTime.now(),
                            firstDate: DateTime.now(),
                            lastDate: DateTime(DateTime.now().year + 10),
                          );
                          if (pickedDate != null) {
                            expiryDateController.text =
                                "${pickedDate.month.toString().padLeft(2, '0')}/${pickedDate.year.toString().substring(2)}";
                          }
                        },
                      ),
                    ),
                    keyboardType: TextInputType.datetime,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return "يرجى إدخال تاريخ الانتهاء";
                      }
                      if (!RegExp(r'^\d{2}/\d{2}$').hasMatch(value)) {
                        return "تاريخ الانتهاء غير صحيح";
                      }
                      return null;
                    },
                  ),
                ),
                SizedBox(width: 10),

                // حقل رمز الأمان (CVC)
                Expanded(
                  child: TextFormField(
                    controller: cvcController,
                    decoration: InputDecoration(
                      labelText: "رمز الأمان (CVC)",
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.lock),
                    ),
                    keyboardType: TextInputType.number,
                    maxLength: 3, 
                    obscureText: true, 
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return "يرجى إدخال رمز الأمان";
                      }
                      if (value.length != 3) {
                        return "رمز الأمان يجب أن يتكون من 3 أرقام";
                      }
                      return null;
                    },
                  ),
                ),
              ],
            ),
            SizedBox(height: 20),

            ElevatedButton(
              onPressed: () async {
                if (cardNumberController.text.length != 16) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text("رقم البطاقة يجب أن يتكون من 16 رقمًا")),
                  );
                  return;
                }
                if (!RegExp(r'^\d{2}/\d{2}$').hasMatch(expiryDateController.text)) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text("تاريخ الانتهاء غير صحيح")),
                  );
                  return;
                }
                if (cvcController.text.length != 3) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text("رمز الأمان يجب أن يتكون من 3 أرقام")),
                  );
                  return;
                }

                try {
                  await PaymentManager.makePayment(amount, currency);

                  await firestoreService.addAppointment(appointmentData);

                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                      builder: (context) => Appointmentpage(),
                    ),
                  );

                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text("تم الدفع بنجاح!")),
                  );
                } catch (e) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text("فشل الدفع: ${e.toString()}")),
                  );
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.deepOrange,
                minimumSize: Size(double.infinity, 50),
              ),
              child: Text(
                "ادفع الآن",
                style: TextStyle(color: Colors.white, fontSize: 18),
              ),
            ),
          ],
        ),
      ),
    );
  }
}


class FirestoreService {
  final CollectionReference appointments =
      FirebaseFirestore.instance.collection('appointments');

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
          (snapshot) => snapshot.docs
              .map((doc) => doc.data() as Map<String, dynamic>)
              .toList(),
        );
  }
}