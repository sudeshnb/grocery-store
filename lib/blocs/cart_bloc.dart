import 'dart:async';

import 'package:grocery/models/data_models/cart_item.dart';
import 'package:grocery/models/data_models/product.dart';
import 'package:grocery/services/auth.dart';
import 'package:grocery/services/database.dart';
import 'package:rxdart/rxdart.dart';

class CartBloc {
  final Database database;
  final AuthBase auth;

  CartBloc({required this.database, required this.auth});

  ///Remove all cart items
  Future<void> removeCart() async {
    await database.removeCollection("users/${auth.uid}/cart");
  }

  ///Get products
  Stream<List<Product>> getProducts(List<CartItem> cartItems) {
    List<String> ids = cartItems.map((e) => e.reference).toList();

    return database.getDataWithArrayCondition('products', ids).map(
        (snapshots) => snapshots.docs
            .map((snapshot) => Product.fromMap(
                snapshot.data() as Map<String, dynamic>, snapshot.id))
            .toList());
  }

  // ignore: close_sinks
  late StreamController<List<CartItem>> cartItemsController = BehaviorSubject();

  Stream<List<CartItem>> get cartItems => cartItemsController.stream;

  ///Get cart items
  Stream<List<CartItem>> getCartItems() {
    return database
        .getDataFromCollection("users/${auth.uid}/cart")
        .map((snapshots) => snapshots.docs.map((snapshot) {
              return CartItem.fromMap(
                  snapshot.data() as Map<String, dynamic>, snapshot.id);
            }).toList());
  }

  ///Get products and cart item and check if cart item is in products using RxDart

  ///Remove cart item
  Future<void> removeFromCart(String reference) =>
      database.removeData("users/${auth.uid}/cart/$reference");

  ///Update cart item quantity
  Future updateQuantity(String reference, int quantity) async {
    database.updateData(
        {'quantity': quantity}, "users/${auth.uid}/cart/$reference");
  }

  ///Update cart item unit
  Future updateUnit(String reference, String unit) async {
    database.updateData({'unit': unit}, "users/${auth.uid}/cart/$reference");
  }

  ///Get total price
  num getTotal(List<CartItem> cartItems) {
    num sum = 0;
    for (var cartItem in cartItems) {
      sum += ((cartItem.unit == 'Piece')
              ? cartItem.product!.pricePerPiece
              : (cartItem.unit == 'KG')
                  ? cartItem.product!.pricePerKg!
                  : cartItem.product!.pricePerKg! * 0.001) *
          cartItem.quantity;
    }

    return sum;
  }
}
