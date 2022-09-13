import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:provider/provider.dart';

import 'package:grocery/blocs/orders_bloc.dart';
import 'package:grocery/models/data_models/orders_item.dart';
import 'package:grocery/models/state_models/theme_model.dart';
import 'package:grocery/services/auth.dart';
import 'package:grocery/services/database.dart';
import 'package:grocery/ui/orders/orders_card.dart';
import 'package:grocery/widgets/fade_in.dart';

class Orders extends StatefulWidget {
  final OrdersBloc bloc;

  const Orders({
    Key? key,
    required this.bloc,
  }) : super(key: key);

  static create(BuildContext context) {
    final database = Provider.of<Database>(context, listen: false);
    final auth = Provider.of<AuthBase>(context, listen: false);
    Navigator.push(context, CupertinoPageRoute(builder: (context) {
      return Provider<OrdersBloc>(
        create: (context) => OrdersBloc(database: database, uid: auth.uid),
        child: Consumer<OrdersBloc>(
          builder: (context, bloc, _) {
            return Orders(bloc: bloc);
          },
        ),
      );
    }));
  }

  @override
  _OrdersState createState() => _OrdersState();
}

class _OrdersState extends State<Orders> {
  ScrollController scrollController = ScrollController();

  @override
  void initState() {
    super.initState();

    widget.bloc.loadProducts(10);
  }

  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width;
    final themeModel = Provider.of<ThemeModel>(context, listen: false);
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "My orders",
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
      ),
      body: NotificationListener(
        onNotification: (ScrollNotification notification) {
          if (notification is ScrollEndNotification) {
            if (scrollController.position.extentAfter == 0) {
              widget.bloc.loadProducts(10);
            }
          }
          return false;
        },
        child: StreamBuilder<List<OrdersItem>>(
          stream: widget.bloc.ordersStream,
          builder: (context, snapshot) {
            if (snapshot.hasData) {
              if (snapshot.data!.isEmpty) {
                ///If no orders
                return Center(
                  child: FadeIn(
                    child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          SvgPicture.asset(
                            'images/state_images/nothing_found.svg',
                            width: width * 0.5,
                            fit: BoxFit.cover,
                          ),
                          Padding(
                              padding: const EdgeInsets.only(top: 30),
                              child: Text(
                                'No order found!',
                                style: themeModel.theme.textTheme.headline3!
                                    .apply(color: themeModel.accentColor),
                              ))
                        ]),
                  ),
                );
              } else {
                ///If there are orders
                List<OrdersItem> orders = snapshot.data!;

                return ListView.builder(
                  controller: scrollController,
                  physics: const AlwaysScrollableScrollPhysics(),
                  padding: const EdgeInsets.only(bottom: 20),
                  itemCount: orders.length,
                  itemBuilder: (context, position) {
                    return FadeIn(
                      child: OrdersCard.create(order: orders[position]),
                    );
                  },
                );
              }
            } else if (snapshot.hasError) {
              ///If there is an error
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
              ///If loading
              return const Center(
                child: CircularProgressIndicator(),
              );
            }
          },
        ),
      ),
    );
  }
}
