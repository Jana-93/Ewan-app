import 'package:flutter/material.dart';
import 'package:flutter_application_1/screens/Stripe_payment/payment_manger.dart';
import 'package:flutter_stripe/flutter_stripe.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_application_1/screens/appointmentpage.dart';

class PaymentPage extends StatelessWidget {
  final int amount;
  final String currency;
  final Map<String, dynamic> appointmentData;
  final VoidCallback onPaymentSuccess;

  PaymentPage({
    required this.amount,
    required this.currency,
    required this.appointmentData,
    required this.onPaymentSuccess,
  });

  @override
  Widget build(BuildContext context) {
    final cardNumberController = TextEditingController();
    final expiryDateController = TextEditingController();
    final cvcController = TextEditingController();

    return Scaffold(
      appBar: AppBar(title: Text("الدفع")),
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

            // حقل إدخال رقم البطاقة
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

            // حقل إدخال تاريخ الانتهاء ورمز الأمان
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

            // زر الدفع
            ElevatedButton(
              onPressed: () async {
                // التحقق من صحة البيانات
                if (cardNumberController.text.length != 16) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text("رقم البطاقة يجب أن يتكون من 16 رقمًا"),
                    ),
                  );
                  return;
                }
                if (!RegExp(
                  r'^\d{2}/\d{2}$',
                ).hasMatch(expiryDateController.text)) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text("تاريخ الانتهاء غير صحيح")),
                  );
                  return;
                }
                if (cvcController.text.length != 3) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text("رمز الأمان يجب أن يتكون من 3 أرقام"),
                    ),
                  );
                  return;
                }

                try {
                  //await PaymentManager.makePayment(amount, currency);

                  // إضافة الموعد إلى Firestore
                  await FirebaseFirestore.instance
                      .collection('appointments')
                      .add(appointmentData);

                  // إظهار رسالة نجاح
                  ScaffoldMessenger.of(
                    context,
                  ).showSnackBar(SnackBar(content: Text("تم الدفع بنجاح!")));

                  // الانتقال إلى صفحة المواعيد
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(builder: (context) => Appointmentpage()),
                  );
                } catch (e) {
                  // إظهار رسالة خطأ
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
