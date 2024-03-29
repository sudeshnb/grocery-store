import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:grocery/helpers/validators.dart';
import 'package:grocery/services/auth.dart';
import 'package:grocery/widgets/dialogs/error_dialog.dart';
import 'package:grocery/widgets/dialogs/success_dialog.dart';

class ChangePasswordModel with ChangeNotifier {
  final AuthBase auth;

  bool validPassword = true;
  bool validConfirmPassword = true;

  bool isLoading = false;

  Future<void> submit(
      BuildContext context, String password, String confirmPassword) async {
    if (_verifyInputs(context, password, confirmPassword)) {
      try {
        isLoading = true;
        notifyListeners();

        await auth.changePassword(password);

        Navigator.pop(context);

        showDialog(
            context: context,
            builder: (context) =>
                const SuccessDialog(message: "The password is changed"));
      } catch (e) {
        if (e is FirebaseAuthException) {
          FirebaseAuthException exception = e;

          showDialog(
              context: context,
              builder: (context) => ErrorDialog(message: exception.message!));
        }
      } finally {
        isLoading = false;
        notifyListeners();
      }
    }
  }

  bool _verifyInputs(
      BuildContext context, String password, String confirmPassword) {
    bool result = true;

    if (!Validators.password(password)) {
      validPassword = false;
      result = false;
    } else {
      validPassword = true;
    }

    if (!Validators.password(confirmPassword)) {
      validConfirmPassword = false;
      result = false;
    } else {
      validConfirmPassword = true;
    }

    notifyListeners();

    if (Validators.password(password) &&
        Validators.password(confirmPassword) &&
        password != confirmPassword) {
      result = false;
      showDialog(
          context: context,
          builder: (context) =>
              const ErrorDialog(message: "Passwords did't match"));
    }

    return result;
  }

  ChangePasswordModel({required this.auth});
}
