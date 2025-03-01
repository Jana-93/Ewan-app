import 'package:dio/dio.dart';
import 'package:flutter_stripe/flutter_stripe.dart';
import 'package:flutter_application_1/screens/Stripe_payment/strip_keys.dart';

abstract class PaymentManager{

  static Future<void> makePayment(int amount, String currency) async {
  try {
    // تأكد أن المبلغ مضروب في 100 (لأن Stripe يقبل المبلغ بأصغر وحدة)
    String clientSecret = await _getClientSecret((amount * 100).toString(), currency);
    await _initializePaymentSheet(clientSecret);
    await Stripe.instance.presentPaymentSheet();
  } catch (error) {
    throw Exception("خطأ في الدفع: ${error.toString()}");
  }
}


  static Future<void>_initializePaymentSheet(String clientSecret)async{
    await Stripe.instance.initPaymentSheet(
      paymentSheetParameters: SetupPaymentSheetParameters(
        paymentIntentClientSecret: clientSecret,
        merchantDisplayName: "Basel",
      ),
    );
  }

 
static Future<String> _getClientSecret(String amount, String currency) async {
  Dio dio = Dio();

  try {
    var response = await dio.post(
      'https://api.stripe.com/v1/payment_intents',
      options: Options(
        headers: {
          'Authorization': 'Bearer ${ApiKeys.secretKey}',  // استخدم مفتاح سري حقيقي
          'Content-Type': 'application/x-www-form-urlencoded'
        },
      ),
      data: {
        'amount': amount,
        'currency': currency,
        'payment_method_types[]': 'card' // تأكد من تحديد نوع الدفع
      },
    );

    return response.data["client_secret"];
  } catch (error) {
    throw Exception("فشل الحصول على client_secret: ${error.toString()}");
  }
}

}