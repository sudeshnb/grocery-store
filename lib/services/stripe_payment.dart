import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_stripe/flutter_stripe.dart';
import 'package:grocery/helpers/project_configuration.dart';
import 'package:grocery/services/auth.dart';
import 'package:grocery/services/cloud_functions.dart';
import 'package:provider/provider.dart';
import 'package:http/http.dart' as http;

class StripeService {
  static init() {
    Stripe.publishableKey = ProjectConfiguration.stripePublishableKey;
    Stripe.merchantIdentifier = ProjectConfiguration.stripeMerchantId;
    /*
    StripePayment.setOptions(StripeOptions(
      publishableKey: ProjectConfiguration.stripePublishableKey
      merchantId: ProjectConfiguration.stripeMerchantId,
    ));
    */
  }

  static Future<String> payWithCard(BuildContext context, String amount) async {
    init();

    Stripe stripe = Stripe.instance;

    ///Create payment intent
    var paymentIntent = await StripeService.createPaymentIntent(
      context,
      amount,
    );

    ///If successful
    if (paymentIntent != null) {
      try {
        await stripe.initPaymentSheet(
            paymentSheetParameters: SetupPaymentSheetParameters(
                merchantDisplayName: 'Flutter Stripe Store Demo',
                paymentIntentClientSecret: paymentIntent['client_secret']));

        await stripe.presentPaymentSheet();

        return paymentIntent['id'];
      } catch (_) {
        throw PlatformException(code: "0", message: "Transaction failed");
      }
    } else {
      ///If transaction fails
      throw PlatformException(code: "0", message: "Can't make payment");
    }
  }

  static Future<Map<String, dynamic>?> createPaymentIntent(
      BuildContext context, String amount) async {
    try {
      if (ProjectConfiguration.useCloudFunctions) {
        final cloudFunctions =
            Provider.of<CloudFunctions>(context, listen: false);
        return await cloudFunctions.createPayment(amount);
      } else {
        final auth = Provider.of<AuthBase>(context, listen: false);
        final token = await auth.token;
        final request =
            await http.post(Uri.parse(ProjectConfiguration.stripePaymentApi),
                headers: {
                  "Authorization": "Bearer " + token,
                },
                body: json.encode({
                  "amount": amount,
                  "uid": auth.uid,
                }));

        // print(request.body);

        if (request.statusCode == 200) {
          return json.decode(request.body);
        }
      }
    } catch (_) {
      // print(e);
    }
    return null;
  }
}
