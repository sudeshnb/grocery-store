import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:grocery/services/auth.dart';
import 'package:grocery/services/database.dart';

class HomeModel {
  PageController pageController = PageController(keepPage: false);
  final Database database;
  final AuthBase auth;

  HomeModel({required this.database, required this.auth});

  int _index = 0;

  void goToPage(int index) {
    if (index != _index) {
      if (index == _index - 1 || index == _index + 1) {
        pageController.animateToPage(
          index,
          duration: Duration(milliseconds: 500),
          curve: Curves.ease,
        );
      } else {
        pageController.jumpToPage(
          index,
        );
      }
      _index = index;
    }
  }

  bool onPop() {
    if (_index == 0) {
      return true;
    } else {
      goToPage(0);
      return false;
    }
  }

  Future<void> checkNotificationToken() async {
    FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;

    String? token = await _firebaseMessaging.getToken();

    if (token != null) {
      await database.setData({
        "token": token,
      }, 'users/${auth.uid}');
    }
  }
}
