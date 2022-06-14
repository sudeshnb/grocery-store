import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:grocery/models/data_models/unit.dart';
import 'package:grocery/services/database.dart';

class ProductDetailsBloc {
  final Database database;
  final String uid;

  ProductDetailsBloc(
      {required this.database, required this.uid, required this.unit});

  int quantity = 1;
  Unit unit;

  ///Add item to cart
  Future<void> addToCart(String reference) => database.setData({
        'quantity': quantity,
        "unit": unit.title,
      }, "users/$uid/cart/$reference");

  ///Remove item from cart
  Future<void> removeFromCart(String reference) =>
      database.removeData("users/$uid/cart/$reference");

  ///Get cart items id
  Stream<DocumentSnapshot> getCartItem(String reference) {
    // ignore: close_sinks

    return database.getDataFromDocument("users/$uid/cart/$reference");
  }
}
