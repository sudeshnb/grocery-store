import 'dart:async';

import 'package:grocery/models/data_models/address.dart';
import 'package:grocery/services/database.dart';
import 'package:rxdart/rxdart.dart';

class AddressesBloc {
  final String uid;
  final Database database;

  AddressesBloc({required this.uid, required this.database, String? selected}) {
    selectedAddressController.add(selected);
  }

  ///Update selected address
  Future<void> setSelectedAddress(String id) async {
    selectedAddressController.add(id);
  }

  ///Delete address
  Future<void> deleteAddress(String id) async {
    await database.removeData('users/$uid/addresses/$id');
  }

  ///Get list of addresses
  Stream<List<Address>> _getAddresses() {
    final snapshots = database.getDataFromCollection('users/$uid/addresses');

    return snapshots.map((snapshots) => snapshots.docs
        .map((snapshot) => Address.fromMap(
            snapshot.data() as Map<String, dynamic>, snapshot.id))
        .toList());
  }

  StreamController<String?> selectedAddressController = BehaviorSubject();

  ///Get selected address
  Stream<String?> _getSelectedAddress() {
    return selectedAddressController.stream;
  }

  ///Get address and selected address and combine them using RxDart
  Stream<List<Address>> getAddresses() {
    return Rx.combineLatest2(_getAddresses(), _getSelectedAddress(),
        (List<Address> addresses, String? selectedAddress) {
      bool isSelected = false;
      for (var element in addresses) {
        if (element.id == selectedAddress) {
          element.selected = true;
          isSelected = true;
        } else {
          element.selected = false;
        }
      }

      if (addresses.isNotEmpty && !isSelected) {
        addresses[0].selected = true;
      }

      return addresses;
    });
  }
}
