import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:grocery/blocs/cart_bloc.dart';
import 'package:grocery/blocs/landing_bloc.dart';
import 'package:grocery/services/auth.dart';
import 'package:grocery/services/database.dart';
import 'package:grocery/transitions/fade_route.dart';
import 'package:grocery/ui/home/home.dart';
import 'package:grocery/ui/sign_in.dart';
import 'package:grocery/widgets/fade_in.dart';

class Landing extends StatelessWidget {
  final LandingBloc bloc;

  const Landing({
    Key? key,
    required this.bloc,
  }) : super(key: key);

  static void create(BuildContext context) {
    final auth = Provider.of<AuthBase>(context, listen: false);
    final database = Provider.of<Database>(context, listen: false);
    Navigator.pushReplacement(
        context,
        FadeRoute(
            page: Provider<LandingBloc>(
          create: (context) => LandingBloc(auth: auth, database: database),
          child: Consumer<LandingBloc>(
            builder: (context, bloc, _) {
              return Landing(bloc: bloc);
            },
          ),
        )));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: StreamBuilder<User?>(
        stream: bloc.onAuthStateChanged,
        builder: (context, snapshot) {
          ///If signed in redirect to home, else redirect to sign in page
          if (snapshot.data != null) {
            WidgetsBinding.instance!.addPostFrameCallback((_) async {
              final cartBloc = Provider.of<CartBloc>(context, listen: false);
              cartBloc.cartItemsController.addStream(cartBloc.getCartItems());
//  final auth =
              Provider.of<AuthBase>(context, listen: false);
              // print(auth.uid);
            });

            return FadeIn(child: Home.create(context));
          } else {
            return FadeIn(child: SignIn.create(context));
          }
        },
      ),
    );
  }
}
