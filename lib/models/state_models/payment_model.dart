import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:grocery/helpers/project_configuration.dart';
import 'package:grocery/models/data_models/address.dart';
import 'package:grocery/models/data_models/cart_item.dart';
import 'package:grocery/models/state_models/checkout_model.dart';
import 'package:grocery/models/data_models/coupon.dart';
import 'package:grocery/services/auth.dart';
import 'package:grocery/services/cloud_functions.dart';
import 'package:grocery/services/database.dart';
import 'package:grocery/services/stripe_payment.dart';
import 'package:grocery/models/data_models/shipping_method.dart' as p;
import 'package:grocery/widgets/dialogs/error_dialog.dart';
import 'package:decimal/decimal.dart';

import 'package:provider/provider.dart';
import 'package:http/http.dart' as http;

class PaymentModel with ChangeNotifier {
  final Database database;
  final AuthBase auth;

  bool paymentViaDelivery = true;
  bool isLoading = false;

  PaymentModel({required this.database, required this.auth});

  void changePaymentMethod(value) {
    paymentViaDelivery = value;

    notifyListeners();
  }

  Future<void> submit(
    BuildContext context, {
    required Address address,
    required p.ShippingMethod shippingMethod,
    required List<CartItem> cartItems,
    required num order,
    Coupon? coupon,
  }) async {
    final checkoutModel = Provider.of<CheckoutModel>(context, listen: false);
    isLoading = true;
    notifyListeners();

    if (paymentViaDelivery) {
      await _submitOrder(context,
          address: address,
          shippingMethod: shippingMethod,
          cartItems: cartItems,
          coupon: coupon);
      isLoading = false;
      notifyListeners();
    } else {
      try {
        num total = checkoutModel.getDiscountedTotal();

        ///Payment process
        String paymentReference = await StripeService.payWithCard(context,
            ((Decimal.parse(total.toString())) * Decimal.parse('100'))
                .toString());


        print(paymentReference);
        await _submitOrder(context,
            address: address,
            shippingMethod: shippingMethod,
            cartItems: cartItems,
            paymentReference: paymentReference,
            coupon: coupon);
      } catch (e) {
        if (e is PlatformException) {
          ///Show error dialog if payment not successful
          if (e.message != 'cancelled') {
            showDialog(
                context: context,
                builder: (context) =>
                    ErrorDialog(message: e.message!));
          }
        }
      } finally {
        isLoading = false;
        notifyListeners();
      }
    }
  }

  ///Order submission on firebase
  Future _submitOrder(
    BuildContext context, {
    required Address address,
    required p.ShippingMethod shippingMethod,
    required List<CartItem> cartItems,
    String? paymentReference,
    Coupon? coupon,
  }) async {



    late bool result;

    if(ProjectConfiguration.useCloudFunctions){


      List<Map> cartItemsMap = cartItems.map((cartItem) {
        return {
          "id": cartItem.reference,
          "quantity": cartItem.quantity,
          "unit":cartItem.unit,
        };
      }).toList();

      final body = {
        "items": cartItemsMap,
        "shipping_method_id": shippingMethod.id,
        "shipping_address": {
          "name": address.name,
          "address": address.address,
          "city": address.city,
          "state": address.state,
          "country": address.country,
          "zip_code": address.zipCode,
          "phone": address.phone,
        },
      };

      if (paymentReference != null) {
        body["payment_id"] = paymentReference;
      }

      if (coupon != null) {
        body['coupon_id'] = coupon.code;
      }




      final cloudFunctions=Provider.of<CloudFunctions>(context,listen: false);


      result=await cloudFunctions.addOrder(body);

    }else{
      result=false;

      DateTime dateTime = DateTime.now();
      String id = dateTime.day.toString() +
          dateTime.hour.toString() +
          dateTime.minute.toString() +
          dateTime.microsecond.toString();
      final checkoutModel = Provider.of<CheckoutModel>(context, listen: false);

      num total = checkoutModel.getDiscountedTotal();

      List<Map> cartItemsMap = cartItems.map((cartItem) {
        return {
          "id": cartItem.reference,
          "title": cartItem.product!.title,
          "quantity": cartItem.quantity.toString() + " " + cartItem.unit,
          "price": (Decimal.parse(((cartItem.unit == 'Piece')
              ? cartItem.product!.pricePerPiece
              : (cartItem.unit == 'KG')
              ? cartItem.product!.pricePerKg
              : cartItem.product!.pricePerKg! * 0.001)
              .toString()) *
              Decimal.parse(cartItem.quantity.toString()))
              .toString(),
        };
      }).toList();

      Map<String, dynamic> data = {
        "date": dateTime.year.toString() +
            '-' +
            ((dateTime.month < 10)
                ? "0" + dateTime.month.toString()
                : dateTime.month.toString()) +
            '-' +
            ((dateTime.day < 10)
                ? "0" + dateTime.day.toString()
                : dateTime.day.toString()) +
            " " +
            ((dateTime.hour < 10)
                ? "0" + dateTime.hour.toString()
                : dateTime.hour.toString()) +
            ':' +
            ((dateTime.minute < 10)
                ? "0" + dateTime.minute.toString()
                : dateTime.minute.toString()),
        "products": cartItemsMap,
        "shipping_method": {
          "title": shippingMethod.title,
          "price": shippingMethod.price.toString(),
        },
        "payment_method": paymentReference==null ?"Cash in delivery" :"Credit card",
        "shipping_address": {
          "name": address.name,
          "address": address.address,
          "city": address.city,
          "state": address.state,
          "country": address.country,
          "zip_code": address.zipCode,
          "phone": address.phone,
        },
        "status": "Processing",
        "order": checkoutModel.getTotal().toString(),
        "total": total.toString(),
      };

      if (paymentReference != null) {
        data["payment_reference"] = paymentReference;
      }

      if (coupon != null) {
        data['coupon'] = {
          'code': coupon.code,
          'type': coupon.type,
          'expiry_date': coupon.expiryDate.toString().substring(0, 10),
          'value': coupon.value.toString()
        };
      }

      await database.setData(data, "users/${auth.uid}/orders/$id");

      await _sendNotification("Order nº$id is placed", id);

      result=true;


    }







    if(result == true){
      Navigator.pop(context, true);

   //   print(request.data is Map<String,dynamic>);
  //    return request.data;


    }else{
      showDialog(context: context, builder: (context)=>
          ErrorDialog(message: "Can't submit order, try again later"));

    }






  }

  ///Send notification to admin
  Future<void> _sendNotification(String msg, String id) async {
    String? token = await _getToken();

    if (token != null) {
      final body = {
        "message": msg,
        "title": "New order!",
        "token":token,
      };

      try {
        await http.post(Uri.parse(ProjectConfiguration.notificationsApi),
            body: json.encode(body));
      } catch (e) {
        print(e);
      }
    }
  }

  ///get admin fcm token
  Future<String?> _getToken() async {
    try {
      final snapshot =
      await database.getFutureDataFromDocument("admin/notifications");
      Map data = snapshot.data() as Map;

      return data['token'];
    } catch (e) {
      return null;
    }
  }
}


