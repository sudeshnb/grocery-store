import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:grocery/models/data_models/product.dart';
import 'package:grocery/services/auth.dart';
import 'package:grocery/services/database.dart';
import 'package:rxdart/rxdart.dart';

class SearchBloc {
  final Database database;
  final AuthBase auth;

  SearchBloc({required this.database, required this.auth});

  // ignore: close_sinks
  StreamController<List<Product>> productsController = BehaviorSubject();

  Stream<List<Product>> get productsStream => productsController.stream;

  bool _canLoadMore = true;

  void clearHistory() {
    _lastDocuments = [];
    savedProducts = [];
    _canLoadMore=true;
  }

  List<DocumentSnapshot> _lastDocuments = [];

  List<Product> savedProducts = [];

  Future<void> loadProducts(String text, int length) async {
    if (_canLoadMore) {
      _canLoadMore = false;

      List<Product> newProducts = (await getSearchedProducts(text, length))
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

  Future<List<DocumentSnapshot>> getSearchedProducts(
      String text, int length) async {
    final collection = await (database.getFutureCollectionWithRangeAndSearch(
        'products',
        startAfter: _lastDocuments.isEmpty ? null : _lastDocuments.last,
        length: length,
        orderBy: 'title',
        searchedData: text));

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
