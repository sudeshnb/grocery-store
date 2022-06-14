import 'dart:async';

import 'package:grocery/models/data_models/address.dart';
import 'package:grocery/services/database.dart';
import 'package:rxdart/rxdart.dart';

class AddressesBloc {
  final String uid;
  final Database database;

  AddressesBloc({required this.uid, required this.database, String? selected}) {
    _selectedAddressController.add(selected);
  }

  ///Update selected address
  Future<void> setSelectedAddress(String id) async {
    _selectedAddressController.add(id);
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

  StreamController<String?> _selectedAddressController = BehaviorSubject();

  ///Get selected address
  Stream<String?> _getSelectedAddress() {
    return _selectedAddressController.stream;
  }

  ///Get address and selected address and combine them using RxDart
  Stream<List<Address>> getAddresses() {
    return Rx.combineLatest2(_getAddresses(), _getSelectedAddress(),
        (List<Address> addresses, String? selectedAddress) {
      bool isSelected = false;
      addresses.forEach((element) {
        if (element.id == selectedAddress) {
          element.selected = true;
          isSelected = true;
        } else {
          element.selected = false;
        }
      });

      if (addresses.length != 0 && !isSelected) {
        addresses[0].selected = true;
      }

      return addresses;
    });
  }
}
