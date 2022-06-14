import 'package:flutter/cupertino.dart';
import 'package:grocery/blocs/cart_bloc.dart';
import 'package:grocery/services/auth.dart';
import 'package:grocery/services/database.dart';
import 'package:provider/provider.dart';
import 'package:rxdart/subjects.dart';

class SettingsModel with ChangeNotifier {
  final AuthBase auth;
  final Database database;

  SettingsModel({required this.auth, required this.database});

  String? get profileImage => auth.profileImage;

  String? get displayName => auth.displayName;

  String? get email => auth.email;

  String get uid => auth.uid;

  Future<void> signOut(BuildContext context) async {
    await database.setData({}, 'users/${auth.uid}');

    final cartBloc=Provider.of<CartBloc>(context,listen: false);
    cartBloc.cartItemsController=BehaviorSubject();

    await auth.signOut();
  }

  void updateWidget() {
    notifyListeners();
  }
}
