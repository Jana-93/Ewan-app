import 'package:flutter/material.dart';
import 'package:flutter_application_1/screens/Stripe_payment/payment_manger.dart';

class PaymentPage extends StatelessWidget {
  final int amount;
  final String currency;

  PaymentPage({required this.amount, required this.currency});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("الدفع"),
      ),
      body: Center(
        child: ElevatedButton(
          onPressed: () async {
            try {
              await PaymentManager.makePayment(amount, currency);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text("تم الدفع بنجاح!")),
              );
            } catch (e) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text("فشل الدفع: $e")),
              );
            }
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.deepOrange,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          child: Text(
            "ادفع الآن",
            style: TextStyle(color: Colors.white),
          ),
        ),
      ),
    );
  }
}