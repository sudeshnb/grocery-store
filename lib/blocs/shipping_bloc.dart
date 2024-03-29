import 'dart:async';

import 'package:grocery/models/data_models/shipping_method.dart';
import 'package:grocery/services/database.dart';
import 'package:rxdart/rxdart.dart';

class ShippingBloc {
  final Database database;
  final String uid;

  ShippingBloc({required this.database, required this.uid, String? selected}) {
    selectedShippingController.add(selected);
  }

  ///Get shipping methods
  Stream<List<ShippingMethod>> _getShippingMethods() {
    final snapshot = database.getDataFromCollection("shipping");

    return snapshot.map((event) => event.docs
        .map((e) =>
            ShippingMethod.fromMap(e.data() as Map<String, dynamic>, e.id))
        .toList());
  }

  ///Get shipping methods with selected shipping and combine them using RxDart
  Stream<List<ShippingMethod>> getShippingMethods() {
    return Rx.combineLatest2(_getShippingMethods(), _getSelectedShipping(),
        (List<ShippingMethod> shippingMethods, String? selectedShipping) {
      bool isSelected = false;
      for (var element in shippingMethods) {
        if (element.id == selectedShipping) {
          element.selected = true;
          isSelected = true;
        } else {
          element.selected = false;
        }
      }

      if (shippingMethods.isNotEmpty && !isSelected) {
        shippingMethods[0].selected = true;
      }

      return shippingMethods;
    });
  }

  StreamController<String?> selectedShippingController = BehaviorSubject();

  ///Get selected shipping index
  Stream<String?> _getSelectedShipping() {
    return selectedShippingController.stream;
  }

  ///Update selected shipping index
  Future<void> setSelectedShipping(String value) async {
    selectedShippingController.add(value);
  }
}
