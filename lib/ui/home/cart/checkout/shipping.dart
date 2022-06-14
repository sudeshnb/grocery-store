import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:grocery/blocs/shipping_bloc.dart';
import 'package:grocery/models/state_models/checkout_model.dart';
import 'package:grocery/models/data_models/shipping_method.dart';
import 'package:grocery/models/state_models/theme_model.dart';
import 'package:grocery/services/auth.dart';
import 'package:grocery/services/database.dart';
import 'package:grocery/widgets/fade_in.dart';
import 'package:provider/provider.dart';

class Shipping extends StatefulWidget {
  final ShippingBloc bloc;

  const Shipping({required this.bloc});

  static Widget create(BuildContext context, {String? selected}) {
    final auth = Provider.of<AuthBase>(context, listen: false);
    final database = Provider.of<Database>(context, listen: false);
    return Provider<ShippingBloc>(
      create: (context) =>
          ShippingBloc(uid: auth.uid, database: database, selected: selected),
      child: Consumer<ShippingBloc>(
        builder: (context, bloc, _) {
          return Shipping(
            bloc: bloc,
          );
        },
      ),
    );
  }

  @override
  _ShippingState createState() => _ShippingState();
}

class _ShippingState extends State<Shipping>{





  @override
  Widget build(BuildContext context) {

    double width = MediaQuery.of(context).size.width;
    final themeModel = Provider.of<ThemeModel>(context);

    return StreamBuilder<List<ShippingMethod>>(
      stream: widget.bloc.getShippingMethods(),
      builder: (context, shippingSnapshot) {
        if (shippingSnapshot.hasData) {
          List<ShippingMethod> shippingMethods = shippingSnapshot.data!;

          if (shippingMethods.isEmpty) {
            return Center();
          } else {
            final checkoutModel =
                Provider.of<CheckoutModel>(context, listen: false);
            checkoutModel.shippingMethod = shippingMethods
                .where((element) => element.selected == true)
                .single;

            return GridView.builder(
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: width ~/ 180,
              ),
              shrinkWrap: true,
              //   physics: NeverScrollableScrollPhysics(),
              padding:
                  EdgeInsets.only(left: 16, right: 16, top: 20, bottom: 100),
              itemBuilder: (context,position){


                return FadeIn(
                  child: GestureDetector(
                    child: Container(
                      margin: EdgeInsets.all(6),
                      decoration: BoxDecoration(
                          color: themeModel.secondBackgroundColor,
                          borderRadius: BorderRadius.all(Radius.circular(15)),
                          boxShadow: [
                            BoxShadow(
                                blurRadius: 2,
                                offset: Offset(0, 5),
                                color: themeModel.shadowColor)
                          ]),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Padding(
                              padding: EdgeInsets.only(top: 10),
                              child: Text(
                                shippingMethods[position].title,
                                style: themeModel.theme.textTheme.headline3,
                              )

                          ),
                          Padding(
                            padding: EdgeInsets.only(top: 10),
                            child: GestureDetector(
                              child: Text(
                                shippingMethods[position].duration! +
                                    " (${shippingMethods[position].price}\$)",
                                style: themeModel.theme.textTheme.subtitle1!.apply(
                                    color: themeModel.secondTextColor
                                ),
                              ),
                              onTap: () {},
                            ),
                          ),
                          Checkbox(
                            key: Key(shippingMethods[position].title),
                            value: shippingMethods[position].selected,
                            materialTapTargetSize: MaterialTapTargetSize.padded,
                            onChanged: (value) {
                              if (!shippingMethods[position].selected) {
                                widget.bloc.setSelectedShipping(
                                    shippingMethods[position].id!);
                              }
                            },
                          )
                        ],
                      ),
                    ),
                    onTap: () {
                      if (!shippingMethods[position].selected) {
                        widget.bloc.setSelectedShipping(shippingMethods[position].id!);
                      }
                    },
                  ),
                );
              },
              itemCount: shippingMethods.length,
            );
          }
        } else if (shippingSnapshot.hasError) {
          return FadeIn(
            child: Padding(
              padding: EdgeInsets.only(top: 20),
              child: Center(
                child: SvgPicture.asset(
                  'images/state_images/error.svg',
                  width: width * 0.5,
                  fit: BoxFit.cover,
                ),
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
