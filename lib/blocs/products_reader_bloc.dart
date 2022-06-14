import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:grocery/models/data_models/product.dart';
import 'package:grocery/services/auth.dart';
import 'package:grocery/services/database.dart';
import 'package:rxdart/rxdart.dart';

class ProductsReaderBloc {
  final Database database;
  final String category;

  final AuthBase auth;

  ProductsReaderBloc(
      {required this.database, required this.category, required this.auth});

  // ignore: close_sinks
  StreamController<List<Product>> productsController = BehaviorSubject();

  Stream<List<Product>> get productsStream => productsController.stream;

  bool _canLoadMore = true;

  List<DocumentSnapshot> _lastDocuments = [];

  List<Product> savedProducts = [];

  Future<void> loadProducts(int length) async {
    if (_canLoadMore) {
      _canLoadMore = false;

      List<Product> newProducts = (await _getCategoryProducts(length))
          .map((e) => Product.fromMap(e.data() as Map<String, dynamic>, e.id))
          .toList();

      savedProducts.addAll(newProducts);

      productsController.add(savedProducts.toSet().toList());

      if (newProducts.length < length) {
        _canLoadMore = false;
      } else {
        _canLoadMore = true;
      }
    }
  }

  Future<List<DocumentSnapshot>> _getCategoryProducts(int length) async {
    final collection = await (database.getFutureCollectionWithRangeAndValue(
      'products',
      startAfter: _lastDocuments.isEmpty ? null : _lastDocuments.last,
      length: length,
      orderBy: 'date',
      key: 'category',
      value: category,
    ));

    if (collection.docs.isNotEmpty) {
      _lastDocuments.add(collection.docs.last);
    }

    return collection.docs;
  }

  ///Remove all cart items
  Future<void> removeCart() async {
    await database.removeCollection("users/${auth.uid}/cart");
  }
}
