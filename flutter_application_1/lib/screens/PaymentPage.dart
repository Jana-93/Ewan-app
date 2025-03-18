import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class PaymentPage extends StatelessWidget {
  final String stripePaymentUrl = "https://buy.stripe.com/test_6oE7vW3Ub0Bwd6U5kl";

  Future<void> _launchStripePayment() async {
    if (await canLaunch(stripePaymentUrl)) {
      await launch(stripePaymentUrl);
    } else {
      throw "تعذر فتح الرابط: $stripePaymentUrl";
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("الدفع باستخدام Stripe"),
      ),
      body: Center(
        child: ElevatedButton(
          onPressed: _launchStripePayment,
          child: Text("انتقل إلى صفحة الدفع"),
        ),
      ),
    );
  }
}