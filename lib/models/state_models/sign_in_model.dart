import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:grocery/helpers/validators.dart';
import 'package:grocery/services/auth.dart';
import 'package:grocery/services/database.dart';
import 'package:grocery/widgets/dialogs/error_dialog.dart';

class SignInModel with ChangeNotifier {
  final AuthBase auth;

  final Database database;
  bool isSignedIn = true;

  bool isLoading = false;

  bool validName = true;
  bool validEmail = true;
  bool validPassword = true;

  SignInModel({required this.auth, required this.database});

  void changeSignStatus() {
    isSignedIn = !isSignedIn;
    refreshTextFields();
    notifyListeners();
  }

  void refreshTextFields() {
    if (validName == false) {
      validName = true;
    }

    if (validEmail == false) {
      validEmail = true;
    }

    if (validPassword == false) {
      validPassword = true;
    }
  }

  Future<void> signInWithEmail(
      BuildContext context, String email, String password) async {
    try {
      isLoading = true;
      notifyListeners();

      if (_verifyInputs(context, email, password)) {
        await auth.signInWithEmailAndPassword(email, password);
      }
    } catch (e) {
      if (e is FirebaseAuthException) {
        FirebaseAuthException exception = e;

        showDialog(
            context: context,
            builder: (context) => ErrorDialog(message: exception.message!)
                );
      }

      //   SnackBars.error(context: context, content: exception);

    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<void> createAccount(
      BuildContext context, String email, String password, String name) async {
    try {
      isLoading = true;
      notifyListeners();

      if (_verifyInputs(context, email, password, name)) {
        final authResult =
            await auth.createUserWithEmailAndPassword(email, password);
        if (authResult.user != null) {
          authResult.user!.updateDisplayName(
            name,
          );
        }
      }
    } catch (e) {
      if (e is FirebaseAuthException) {
        FirebaseAuthException exception = e;

        showDialog(
            context: context,
            builder: (context) =>
                ErrorDialog(message: exception.message!));
      }

      //  SnackBars.error(context: context, content: exception);

    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<void> signInWithGoogle(BuildContext context) async =>
      await _signIn(context, auth.signInWithGoogle());

  Future<void> signInWithFacebook(BuildContext context) async =>
      await _signIn(context, auth.signInWithFacebook());

  Future<void> _signIn(BuildContext context, Future<void> function) async {
    try {
      isLoading = true;
      notifyListeners();
      await function;
    } catch (e) {
      if (e is FirebaseAuthException) {
        FirebaseAuthException exception = e;

        showDialog(
            context: context,
            builder: (context) =>
                ErrorDialog(message: exception.message!));
      }
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  ///Verify fields input
  bool _verifyInputs(BuildContext context, String email, String password,
      [String? name]) {
    bool result = true;

    if (name != null) {
      if (!Validators.name(name)) {
        validName = false;
        result = false;
      } else {
        validName = true;
      }
    }

    if (!Validators.email(email)) {
      validEmail = false;
      result = false;
    } else {
      validEmail = true;
    }

    if (!Validators.password(password)) {
      validPassword = false;
      result = false;
    } else {
      validPassword = true;
    }

    if (!result) {
      notifyListeners();
    }

    return result;
  }
}
