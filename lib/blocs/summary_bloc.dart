import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:grocery/blocs/cart_bloc.dart';
import 'package:grocery/models/state_models/checkout_model.dart';
import 'package:grocery/models/data_models/coupon.dart';
import 'package:grocery/services/database.dart';
import 'package:provider/provider.dart';

class SummaryBloc {
  final CartBloc cartBloc;
  final Database database;

  bool validCode = true;
  String? message;

  ///Coupon stream
  // ignore: close_sinks
  StreamController<bool> couponController = StreamController<bool>.broadcast();

  Stream<bool> get couponStream => couponController.stream.asBroadcastStream();

  ///Coupon Price stream
  // ignore: close_sinks
  StreamController<bool> couponPriceController =
      StreamController<bool>.broadcast();

  Stream<bool> get couponPriceStream =>
      couponPriceController.stream.asBroadcastStream();

  ///Submit coupon
  Future<void> submitCoupon(BuildContext context, String code) async {
    final checkoutModel = Provider.of<CheckoutModel>(context, listen: false);

    couponController.add(true);

    if (code.replaceAll(" ", "").length == 0) {
      validCode = false;
      message = "Please enter a valid code";
      if (checkoutModel.coupon != null) {
        checkoutModel.coupon = null;
        couponPriceController.add(true);
      }
    } else {
      validCode = true;
    }

    if (validCode) {
      DocumentSnapshot document =
          await database.getFutureDataFromDocument("coupons/" + code);

      if (document.data() == null) {
        validCode = false;
        message = "This coupon code doesn\'t exist";

        if (checkoutModel.coupon != null) {
          checkoutModel.coupon = null;
          couponPriceController.add(true);
        }
      } else {
        Coupon coupon = Coupon.fromMap(
            document.data() as Map<String, dynamic>, document.id);
        DateTime dateTime =
            DateTime.parse(DateTime.now().toString().substring(0, 10));

        if (coupon.expiryDate.isAfter(dateTime) ||
            coupon.expiryDate.isAtSameMomentAs(dateTime)) {
          message = "Coupon successfully added";

          checkoutModel.coupon = coupon;
          couponPriceController.add(true);
        } else {
          validCode = false;
          message = "This coupon code is expired";
          if (checkoutModel.coupon != null) {
            checkoutModel.coupon = null;
            couponPriceController.add(true);
          }
        }
      }
    }

    couponController.add(false);
  }

  SummaryBloc({required this.cartBloc, required this.database});
}
