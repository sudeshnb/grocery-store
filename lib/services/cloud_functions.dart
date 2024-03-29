import 'package:cloud_functions/cloud_functions.dart';

class CloudFunctions {
  FirebaseFunctions functions = FirebaseFunctions.instance;

  CloudFunctions() {
    //_functions.useFunctionsEmulator('localhost', 5001);
  }

  Future<Map<String, dynamic>?> createPayment(String amount) async {
    final body = {"amount": amount};

    final request = await functions.httpsCallable('createPayment').call(body);

    if (request.data != null) {
      // print(request.data is Map<String, dynamic>);
      return request.data;
    }
    return null;
  }

  Future<bool> addOrder(Map body) async {
    final request = await functions.httpsCallable('addOrder').call(body);

    if (request.data == "Your order is placed!") {
      return true;
    } else {
      // print(request.data);
      return false;
    }
  }
}
