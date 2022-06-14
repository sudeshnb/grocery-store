import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:grocery/models/data_models/orders_item.dart';
import 'package:grocery/services/database.dart';
import 'package:rxdart/rxdart.dart';

class OrdersBloc {
  final Database database;
  final String uid;

  OrdersBloc({required this.database, required this.uid});

  // ignore: close_sinks
  StreamController<List<OrdersItem>> ordersController = BehaviorSubject();

  Stream<List<OrdersItem>> get ordersStream => ordersController.stream;

  bool _canLoadMore = true;

  List<DocumentSnapshot> _lastDocuments = [];

  List<OrdersItem> savedOrders = [];

  Future<void> loadProducts(int length) async {
    if (_canLoadMore) {
      _canLoadMore = false;

      List<OrdersItem> newOrders = (await _getOrders(length))
          .map(
              (e) => OrdersItem.fromMap(e.data() as Map<String, dynamic>, e.id))
          .toList();

      savedOrders.addAll(newOrders);

      ordersController.add(savedOrders.toSet().toList());

      if (newOrders.length < length) {
        _canLoadMore = false;
      } else {
        _canLoadMore = true;
      }
    }
  }

  Future<List<DocumentSnapshot>> _getOrders(int length) async {
    final collection = await (database.getFutureDataFromCollectionWithRange(
      "users/$uid/orders",
      startAfter: _lastDocuments.isEmpty ? null : _lastDocuments.last,
      length: length,
      orderBy: 'date',
    ));

    if (collection.docs.isNotEmpty) {
      _lastDocuments.add(collection.docs.last);
    }

    return collection.docs;
  }
}
