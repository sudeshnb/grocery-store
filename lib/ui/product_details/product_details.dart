import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:grocery/blocs/cart_bloc.dart';
import 'package:grocery/blocs/product_details_bloc.dart';
import 'package:grocery/models/data_models/cart_item.dart';
import 'package:grocery/models/data_models/product.dart';
import 'package:grocery/models/state_models/select_menu_model.dart';
import 'package:grocery/models/state_models/theme_model.dart';
import 'package:grocery/models/data_models/unit.dart';
import 'package:grocery/services/auth.dart';
import 'package:grocery/services/database.dart';
import 'package:grocery/ui/product_details/select_menu.dart';
import 'package:grocery/widgets/buttons/default_button.dart';
import 'package:grocery/widgets/fade_in.dart';
import 'package:grocery/widgets/transparent_image.dart';
import 'package:provider/provider.dart';
import 'package:grocery/ui/home/cart/checkout/checkout.dart';

// ignore: must_be_immutable
class ProductDetails extends StatefulWidget {
  static Future<bool?> create(BuildContext context, Product product) {
    final database = Provider.of<Database>(context, listen: false);

    final auth = Provider.of<AuthBase>(context, listen: false);

    ProductDetailsBloc bloc = ProductDetailsBloc(
      database: database,
      uid: auth.uid,
      unit: Unit(
        title: "Piece",
        price: product.pricePerPiece,
      ),
    );

    return Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) => MultiProvider(
                    providers: [
                      Provider<ProductDetailsBloc>(
                        create: (context) => bloc,
                      ),
                      ChangeNotifierProvider<SelectMenuModel>(
                        create: (context) => SelectMenuModel(
                          pricePerKg: product.pricePerKg,
                          pricePerPiece: product.pricePerPiece,
                          quantity: 1,
                          productDetailsBloc: bloc,
                        ),
                      )
                    ],
                    child: Consumer<ProductDetailsBloc>(
                      builder: (context, bloc, _) {
                        return ProductDetails(product: product, bloc: bloc);
                      },
                    ))));
  }

  final Product product;
  final ProductDetailsBloc bloc;

  const ProductDetails({required this.product, required this.bloc});

  @override
  _ProductDetailsState createState() => _ProductDetailsState();
}

class _ProductDetailsState extends State<ProductDetails>
    with TickerProviderStateMixin {
  ScrollController _scrollController = ScrollController();

  late Stream<List<CartItem>> cartItemStream;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();

    final cartBloc = Provider.of<CartBloc>(context, listen: false);
    cartItemStream = cartBloc.cartItems;
  }

  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width;

    final themeModel = Provider.of<ThemeModel>(context);

    return Scaffold(
        body: ListView(
      controller: _scrollController,
      padding: EdgeInsets.only(bottom: 20),
      children: [
        ///Product title
        AppBar(
          elevation: 0,
          centerTitle: true,
          backgroundColor: Colors.transparent,
          title:Text(
              widget.product.title,
            style: themeModel.theme.textTheme.headline3,
          ),

          leading: IconButton(
            icon: Icon(
              Icons.arrow_back,
              color: themeModel.textColor,
            ),
            onPressed: () {
              Navigator.pop(context);
            },
          ),
          actions: [
            StreamBuilder<List<CartItem>>(
              stream: cartItemStream,
              builder: (context, snapshot) {
                if (snapshot.hasData) {
                  List<String> references =
                      snapshot.data!.map((e) => e.reference).toList();
                  bool addedToCart =
                      references.contains(widget.product.reference);

                  return (addedToCart)
                      ? FadeIn(
                          child: IconButton(
                            icon: Icon(
                              Icons.shopping_cart_outlined,
                              color: themeModel.textColor,
                            ),
                            onPressed: () async {
                              final checkoutResult =
                                  await Checkout.create(context);
                              if (checkoutResult ?? false) {
                                Navigator.pop(context, true);
                              }
                            },
                          ),
                        )
                      : SizedBox();
                } else {
                  return SizedBox();
                }
              },
            ),
          ],
        ),

        ///Product image
        Padding(
          padding: EdgeInsets.all(20),
          child: Hero(
              tag: widget.product.reference,
              child: FadeInImage(
                width: width,
                fit: BoxFit.cover,
                image: NetworkImage(widget.product.image),
                placeholder: MemoryImage(kTransparentImage),
              )),
        ),

        ///Product reference
        FadeIn(
          child: Padding(
            padding: EdgeInsets.only(left: 20, right: 20),
            child: Row(
              children: [
                Text(
                  "Reference: ",
                  style: themeModel.theme.textTheme.headline3!.apply(
                      color: themeModel.accentColor
                  ),
                ),
                Text(
                  widget.product.reference,
                  style: themeModel.theme.textTheme.headline3,
                ),
              ],
            ),
          ),
        ),

        ///Check if product is in cart
        AnimatedSize(
          duration: Duration(milliseconds: 300),
          child: StreamBuilder<List<CartItem>>(
            stream: cartItemStream,
            builder: (context, snapshot) {
              if (snapshot.hasData) {
                List<String> references =
                    snapshot.data!.map((e) => e.reference).toList();
                bool addedToCart =
                    references.contains(widget.product.reference);

                return Column(
                  children: [
                    ///If not added, show select menu
                    (!addedToCart)
                        ? FadeIn(
                            child: SelectMenu.create(),
                          )
                        : SizedBox(),

                    ///If added show "Add to cart" else show "Added"

                    Padding(
                      padding: EdgeInsets.only(left: 20, right: 20),
                      child: FadeIn(
                        child: DefaultButton(
                            color: themeModel.accentColor,
                            widget: Row(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  addedToCart
                                      ? Icons.done
                                      : Icons.add_shopping_cart,
                                  color: Colors.white,
                                ),
                                Padding(
                                  padding: EdgeInsets.only(left: 20),
                                  child:Text(
                                    !addedToCart ? "Add to Cart" : "Added",
                                    style: themeModel.theme.textTheme.headline3!.apply(
                                      color: Colors.white
                                    ),
                                  ),

                                )
                              ],
                            ),
                            onPressed: () {
                              (!addedToCart)
                                  ? widget.bloc
                                      .addToCart(widget.product.reference)
                                      .then((value) {
                                      _scrollController.animateTo(
                                        0.0,
                                        curve: Curves.easeOut,
                                        duration:
                                            const Duration(milliseconds: 300),
                                      );
                                    })
                                  : widget.bloc
                                      .removeFromCart(widget.product.reference)
                                      .then((value) {
                                      _scrollController.animateTo(
                                        0.0,
                                        curve: Curves.easeOut,
                                        duration:
                                            const Duration(milliseconds: 300),
                                      );
                                    });
                            }),
                      ),
                    ),
                  ],
                );
              } else {
                return SizedBox();
              }
            },
          ),
        ),

        FadeIn(
          duration: Duration(milliseconds: 400),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ///Product description
              Padding(
                padding: EdgeInsets.only(left: 20, right: 20, top: 30),
                child: Text(
                    "Description",
                  style: themeModel.theme.textTheme.headline3!.apply(
                    color: themeModel.accentColor
                  ),
                )

              ),
              Padding(
                padding: EdgeInsets.only(left: 20, right: 20, top: 10),
                child: Text(
                    widget.product.description,
                  style: themeModel.theme.textTheme.bodyText1,
                )
              ),

              ///Product storage description

              Padding(
                  padding: EdgeInsets.only(left: 20, right: 20, top: 30),
                  child: Text(
                    "Storage",
                    style: themeModel.theme.textTheme.headline3!.apply(
                        color: themeModel.accentColor
                    ),
                  )

              ),
              Padding(
                  padding: EdgeInsets.only(left: 20, right: 20, top: 10),
                  child: Text(
                    widget.product.storage,
                    style: themeModel.theme.textTheme.bodyText1,
                  )
              ),

              ///Product origin description

              Padding(
                  padding: EdgeInsets.only(left: 20, right: 20, top: 30),
                  child: Text(
                    "Origin",
                    style: themeModel.theme.textTheme.headline3!.apply(
                        color: themeModel.accentColor
                    ),
                  )

              ),
              Padding(
                  padding: EdgeInsets.only(left: 20, right: 20, top: 10),
                  child: Text(
                    widget.product.origin,
                    style: themeModel.theme.textTheme.bodyText1,
                  )
              ),


            ],
          ),
        ),
      ],
    ));
  }
}
