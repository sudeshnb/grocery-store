import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:grocery/models/state_models/checkout_bar_model.dart';
import 'package:grocery/models/state_models/checkout_model.dart';
import 'package:grocery/models/state_models/theme_model.dart';
import 'package:grocery/ui/addresses/addresses.dart';
import 'package:grocery/ui/home/cart/checkout/checkout_bar.dart';
import 'package:grocery/ui/home/cart/checkout/payment.dart';
import 'package:grocery/ui/home/cart/checkout/shipping.dart';
import 'package:grocery/ui/home/cart/checkout/summary.dart';

class Checkout extends StatelessWidget {
  final CheckoutModel model;

  const Checkout({
    Key? key,
    required this.model,
  }) : super(key: key);

  static Future<bool?> create(BuildContext context) async {
    return await Navigator.push(
        context,
        CupertinoPageRoute(
            builder: (context) => MultiProvider(
                  providers: [
                    ChangeNotifierProvider<CheckoutModel>(
                      create: (context) => CheckoutModel(
                        pageController: PageController(),
                      ),
                    ),
                    ChangeNotifierProvider<CheckoutBarModel>(
                      create: (context) => CheckoutBarModel(),
                    ),
                  ],
                  child: Consumer<CheckoutModel>(
                    builder: (context, model, _) {
                      return Checkout(
                        model: model,
                      );
                    },
                  ),
                )));
  }

  @override
  Widget build(BuildContext context) {
    final themeModel = Provider.of<ThemeModel>(context);
    final checkoutBarModel =
        Provider.of<CheckoutBarModel>(context, listen: false);

    return Scaffold(
      appBar: AppBar(
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(
            bottom: Radius.circular(15),
          ),
        ),
        title: Text(
          "Checkout",
          style: themeModel.theme.textTheme.headline3,
        ),
        backgroundColor: themeModel.secondBackgroundColor,
        centerTitle: true,
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back,
            color: themeModel.textColor,
          ),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(70),
          child: Theme(
            data: ThemeData(
              highlightColor: Colors.transparent,
              splashColor: Colors.transparent,
            ),
            child: CheckoutBar.create(),
          ),
        ),
      ),
      floatingActionButton: (model.pageIndex == 3)
          ? const SizedBox()
          : FloatingActionButton(
              child: const Icon(
                Icons.arrow_forward,
                color: Colors.white,
              ),
              onPressed: () {
                model.goToNextPage(context, model.pageIndex + 1);
              },
            ),
      body: PageView(
        physics: const NeverScrollableScrollPhysics(),
        controller: model.pageController,
        onPageChanged: (page) {
          checkoutBarModel.updatePageIndex(page);
        },
        children: [
          Addresses.create(context,
              padding: const EdgeInsets.only(
                  top: 20, bottom: 100, left: 20, right: 20),
              selected: model.address != null ? model.address!.id : null),
          Shipping.create(context,
              selected: model.shippingMethod != null
                  ? model.shippingMethod!.id
                  : null),
          Summary.create(context),
          Payment.create(context)
        ],
      ),
    );
  }
}
