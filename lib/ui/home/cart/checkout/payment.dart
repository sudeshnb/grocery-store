import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:grocery/models/state_models/payment_model.dart';
import 'package:grocery/models/state_models/theme_model.dart';
import 'package:grocery/widgets/buttons/default_button.dart';
import 'package:grocery/widgets/dialogs/error_dialog.dart';
import 'package:grocery/widgets/fade_in.dart';
import 'package:provider/provider.dart';
import 'package:grocery/services/auth.dart';
import 'package:grocery/services/database.dart';
import 'package:grocery/models/state_models/checkout_model.dart';
import 'package:decimal/decimal.dart';

class Payment extends StatefulWidget {
  final PaymentModel model;

  const Payment({required this.model});

  static Widget create(BuildContext context) {
    final auth = Provider.of<AuthBase>(context);
    final database = Provider.of<Database>(context);
    return ChangeNotifierProvider<PaymentModel>(
      create: (context) => PaymentModel(auth: auth, database: database),
      child: Consumer<PaymentModel>(
        builder: (context, model, _) {
          return Payment(model: model);
        },
      ),
    );
  }

  @override
  _PaymentState createState() => _PaymentState();
}

class _PaymentState extends State<Payment>
    with TickerProviderStateMixin{


  TextEditingController nameController = TextEditingController();
  TextEditingController cardNumberController = TextEditingController();
  TextEditingController cvvController = TextEditingController();

  FocusNode nameFocus = FocusNode();
  FocusNode cardNumberFocus = FocusNode();
  FocusNode cvvFocus = FocusNode();

  @override
  Widget build(BuildContext context) {
    final themeModel = Provider.of<ThemeModel>(context);
    final checkoutModel = Provider.of<CheckoutModel>(context, listen: false);

    num order = checkoutModel.getTotal();
    num total = checkoutModel.getDiscountedTotal();

    return ListView(
      padding: EdgeInsets.only(left: 20, right: 20, bottom: 100, top: 20),
      children: [
        FadeIn(
          duration: Duration(milliseconds: 400),
          child: Container(
            padding: EdgeInsets.all(10),
            margin: EdgeInsets.only(bottom: 10),
            decoration: BoxDecoration(
                color: themeModel.backgroundColor,
                border: Border.all(
                    width: 2,
                    color: (widget.model.paymentViaDelivery)
                        ? themeModel.accentColor
                        : themeModel.secondBackgroundColor),
                borderRadius: BorderRadius.all(Radius.circular(15)),
                boxShadow: [
                  BoxShadow(
                    blurRadius: 2,
                    offset: Offset(0, 5),
                    color: themeModel.shadowColor,
                  )
                ]),
            child: ListTile(
              trailing: Icon(
                FontAwesomeIcons.dollarSign,
                color: themeModel.textColor,
              ),
              tileColor: themeModel.backgroundColor,
              contentPadding: EdgeInsets.all(0),
              onTap: () {
                if (!widget.model.paymentViaDelivery) {
                  widget.model
                      .changePaymentMethod(!widget.model.paymentViaDelivery);
                }
              },
              title: Text(
                "Cash in delivery",
                style: themeModel.theme.textTheme.bodyText1,
              ),
              leading: Checkbox(
                materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                value: widget.model.paymentViaDelivery,
                onChanged: (value) {
                  if (!widget.model.paymentViaDelivery) {
                    widget.model.changePaymentMethod(true);
                  }
                },
              ),
            ),
          ),
        ),
        FadeIn(
          duration: Duration(milliseconds: 400),
          child: Container(
            padding: EdgeInsets.all(10),
            decoration: BoxDecoration(
                color: themeModel.backgroundColor,
                border: Border.all(
                    width: 2,
                    color: (!widget.model.paymentViaDelivery)
                        ? themeModel.accentColor
                        : themeModel.secondBackgroundColor),
                borderRadius: BorderRadius.all(Radius.circular(15)),
                boxShadow: [
                  BoxShadow(
                    blurRadius: 2,
                    offset: Offset(0, 5),
                    color: themeModel.shadowColor,
                  )
                ]),
            child: ListTile(
              trailing: Icon(
                Icons.credit_card_sharp,
                color: themeModel.textColor,
              ),
              tileColor: themeModel.backgroundColor,
              contentPadding: EdgeInsets.all(0),
              onTap: () {
                widget.model
                    .changePaymentMethod(!widget.model.paymentViaDelivery);
              },
              title: Text(
                "Payment via credit card",
                style: themeModel.theme.textTheme.bodyText1,
              ),
              leading: Checkbox(
                materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                value: !widget.model.paymentViaDelivery,
                onChanged: (value) {
                  if (widget.model.paymentViaDelivery) {
                    widget.model.changePaymentMethod(false);
                  }
                },
              ),
            ),
          ),
        ),

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
                  checkoutModel.shippingMethod!.price.toString() + '\$',
                  style: themeModel.theme.textTheme.headline3!
                      .apply(color: themeModel.priceColor),
                ),
              ],
            ),
          ),
        ),

        (checkoutModel.coupon == null)
            ? SizedBox()
            : FadeIn(
                duration: Duration(milliseconds: 400),
                child: Padding(
                  padding: EdgeInsets.only(top: 10),
                  child: Row(
                    children: [
                      Text(
                        'Coupon:',
                        style: themeModel.theme.textTheme.bodyText1,
                      ),
                      Spacer(),
                      Text(
                        "-" +
                            Decimal.parse(
                                    checkoutModel.coupon!.value.toString())
                                .toString() +
                            ((checkoutModel.coupon!.type == "percentage")
                                ? "%"
                                : "\$"),
                        style: themeModel.theme.textTheme.headline3!
                            .apply(color: themeModel.priceColor),
                      ),
                    ],
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
                  style: themeModel.theme.textTheme.bodyText1,
                ),
                Spacer(),
                Text(
                  total.toString() + '\$',
                  style: themeModel.theme.textTheme.headline3!
                      .apply(color: themeModel.priceColor),
                ),
              ],
            ),
          ),
        ),

        (widget.model.isLoading)
            ? Center(
                child: CircularProgressIndicator(),
              )
            : FadeIn(
                duration: Duration(milliseconds: 400),
                child: DefaultButton(
                    color: themeModel.accentColor,
                    widget: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.arrow_forward,
                          color: Colors.white,
                        ),
                        Padding(
                            padding: EdgeInsets.only(left: 10),
                            child: Text(
                              "Confirm Order",
                              style: themeModel.theme.textTheme.headline3!
                                  .apply(color: Colors.white),
                            ))
                      ],
                    ),
                    onPressed: () async {
                      if (!widget.model.paymentViaDelivery) {
                        if (total < 0.5) {
                          showDialog(
                              context: context,
                              builder: (context) => ErrorDialog(
                                  message:
                                      "You can't make payment under 0.5\$"));
                        } else {
                          widget.model.submit(context,
                              address: checkoutModel.address!,
                              shippingMethod: checkoutModel.shippingMethod!,
                              cartItems: checkoutModel.cartItems!,
                              order: order,
                              coupon: checkoutModel.coupon);
                        }
                      } else {
                        widget.model.submit(context,
                            address: checkoutModel.address!,
                            shippingMethod: checkoutModel.shippingMethod!,
                            cartItems: checkoutModel.cartItems!,
                            order: order,
                            coupon: checkoutModel.coupon);
                      }
                    }),
              )
      ],
    );
  }
}
