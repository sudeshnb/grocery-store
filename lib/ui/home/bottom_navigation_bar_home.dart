import 'package:flutter/material.dart';
import 'package:grocery/models/state_models/bottom_navigation_bar_model.dart';
import 'package:grocery/models/state_models/home_model.dart';
import 'package:provider/provider.dart';

class BottomNavigationBarHome extends StatelessWidget {
  final BottomNavigationBarModel model;

  const BottomNavigationBarHome({required this.model});

  @override
  Widget build(BuildContext context) {
    return BottomNavigationBar(
      currentIndex: model.indexPage,
      onTap: (index) {
        model.goToPage(index);

        final homeModel = Provider.of<HomeModel>(context, listen: false);
        homeModel.goToPage(index);
      },
      type: BottomNavigationBarType.fixed,
      showUnselectedLabels: false,
      showSelectedLabels: false,
      items: [
        BottomNavigationBarItem(
          icon: Icon(
            Icons.home,
          ),
          label: "Home",
        ),
        BottomNavigationBarItem(
          icon: Icon(
            Icons.search,

          ),
          label: "Search",
        ),
        BottomNavigationBarItem(
          icon: Icon(
            Icons.shopping_cart,

          ),
          label: "Cart",
        ),
        BottomNavigationBarItem(
            icon: Icon(
              Icons.settings,

            ),
            label: "Settings"),
      ],
    );
  }
}
