import 'package:country_code_picker/country_code.dart';
import 'package:flutter/cupertino.dart';
import 'package:grocery/services/database.dart';

class AddAddressModel with ChangeNotifier {
  final Database database;
  final String uid;

  CountryCode country = CountryCode.fromCountryCode('US');

  bool validName = true;
  bool validAddress = true;
  bool validState = true;
  bool validPhone = true;
  bool validZip = true;
  bool validCity = true;

  bool isLoading = false;

  bool _verifyInputs(String name, String address, String city, String state,
      String phone, String zipCode) {
    bool result = true;

    if (name.replaceAll(" ", "").length < 4) {
      validName = false;
      result = false;
    } else {
      validName = true;
    }

    if (address.replaceAll(" ", "").length < 4) {
      validAddress = false;
      result = false;
    } else {
      validAddress = true;
    }

    if (city.replaceAll(" ", "").length < 3) {
      validCity = false;
      result = false;
    } else {
      validCity = true;
    }

    if (state.replaceAll(" ", "").length < 4) {
      validState = false;
      result = false;
    } else {
      validState = true;
    }

    if (phone.replaceAll(" ", "").length < 7) {
      validPhone = false;
      result = false;
    } else {
      validPhone = true;
    }

    if (zipCode.replaceAll(" ", "").length < 4) {
      validZip = false;
      result = false;
    } else {
      validZip = true;
    }

    if (!result) {
      notifyListeners();
    }

    return result;
  }

  void changeCountry(CountryCode newCountry) {
    country = newCountry;
    notifyListeners();
  }

  Future<void> addAddress(
    BuildContext context, {
    required String name,
    required String address,
    required String city,
    required String state,
    required String zipCode,
    required String phone,
    String? editedId,
  }) async {
    if (_verifyInputs(name, address, city, state, phone, zipCode)) {
      isLoading = true;
      notifyListeners();

      String id;
      if (editedId == null) {
        DateTime date = DateTime.now();

        id = date.year.toString() +
            date.month.toString() +
            date.day.toString() +
            date.hour.toString() +
            date.minute.toString() +
            date.second.toString() +
            date.millisecond.toString() +
            date.microsecond.toString();
      } else {
        id = editedId;
      }

      (editedId == null)
          ? await database.setData({
              'name': name,
              'address': address,
              'city': city,
              'state': state,
              'country': country.name,
              'zip_code': zipCode,
              'phone': country.dialCode! + phone
            }, 'users/$uid/addresses/$id')
          : await database.updateData({
              'name': name,
              'address': address,
              'city': city,
              'state': state,
              'country': country.name,
              'zip_code': zipCode,
              'phone': country.dialCode! + phone
            }, 'users/$uid/addresses/$id');

      isLoading = false;
      notifyListeners();
      Navigator.pop(context);
    }
  }

  AddAddressModel({required this.database, required this.uid});
}
