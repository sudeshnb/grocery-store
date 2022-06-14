import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_svg/svg.dart';
import 'package:grocery/blocs/cart_bloc.dart';
import 'package:grocery/blocs/summary_bloc.dart';
import 'package:grocery/models/data_models/cart_item.dart';
import 'package:grocery/models/state_models/checkout_model.dart';
import 'package:grocery/models/data_models/product.dart';
import 'package:grocery/models/state_models/theme_model.dart';
import 'package:grocery/services/database.dart';
import 'package:grocery/ui/product_details/product_details.dart';
import 'package:grocery/widgets/cards/cart_card.dart';
import 'package:grocery/widgets/fade_in.dart';
import 'package:provider/provider.dart';
import 'package:decimal/decimal.dart';

class Summary extends StatefulWidget {
  final SummaryBloc bloc;

  const Summary({required this.bloc});

  static create(BuildContext context) {
    final database = Provider.of<Database>(context, listen: false);
    final cartBloc = Provider.of<CartBloc>(context, listen: false);

    return Provider<SummaryBloc>(
      create: (context) => SummaryBloc(
        cartBloc: cartBloc,
        database: database,
      ),
      child: Consumer<SummaryBloc>(
        builder: (context, bloc, _) {
          return Summary(bloc: bloc);
        },
      ),
    );
  }

  @override
  _SummaryState createState() => _SummaryState();
}

class _SummaryState extends State<Summary> with TickerProviderStateMixin {
  TextEditingController codeController = TextEditingController();
  FocusNode codeFocus = FocusNode();

  @override
  void initState() {
    super.initState();

    final checkoutModel = Provider.of<CheckoutModel>(context, listen: false);
    if (checkoutModel.coupon != null) {
      codeController = TextEditingController(text: checkoutModel.coupon!.code);
    }
  }

  bool initialBuild = true;

  @override
  Widget build(BuildContext context) {
    final checkoutModel = Provider.of<CheckoutModel>(context, listen: false);
    final themeModel = Provider.of<ThemeModel>(context);
    double width = MediaQuery.of(context).size.width;

    ///If cart is empty, pop to home
    return StreamBuilder<List<CartItem>>(
      stream: widget.bloc.cartBloc.cartItems,
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          List<CartItem> cartItems = snapshot.data!;
          if (cartItems.length == 0) {
            // TODO
            // SchedulerBinding.instance.addPostFrameCallback((_) {
            //   Navigator.pop(context);
            // });

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
                      padding: EdgeInsets.only(top: 30),
                      child: Text(
                        'Nothing found here\nGo and enjoy shopping!',
                        style: themeModel.theme.textTheme.headline3!.apply(
                          color: themeModel.accentColor,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    )
                  ]),
            );
          } else {
            return StreamBuilder<List<Product>>(
                stream: widget.bloc.cartBloc.getProducts(cartItems),
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
                          }).length ==
                          0) {
                        return false;
                      } else {
                        return true;
                      }
                    }).toList();

                    if (cartItems.length == 0) {
                      // TODO
                      // SchedulerBinding.instance.addPostFrameCallback((_) {
                      //   Navigator.pop(context);
                      // });
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
                            ]),
                      );
                    } else {
                      checkoutModel.cartItems = cartItems;

                      num order = checkoutModel.getTotal();
                      num total = checkoutModel.getDiscountedTotal();
                      return ListView(
                        padding: EdgeInsets.only(
                            left: 20, right: 20, top: 20, bottom: 100),
                        children: [
                          ///List of cart items
                          Column(
                            children: List.generate(cartItems.length, (index) {
                              return FadeIn(
                                  child: CartCard(
                                      cartItem: cartItems[index],
                                      delete: () async {
                                        await widget.bloc.cartBloc
                                            .removeFromCart(
                                                cartItems[index].reference);
                                      },
                                      updateQuantity:
                                          widget.bloc.cartBloc.updateQuantity,
                                      updateUnit:
                                          widget.bloc.cartBloc.updateUnit,
                                      goToProduct: () {
                                        ProductDetails.create(
                                                context, products[index])
                                            .then((value) {
                                          if (value != null) {
                                            Navigator.pop(context, true);
                                          }
                                        });
                                      }));
                            }),
                          ),

                          StreamBuilder<bool>(
                              stream: widget.bloc.couponStream,
                              initialData: false,
                              builder: (context, snapshot) {
                                bool isLoading = snapshot.data!;

                                return Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Container(
                                      decoration: BoxDecoration(
                                          color:
                                              themeModel.secondBackgroundColor,
                                          borderRadius: BorderRadius.all(
                                              Radius.circular(15)),
                                          border: Border.all(
                                              color: (initialBuild ||
                                                      widget.bloc.validCode)
                                                  ? themeModel
                                                      .secondBackgroundColor
                                                  : Colors.red,
                                              width: 2)),
                                      child: Row(
                                        children: [
                                          Expanded(
                                              child: TextField(
                                            enabled: !isLoading,
                                            keyboardType: TextInputType.text,
                                            textInputAction:
                                                TextInputAction.done,
                                            controller: codeController,
                                            focusNode: codeFocus,
                                            textCapitalization:
                                                TextCapitalization.characters,
                                            onSubmitted: (value) {
                                              initialBuild = false;
                                              widget.bloc.submitCoupon(
                                                  context, codeController.text);
                                            },
                                            onChanged: (value) {},
                                            decoration: InputDecoration(
                                                border: InputBorder.none,
                                                focusedBorder: InputBorder.none,
                                                enabledBorder: InputBorder.none,
                                                errorBorder: InputBorder.none,
                                                disabledBorder:
                                                    InputBorder.none,
                                                hintText: "Enter coupon",
                                                contentPadding: EdgeInsets.only(
                                                    left: 20, right: 20)),
                                          )),
                                          GestureDetector(
                                            child: Container(
                                              decoration: BoxDecoration(
                                                  color: Colors.transparent),
                                              padding:
                                                  EdgeInsets.only(right: 10),
                                              child: (isLoading)
                                                  ? CircularProgressIndicator()
                                                  : Icon(
                                                      Icons
                                                          .arrow_forward_ios_sharp,
                                                      size: 18,
                                                      color:
                                                          themeModel.textColor,
                                                    ),
                                            ),
                                            onTap: () {
                                              initialBuild = false;
                                              widget.bloc.submitCoupon(
                                                  context, codeController.text);
                                            },
                                          ),
                                        ],
                                      ),
                                    ),
                                    AnimatedSize(
                                      duration: Duration(milliseconds: 300),
                                      child: (!initialBuild && !isLoading)
                                          ? FadeIn(
                                              child: Text(
                                                widget.bloc.message!,
                                                style: themeModel
                                                    .theme.textTheme.subtitle2!
                                                    .apply(
                                                        color:
                                                            widget.bloc
                                                                    .validCode
                                                                ? themeModel
                                                                    .accentColor
                                                                : Colors.red),
                                              ),
                                            )
                                          : SizedBox(),
                                    ),
                                  ],
                                );
                              }),

                          ///Total price of orders
                          FadeIn(
                            duration: Duration(milliseconds: 400),
                            child: Padding(
                              padding: EdgeInsets.only(top: 10),
                              child: Row(
                                children: [
                                  Text(
                                    'Order:',
                                    style: themeModel.theme.textTheme.bodyText1,
                                  ),
                                  Spacer(),
                                  Text(
                                    order.toString() + '\$',
                                    style: themeModel.theme.textTheme.headline3!
                                        .apply(color: themeModel.priceColor),
                                  ),
                                ],
                              ),
                            ),
                          ),

                          ///Delivery price
                          FadeIn(
                            duration: Duration(milliseconds: 400),
                            child: Padding(
                              padding: EdgeInsets.only(top: 10),
                              child: Row(
                                children: [
                                  Text(
                                    'Delivery:',
                                    style: themeModel.theme.textTheme.bodyText1,
                                  ),
                                  Spacer(),
                                  Text(
                                    checkoutModel.shippingMethod!.price
                                            .toString() +
                                        '\$',
                                    style: themeModel.theme.textTheme.headline3!
                                        .apply(color: themeModel.priceColor),
                                  ),
                                ],
                              ),
                            ),
                          ),

                          StreamBuilder(
                              stream: widget.bloc.couponPriceStream,
                              builder: (context, snapshot) {
                                total = checkoutModel.getDiscountedTotal();
                                return Column(
                                  children: [
                                    AnimatedSize(
                                      duration: Duration(milliseconds: 300),
                                      child: (checkoutModel.coupon == null)
                                          ? SizedBox()
                                          : FadeIn(
                                              duration:
                                                  Duration(milliseconds: 400),
                                              child: Padding(
                                                padding:
                                                    EdgeInsets.only(top: 10),
                                                child: Row(
                                                  children: [
                                                    Text(
                                                      'Coupon:',
                                                      style: themeModel.theme
                                                          .textTheme.bodyText1,
                                                    ),
                                                    Spacer(),
                                                    Text(
                                                      "-" +
                                                          Decimal.parse(
                                                                  checkoutModel
                                                                      .coupon!
                                                                      .value
                                                                      .toString())
                                                              .toString() +
                                                          ((checkoutModel
                                                                      .coupon!
                                                                      .type ==
                                                                  "percentage")
                                                              ? "%"
                                                              : "\$"),
                                                      style: themeModel.theme
                                                          .textTheme.headline3!
                                                          .apply(
                                                              color: themeModel
                                                                  .priceColor),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            ),
                                    ),

                                    ///Total price: order + delivery
                                    FadeIn(
                                      duration: Duration(milliseconds: 400),
                                      child: Padding(
                                        padding: EdgeInsets.only(top: 10),
                                        child: Row(
                                          children: [
                                            Text(
                                              'Total:',
                                              style: themeModel
                                                  .theme.textTheme.bodyText1,
                                            ),
                                            Spacer(),
                                            Text(
                                              total.toString() + '\$',
                                              style: themeModel
                                                  .theme.textTheme.headline3!
                                                  .apply(
                                                      color: themeModel
                                                          .priceColor),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ],
                                );
                              }),
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
                    return Center(
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
          return Center(
            child: CircularProgressIndicator(),
          );
        }
      },
    );
  }
}
