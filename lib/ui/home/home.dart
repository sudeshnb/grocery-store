import 'package:flutter/material.dart';
import 'package:grocery/blocs/home_page_bloc.dart';
import 'package:grocery/models/state_models/bottom_navigation_bar_model.dart';
import 'package:grocery/models/state_models/home_model.dart';
import 'package:grocery/services/auth.dart';
import 'package:grocery/services/database.dart';
import 'package:grocery/ui/home/bottom_navigation_bar_home.dart';
import 'package:grocery/ui/home/cart/cart.dart';
import 'package:grocery/ui/home/home_page.dart';
import 'package:grocery/ui/home/search.dart';
import 'package:grocery/ui/home/settings/settings.dart';
import 'package:provider/provider.dart';

// ignore: must_be_immutable
class Home extends StatefulWidget {
  final HomeModel model;

  const Home({required this.model});

  static Widget create(BuildContext context) {
    final auth = Provider.of<AuthBase>(context);
    final database = Provider.of<Database>(context);

    return MultiProvider(
      providers: [
        Provider<HomePageBloc>(
          create: (context) => HomePageBloc(database: database, auth: auth),
        ),
        Provider<HomeModel>(
          create: (context) => HomeModel(auth: auth, database: database),
        ),
        ChangeNotifierProvider<BottomNavigationBarModel>(
          create: (context) => BottomNavigationBarModel(),
        ),
      ],
      child: Consumer<HomeModel>(
        builder: (context, model, _) {
          return Home(
            model: model,
          );
        },
      ),
    );
  }

  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
  @override
  void initState() {
    super.initState();

    ///Add fcm token to firestore to receive notifications
    widget.model.checkNotificationToken();
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
        child: Scaffold(
          key: Key("home"),
          extendBody: true,
          body: PageView(
            controller: widget.model.pageController,
            children: [
              ///Home screens
              HomePage.create(),
              Search.create(context),
              Cart.create(),
              Settings.create(context),
            ],
            onPageChanged: (value) {
              final bottomModel =
                  Provider.of<BottomNavigationBarModel>(context, listen: false);

              bottomModel.goToPage(value);
            },
          ),
          bottomNavigationBar: Consumer<BottomNavigationBarModel>(
            builder: (context, model, _) {
              return BottomNavigationBarHome(
                model: model,
              );
            },
          ),
        ),
        onWillPop: () async {
          ///When clicking on return button
          ///If home is in homePage pop else go to homePage
          return widget.model.onPop();
        });
  }
}
