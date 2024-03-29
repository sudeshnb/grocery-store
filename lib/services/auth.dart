import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/services.dart';
import 'package:flutter_facebook_auth/flutter_facebook_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';

///Auth service
abstract class AuthBase {
  Stream<User?> get onAuthStateChanged;

  Future<void> signInWithEmailAndPassword(String email, String password);

  Future<UserCredential> createUserWithEmailAndPassword(
      String email, String password);

  Future<void> signInWithGoogle();

  Future<void> signInWithFacebook();

  Future<void> signOut();

  Future<void> editImage(String path);

  Future<void> updateNameAndEmail(String email, String name);

  Future<void> changePassword(String password);

  String get uid;

  String get email;

  String? get profileImage;

  String get displayName;

  Future<String> get token;
}

class Auth implements AuthBase {
  final _firebaseAuth = FirebaseAuth.instance;

  @override
  Stream<User?> get onAuthStateChanged {
    return _firebaseAuth.authStateChanges();
  }

  @override
  String get uid => _firebaseAuth.currentUser!.uid;

  @override
  Future<String> get token => _firebaseAuth.currentUser!.getIdToken();

  @override
  String get email => _firebaseAuth.currentUser!.email ?? "";

  @override
  String get displayName => _firebaseAuth.currentUser!.displayName ?? "";

  @override
  String? get profileImage => _firebaseAuth.currentUser!.photoURL;

  @override
  Future<void> editImage(String path) async {
    await _firebaseAuth.currentUser!.updatePhotoURL(path);
  }

  @override
  Future<void> updateNameAndEmail(String email, String name) async {
    await _firebaseAuth.currentUser!.updateDisplayName(name);

    await _firebaseAuth.currentUser!.updateEmail(email);
  }

  @override
  Future<void> changePassword(String password) async {
    await _firebaseAuth.currentUser!.updatePassword(password);
  }

  @override
  Future<void> signInWithEmailAndPassword(String email, String password) async {
    await _firebaseAuth.signInWithEmailAndPassword(
        email: email, password: password);
  }

  @override
  Future<UserCredential> createUserWithEmailAndPassword(
      String email, String password) async {
    return await _firebaseAuth.createUserWithEmailAndPassword(
        email: email, password: password);
  }

  @override
  Future<void> signInWithGoogle() async {
    final googleSignIn = GoogleSignIn();
    final googleAccount = await googleSignIn.signIn();
    if (googleAccount != null) {
      final googleAuth = await googleAccount.authentication;
      if (googleAuth.accessToken != null && googleAuth.idToken != null) {
        await _firebaseAuth.signInWithCredential(
          GoogleAuthProvider.credential(
            idToken: googleAuth.idToken,
            accessToken: googleAuth.accessToken,
          ),
        );
      } else {
        throw PlatformException(
          code: 'ERROR_MISSING_GOOGLE_AUTH_TOKEN',
          message: 'Missing Google Auth Token',
        );
      }
    } else {
      throw PlatformException(
        code: 'ERROR_ABORTED_BY_USER',
        message: 'Sign in aborted by user',
      );
    }
  }

  @override
  Future<void> signInWithFacebook() async {
    final LoginResult result = await FacebookAuth.instance.login(permissions: [
      'public_profile'
    ]); // by default we request the email and the public profile

    if (result.status == LoginStatus.success) {
      await _firebaseAuth.signInWithCredential(
        FacebookAuthProvider.credential(
          result.accessToken!.token,
        ),
      );
    } else {
      throw PlatformException(
        code: 'ERROR_ABORTED_BY_USER',
        message: 'Sign in aborted by user',
      );
    }
  }

  @override
  Future<void> signOut() async {
    final googleSignIn = GoogleSignIn();
    await googleSignIn.signOut();
    final facebookLogin = FacebookAuth.instance;
    await facebookLogin.logOut();
    await _firebaseAuth.signOut();
  }
}
