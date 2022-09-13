import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:provider/provider.dart';

import 'package:grocery/blocs/cart_bloc.dart';
import 'package:grocery/models/data_models/cart_item.dart';
import 'package:grocery/models/data_models/product.dart';
import 'package:grocery/models/state_models/home_model.dart';
import 'package:grocery/models/state_models/theme_model.dart';
import 'package:grocery/ui/home/cart/checkout/checkout.dart';
import 'package:grocery/ui/product_details/product_details.dart';
import 'package:grocery/widgets/buttons/default_button.dart';
import 'package:grocery/widgets/cards/cart_card.dart';
import 'package:grocery/widgets/dialogs/success_dialog.dart';
import 'package:grocery/widgets/fade_in.dart';

class Cart extends StatefulWidget {
  final CartBloc bloc;

  const Cart({
    Key? key,
    required this.bloc,
  }) : super(key: key);

  static Widget create() {
    return Consumer<CartBloc>(
      builder: (context, bloc, _) {
        return Cart(
          bloc: bloc,
        );
      },
    );
  }

  @override
  _CartState createState() => _CartState();
}

class _CartState extends State<Cart> with TickerProviderStateMixin {
  @override
  Widget build(BuildContext context) {
    final themeModel = Provider.of<ThemeModel>(context);
    double width = MediaQuery.of(context).size.width;

    return StreamBuilder<List<CartItem>>(
      stream: widget.bloc.cartItems,
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          List<CartItem> cartItems = snapshot.data!;
          if (cartItems.isEmpty) {
            return FadeIn(
              child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    SvgPicture.asset(
                      'images/state_images/empty_cart.svg',
                      width: width * 0.5,
                      fit: BoxFit.cover,
                    ),
                    Padding(
                        padding: const EdgeInsets.only(top: 30),
                        child: Text(
                          'Nothing found here\nGo and enjoy shopping!',
                          style: themeModel.theme.textTheme.headline3!.apply(
                            color: themeModel.accentColor,
                          ),
                          textAlign: TextAlign.center,
                        ))
                  ]),
            );
          } else {
            return StreamBuilder<List<Product>>(
                stream: widget.bloc.getProducts(cartItems),
                builder: (context, snapshot) {
                  if (snapshot.hasData) {
                    List<Product> products = snapshot.data!;
                    cartItems = cartItems.where((cartItem) {
                      if (products.where((product) {
                        if (cartItem.reference == product.reference) {
                          cartItem.product = product;
                          return true;
                        } else {
                          return false;
                        }
                      }).isEmpty) {
                        return false;
                      } else {
                        return true;
                      }
                    }).toList();

                    if (cartItems.isEmpty) {
                      return FadeIn(
                        child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              SvgPicture.asset(
                                'images/state_images/empty_cart.svg',
                                width: width * 0.5,
                                fit: BoxFit.cover,
                              ),
                              Padding(
                                padding: const EdgeInsets.only(top: 30),
                                child: Text(
                                  'Nothing found here\nGo and enjoy shopping!',
                                  style: themeModel.theme.textTheme.headline3!
                                      .apply(
                                    color: themeModel.accentColor,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                              )
                            ]),
                      );
                    } else {
                      return ListView(
                        padding: const EdgeInsets.only(
                            left: 20, right: 20, top: 40, bottom: 80),
                        children: [
                          Padding(
                            padding: const EdgeInsets.only(bottom: 20),
                            child: Align(
                                alignment: Alignment.center,
                                child: Text(
                                  "Cart",
                                  style: themeModel.theme.textTheme.headline3,
                                )),
                          ),

                          ///List of cart items
                          AnimatedSize(
                            duration: const Duration(milliseconds: 300),
                            child: Column(
                              children:
                                  List.generate(cartItems.length, (index) {
                                return FadeIn(
                                    child: CartCard(
                                        cartItem: cartItems[index],
                                        delete: () async {
                                          await widget.bloc.removeFromCart(
                                              cartItems[index].reference);
                                        },
                                        updateQuantity:
                                            widget.bloc.updateQuantity,
                                        updateUnit: widget.bloc.updateUnit,
                                        goToProduct: () {
                                          ProductDetails.create(
                                                  context, products[index])
                                              .then((value) {
                                            if (value != null) {
                                              final homeModel =
                                                  Provider.of<HomeModel>(
                                                      context,
                                                      listen: false);

                                              homeModel.goToPage(0);

                                              showDialog(
                                                      context: context,
                                                      builder: (context) =>
                                                          const SuccessDialog(
                                                              message:
                                                                  "Congratulations!\nYour order is placed!"))
                                                  .then((value) {
                                                widget.bloc.removeCart();
                                              });
                                            }
                                          });
                                        }));
                              }),
                            ),
                          ),

                          ///Checkout button
                          FadeIn(
                            duration: const Duration(milliseconds: 400),
                            child: DefaultButton(
                                color: themeModel.accentColor,
                                widget: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    const Icon(
                                      Icons.arrow_forward,
                                      color: Colors.white,
                                    ),
                                    Padding(
                                        padding:
                                            const EdgeInsets.only(left: 10),
                                        child: Text(
                                          "Checkout",
                                          style: themeModel
                                              .theme.textTheme.headline3!
                                              .apply(color: Colors.white),
                                        ))
                                  ],
                                ),
                                onPressed: () async {
                                  final checkoutResult =
                                      await Checkout.create(context);
                                  if (checkoutResult ?? false) {
                                    final homeModel = Provider.of<HomeModel>(
                                        context,
                                        listen: false);

                                    homeModel.goToPage(0);

                                    showDialog(
                                        context: context,
                                        builder: (context) => const SuccessDialog(
                                            message:
                                                "Congratulations!\nYour order is placed!")).then(
                                        (value) {
                                      widget.bloc.removeCart();
                                    });
                                  }
                                }),
                          )
                        ],
                      );
                    }
                  } else if (snapshot.hasError) {
                    return FadeIn(
                      child: Center(
                        child: SvgPicture.asset(
                          'images/state_images/error.svg',
                          width: width * 0.5,
                          fit: BoxFit.cover,
                        ),
                      ),
                    );
                  } else {
                    return const Center(
                      child: CircularProgressIndicator(),
                    );
                  }
                });
          }
        } else if (snapshot.hasError) {
          return FadeIn(
            child: Center(
              child: SvgPicture.asset(
                'images/state_images/error.svg',
                width: width * 0.5,
                fit: BoxFit.cover,
              ),
            ),
          );
        } else {
          return const Center(
            child: CircularProgressIndicator(),
          );
        }
      },
    );
  }
}
