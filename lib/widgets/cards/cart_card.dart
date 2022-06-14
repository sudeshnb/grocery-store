import 'package:decimal/decimal.dart';
import 'package:flutter/material.dart';
import 'package:grocery/models/data_models/cart_item.dart';
import 'package:grocery/models/state_models/theme_model.dart';
import 'package:grocery/ui/home/cart/edit_cart_item.dart';
import 'package:grocery/widgets/buttons/default_button.dart';
import 'package:grocery/widgets/transparent_image.dart';
import 'package:provider/provider.dart';

class CartCard extends StatelessWidget {
  final CartItem cartItem;
  final Future Function() delete;
  final Future Function(String, int) updateQuantity;
  final Future Function(String, String) updateUnit;
  final void Function() goToProduct;

  const CartCard({
    required this.cartItem,
    required this.delete,
    required this.updateQuantity,
    required this.updateUnit,
    required this.goToProduct});








  @override
  Widget build(BuildContext context) {
    final themeModel = Provider.of<ThemeModel>(context);
    final width = MediaQuery.of(context).size.width;

    return Container(
      decoration: BoxDecoration(
          color: themeModel.secondBackgroundColor,
          borderRadius:const BorderRadius.all(Radius.circular(15)),
          boxShadow: [
            BoxShadow(
                blurRadius: 2,
                offset:const Offset(0, 5),
                color: themeModel.shadowColor)
          ]),
      margin:const EdgeInsets.only(bottom: 10),
      child: GestureDetector(
        onTap: goToProduct,
        child: Container(
          color: Colors.transparent,
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              GestureDetector(
                onTap: goToProduct,
                child: Container(
                  padding:const EdgeInsets.only(top: 20, bottom: 20, left: 20),
                  color: Colors.transparent,
                  child: Hero(
                    tag: cartItem.product!.reference,
                    child: FadeInImage(
                      width: width * 0.2,
                      fit: BoxFit.cover,
                      placeholder: MemoryImage(kTransparentImage),
                      image: NetworkImage(cartItem.product!.image),
                    ),
                  ),
                ),
              ),
              Expanded(
                  child: GestureDetector(
                    onTap: goToProduct,
                    child: Container(
                      color: Colors.transparent,
                      padding:const EdgeInsets.only(top: 20, bottom: 20, right: 10),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Padding(
                            padding:const EdgeInsets.only(left: 10),
                            child: Align(
                              alignment: Alignment.centerLeft,
                              child: Text(
                                  cartItem.product!.title,
                                style: themeModel.theme.textTheme.headline3,
                              )


                            ),
                          ),
                          Padding(
                            padding:const EdgeInsets.only(top: 10, left: 10),
                            child: Align(
                              alignment: Alignment.centerLeft,
                              child:Text(
                                  cartItem.quantity.toString() +
                                      " " +
                                      cartItem.unit,
                                style: themeModel.theme.textTheme.bodyText1!.apply(
                                  color: themeModel.secondTextColor
                                ),
                              )

                            ),
                          ),
                          Padding(
                            padding:const EdgeInsets.only(
                              top: 10,
                            ),
                            child: Align(
                              alignment: Alignment.centerRight,
                              child: Padding(
                                padding:const EdgeInsets.only(left: 10),
                                child: Text(
                                    (Decimal.parse(((cartItem.unit == 'Piece')
                                        ? cartItem
                                        .product!.pricePerPiece
                                        : (cartItem.unit == 'KG')
                                        ? cartItem
                                        .product!.pricePerKg
                                        : cartItem.product!
                                        .pricePerKg! *
                                        0.001)
                                        .toString()) *
                                        Decimal.parse(
                                            cartItem.quantity.toString()))
                                        .toString() +
                                        "\$",

                                  style: themeModel.theme.textTheme.bodyText1!.apply(
                                    color: themeModel.priceColor
                                  ),

                                )

                              ),
                            ),
                          )
                        ],
                      ),
                    ),
                  )),
              Column(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Padding(
                    padding:const EdgeInsets.only(
                      right: 10,
                    ),
                    child: GestureDetector(
                        child: Icon(
                          Icons.edit,
                          color: themeModel.secondTextColor,
                        ),
                        onTap: () {
                          showModalBottomSheet(
                              context: context,
                              builder: (context) {
                                return EditCarItem.create(
                                    pricePerKg: cartItem.product!.pricePerKg,
                                    pricePerPiece:
                                    cartItem.product!.pricePerPiece,
                                    quantity: cartItem.quantity,
                                    initialUnitTitle: cartItem.unit,
                                    updateQuantity: updateQuantity,
                                    reference: cartItem.reference,
                                    updateUnit: updateUnit);
                              });
                        }),
                  ),
                  Padding(
                    padding:const EdgeInsets.only(right: 10, top: 20),
                    child: GestureDetector(
                        child: Icon(
                          Icons.delete,
                          color: themeModel.secondTextColor,
                        ),
                        onTap: () {
                          showModalBottomSheet(
                              context: context,
                              backgroundColor: Colors.transparent,
                              builder: (context) {
                                return Container(
                                  decoration: BoxDecoration(
                                      borderRadius: BorderRadius.only(
                                        topLeft: Radius.circular(15),
                                        topRight: Radius.circular(15),
                                      ),
                                      color: themeModel.theme.backgroundColor),
                                  padding: EdgeInsets.all(20),
                                  child: Wrap(
                                    children: [
                                      Align(
                                        alignment: Alignment.center,
                                        child: Text(
                                            "Are you Sure?",
                                          style: themeModel.theme.textTheme.headline2!,
                                        )



                                      ),
                                      Align(
                                        alignment: Alignment.center,
                                        child: Padding(
                                          padding:const EdgeInsets.all(20),
                                          child: Row(
                                            mainAxisAlignment:
                                            MainAxisAlignment.center,
                                            children: [
                                              DefaultButton(
                                                widget: Text(
                                          "Cancel",
                                            style: themeModel.theme.textTheme.headline3!.apply(
                                              color: themeModel.secondTextColor
                                            ),
                                          ),



                                                onPressed: () {
                                                  Navigator.pop(context);
                                                },
                                                color:
                                                themeModel.secondTextColor,
                                                border: true,
                                              ),
                                              Padding(
                                                padding:
                                                const EdgeInsets.only(left: 20),
                                                child: DefaultButton(
                                                    widget: Text(
                                                        "Delete",
                                                      style: themeModel.theme.textTheme.headline3!.apply(
                                                        color: Colors.white
                                                      ),
                                                    ),
                                                    onPressed: () async {
                                                      await delete();
                                                      Navigator.pop(context);
                                                    },
                                                    color: Colors.red),
                                              ),
                                            ],
                                          ),
                                        ),
                                      )
                                    ],
                                  ),
                                );
                              });
                        }),
                  ),
                ],
              )
            ],
          ),
        ),
      ),
    );
  }
}
