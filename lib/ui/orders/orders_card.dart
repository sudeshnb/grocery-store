import 'package:flutter/material.dart';
import 'package:grocery/models/state_models/orders_card_model.dart';
import 'package:grocery/models/data_models/orders_item.dart';
import 'package:grocery/models/data_models/orders_product_item.dart';
import 'package:grocery/models/state_models/theme_model.dart';
import 'package:grocery/widgets/fade_in.dart';
import 'package:provider/provider.dart';

class OrdersCard extends StatefulWidget {
  final OrdersCardModel model;
  final OrdersItem order;

  const OrdersCard({required this.model, required this.order});

  static Widget create({required OrdersItem order}) {
    return ChangeNotifierProvider<OrdersCardModel>(
      create: (context) => OrdersCardModel(),
      child: Consumer<OrdersCardModel>(
        builder: (context, model, _) {
          return OrdersCard(
            model: model,
            order: order,
          );
        },
      ),
    );
  }

  @override
  _OrdersCardState createState() => _OrdersCardState();
}

class _OrdersCardState extends State<OrdersCard>
    with TickerProviderStateMixin<OrdersCard> {
  @override
  Widget build(BuildContext context) {

    final themeModel = Provider.of<ThemeModel>(context, listen: false);

    List<OrdersProductItem> products = widget.order.products;

    return AnimatedSize(
      duration: Duration(milliseconds: 400),
      curve: Curves.ease,
      child: GestureDetector(
        onTap: () {
          ///Shrink or expand widget
          widget.model.updateWidget();
        },
        child: Container(
          margin: EdgeInsets.only(left: 20, right: 20, top: 20),
          padding: EdgeInsets.only(left: 20, right: 20, top: 10, bottom: 10),
          decoration: BoxDecoration(
              color: themeModel.secondBackgroundColor,
              borderRadius: BorderRadius.all(Radius.circular(15)),
              boxShadow: [
                BoxShadow(
                    blurRadius: 30,
                    offset: Offset(0, 5),
                    color: themeModel.shadowColor)
              ]),
          child: Column(
            children: [
              Row(
                children: [
                  ///Order number
                  Expanded(
                      child: Text(
                    "Order #" + widget.order.id,
                    style: themeModel.theme.textTheme.headline3,
                  )),

                //  Spacer(),
                  IconButton(
                      icon: Icon(
                        (widget.model.isExpended)
                            ? Icons.keyboard_arrow_up
                            : Icons.keyboard_arrow_down,
                        color: themeModel.textColor,
                      ),
                      onPressed: () {
                        widget.model.updateWidget();
                      }),
                ],
              ),
              (widget.model.isExpended)
                  ? FadeIn(
                      child: Column(
                        children: [
                          Row(
                            children: [
                              ///Order date
                              Text(
                                  "Date: ",
                                style: themeModel.theme.textTheme.bodyText2,
                              ),

                              Spacer(),
                              Text(
                                "${widget.order.date}",
                                style: themeModel.theme.textTheme.bodyText2!.apply(
                                  color: themeModel.secondTextColor
                                ),
                              ),

                            ],
                          ),

                          ///List or orders
                          Padding(
                            padding: EdgeInsets.only(top: 10),
                            child: Column(
                              children:
                                  List.generate(products.length, (position) {
                                return Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [

                                    Expanded(
                                      child: Text(
                                        products[position].title,
                                        style: themeModel.theme.textTheme.bodyText2,
                                      ),

                                    ),
                                    Expanded(
                                      child: Padding(
                                          padding:
                                          EdgeInsets.only(left: 10, right: 10),
                                          child: Text(
                                            products[position].quantity,
                                            style: themeModel.theme.textTheme.bodyText2!.apply(
                                                color: themeModel.secondTextColor
                                            ),
                                          )
                                      ),

                                    ),
                                    Expanded(
                                      child:Align(
                                        alignment: Alignment.centerRight,

                                        child: Text(
                                          products[position].price.toString() +
                                              "\$",
                                          style: themeModel.theme.textTheme.bodyText2!.apply(
                                              color: themeModel.priceColor
                                          ),
                                        ),
                                      ))

                                  ],
                                );
                              }),
                            ),
                          ),

                          ///Order status
                          Padding(
                            padding: EdgeInsets.only(top: 10),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Container(
                                  decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      color: (widget.order.status ==
                                              'Delivered')
                                          ? Colors.green
                                          : (widget.order.status == 'Declined')
                                              ? Colors.red
                                              : Colors.orange),
                                  padding: EdgeInsets.all(5),
                                  margin: EdgeInsets.only(right: 10),
                                  child: Icon(
                                    (widget.order.status == 'Delivered')
                                        ? Icons.done
                                        : (widget.order.status == 'Declined')
                                            ? Icons.clear
                                            : Icons.pending_outlined,
                                    size: 20,
                                    color: Colors.white,
                                  ),
                                ),

                                Text(
                                    widget.order.status,
                                  style: themeModel.theme.textTheme.headline3!.apply(
                                    color: (widget.order.status == 'Delivered')
                                        ? Colors.green
                                        : (widget.order.status == 'Declined')
                                        ? Colors.red
                                        : Colors.orange
                                  ),
                                )

                              ],
                            ),
                          ),

                          ///Admin comment
                          (widget.order.adminComment == null)
                              ? SizedBox()
                              : Padding(
                                  padding: EdgeInsets.only(top: 5),
                                  child: Align(
                                    alignment: Alignment.centerLeft,
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          "Admin comment:",
                                          style: themeModel.theme.textTheme.bodyText2,
                                        ),
                                        Text(
                                          widget.order.adminComment!,
                                          style: themeModel.theme.textTheme.bodyText1!.apply(
                                            color: themeModel.secondTextColor
                                          ),
                                        ),

                                      ],
                                    ),
                                  ),
                                ),

                          ///Delivery Comment
                          (widget.order.deliveryComment == null)
                              ? SizedBox()
                              : Padding(
                                  padding: EdgeInsets.only(top: 5),
                                  child: Align(
                                    alignment: Alignment.centerLeft,
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          "Delivery comment:",
                                          style: themeModel.theme.textTheme.bodyText2,
                                        ),
                                        Text(
                                          widget.order.deliveryComment!,
                                          style: themeModel.theme.textTheme.bodyText1!.apply(
                                              color: themeModel.secondTextColor
                                          ),
                                        ),


                                      ],
                                    ),
                                  ),
                                ),

                          ///Payment method
                          Padding(
                            padding: EdgeInsets.only(top: 5),
                            child: Align(
                              alignment: Alignment.centerLeft,
                              child: Wrap(
                                children: [
                                  Text(
                                    "Payment method: ",
                                    style: themeModel.theme.textTheme.bodyText2,
                                  ),
                                  Text(
                                    widget.order.paymentMethod,
                                    style: themeModel.theme.textTheme.bodyText1!.apply(
                                        color: themeModel.priceColor
                                    ),
                                  ),

                                ],
                              ),
                            ),
                          ),

                          ///Delivery price
                          Padding(
                            padding: EdgeInsets.only(top: 5),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: [
                                Text(
                                  "Delivery:",
                                  style: themeModel.theme.textTheme.bodyText2,
                                ),


                                Container(
                                  alignment: Alignment.centerRight,
                                  padding: EdgeInsets.only(left: 10),
                                  child: Text(
                                    widget.order.shippingMethod.price
                                        .toString() +
                                        "\$",
                                    style: themeModel.theme.textTheme.bodyText1!.apply(
                                        color: themeModel.priceColor
                                    ),
                                  ),

                                ),
                              ],
                            ),
                          ),

                          ///Coupon
                          (widget.order.coupon == null)
                              ? SizedBox()
                              : Padding(
                                  padding: EdgeInsets.only(top: 5),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    children: [

                                      Text(
                                        "Coupon:",
                                        style: themeModel.theme.textTheme.bodyText2,
                                      ),


                                      Container(
                                        alignment: Alignment.centerRight,
                                        padding: EdgeInsets.only(left: 10),
                                        child: Text(
                                          (widget.order.coupon!.value)
                                              .toString() +
                                              ((widget.order.coupon!.type ==
                                                  "percentage")
                                                  ? "%"
                                                  : "\$"),
                                          style: themeModel.theme.textTheme.bodyText1!.apply(
                                              color: themeModel.priceColor
                                          ),
                                        ),

                                      ),


                                    ],
                                  ),
                                ),

                          ///Total price
                          Padding(
                            padding: EdgeInsets.only(top: 5),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: [




                                Text(
                                  "Total:",
                                  style: themeModel.theme.textTheme.bodyText2,
                                ),


                                Container(
                                  alignment: Alignment.centerRight,
                                  padding: EdgeInsets.only(left: 10),
                                  child: Text(
                                    (widget.order.total).toString() + "\$",
                                    style: themeModel.theme.textTheme.bodyText1!.apply(
                                        color: themeModel.priceColor
                                    ),
                                  ),

                                ),





                              ],
                            ),
                          )
                        ],
                      ),
                    )
                  : SizedBox(),
            ],
          ),
        ),
      ),
    );
  }
}
