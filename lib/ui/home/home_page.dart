import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:grocery/blocs/home_page_bloc.dart';

import 'package:grocery/models/data_models/category.dart';
import 'package:grocery/models/state_models/home_model.dart';
import 'package:grocery/models/data_models/product.dart';
import 'package:grocery/models/state_models/theme_model.dart';
import 'package:grocery/ui/product_details/product_details.dart';
import 'package:grocery/ui/products_reader.dart';
import 'package:grocery/widgets/cards/category_card.dart';
import 'package:grocery/widgets/cards/product_card.dart';
import 'package:grocery/widgets/dialogs/success_dialog.dart';
import 'package:grocery/widgets/fade_in.dart';
import 'package:grocery/widgets/transparent_image.dart';
import 'package:provider/provider.dart';

// ignore: must_be_immutable
class HomePage extends StatefulWidget {
  final HomePageBloc bloc;

  HomePage({required this.bloc});

  static Widget create() {
    return Consumer<HomePageBloc>(
      builder: (context, bloc, _) {
        return HomePage(
          bloc: bloc,
        );
      },
    );
  }

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {



  ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    // TODO: implement initState
    super.initState();

    widget.bloc.loadProducts(10);
  }

  @override
  Widget build(BuildContext context) {



    double height = MediaQuery.of(context).size.height;
    double width = MediaQuery.of(context).size.width;

    final themeModel = Provider.of<ThemeModel>(context);

    return NotificationListener(
      onNotification: (ScrollNotification notification) {
        if (notification is ScrollEndNotification) {
          if (_scrollController.position.extentAfter == 0) {
            widget.bloc.loadProducts(10);
          }
        }
        return false;
      },
      child: ListView(
        shrinkWrap: true,
        controller: _scrollController,
        padding: EdgeInsets.only(bottom: 60),
        children: [
          Container(
            decoration: BoxDecoration(
                color: themeModel.secondBackgroundColor,
                borderRadius: BorderRadius.only(
                    bottomLeft: Radius.circular(25),
                    bottomRight: Radius.circular(25)),
                boxShadow: [
                  BoxShadow(
                    blurRadius: 30,
                    offset: Offset(0, 5),
                    color: themeModel.shadowColor,
                  )
                ]),
            child: Column(
              children: [
                AppBar(
                  elevation: 0,
                  title: Text(
                      "Store",
                    style: themeModel.theme.textTheme.headline3,
                  )
                  ,

                  centerTitle: true,
                  backgroundColor: Colors.transparent,
                  actions: [
                    IconButton(
                      icon: Icon(
                        Icons.search,
                        color: themeModel.textColor,
                      ),
                      onPressed: () {
                        ///If click to search button
                        final homeModel =
                            Provider.of<HomeModel>(context, listen: false);

                        homeModel.goToPage(1);
                      },
                    )
                  ],
                ),

                ///Featured category
                GestureDetector(
                  onTap: () {
                    ProductReader.create(context,
                        category: widget.bloc.featuredCategory.title);
                  },
                  child: Container(
                    color: Colors.transparent,
                    height: height * 0.6,
                    width: double.infinity,
                    padding: EdgeInsets.all(20),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Expanded(
                          child: FadeInImage(
                            //  height: height*0.35,
                            fit: BoxFit.cover,
                            image:
                                AssetImage(widget.bloc.featuredCategory.image),
                            placeholder: MemoryImage(kTransparentImage),
                          ),
                        ),
                        Padding(
                          padding: EdgeInsets.only(top: 20),
                          child: Text(
                              widget.bloc.featuredCategory.title.replaceFirst(
                                  widget.bloc.featuredCategory.title[0],
                                  widget.bloc.featuredCategory.title[0]
                                      .toUpperCase()),
                            style: themeModel.theme.textTheme.headline2,
                          )
                        ),
                        Padding(
                          padding: EdgeInsets.only(top: 40),
                          child: Text(
                              "Browse",
                            style: themeModel.theme.textTheme.bodyText1!.apply(
                              color: themeModel.secondTextColor
                            ),
                          )
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),

          ///List of categories
          Container(
            height: 180,
            margin: EdgeInsets.only(
              top: 20,
            ),
            width: double.infinity,
            alignment: Alignment.center,
            child: StreamBuilder<List<Category>>(
              stream: widget.bloc.categoriesStream,
              builder: (context, snapshot) {
                if (snapshot.hasData) {
                  List<Category> categories = snapshot.data!;

                  return ListView.builder(
                    shrinkWrap: true,
                    scrollDirection: Axis.horizontal,
                    padding: EdgeInsets.only(left: 20),
                    itemBuilder: (context, position) {
                      return FadeIn(
                        duration: Duration(milliseconds: 250),
                        child:CategoryCard(category: categories[position])

                      );
                    },
                    itemCount: categories.length,
                  );
                } else if (snapshot.hasError) {
                  return SizedBox();
                } else {
                  return Center(
                    child: CircularProgressIndicator(),
                  );
                }
              },
            ),
          ),

          ///List of products
          StreamBuilder<List<Product>>(
              stream: widget.bloc.productsStream,
              builder: (context, snapshot) {
                if (snapshot.hasData) {
                  ///If there are products
                  List<Product> products = snapshot.data!;

                  return GridView.builder(
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: width ~/ 180),
                    shrinkWrap: true,
                    physics: NeverScrollableScrollPhysics(),
                    padding: EdgeInsets.only(
                        left: 16, right: 16, top: 20, bottom: 4),
                    itemBuilder: (context,position){

                      return FadeIn(
                          child: ProductCard(
                              product:  products[position],
                              onTap: () {
                                ProductDetails.create(context, products[position])
                                    .then((value) {
                                  if (value != null) {
                                    showDialog(
                                        context: context,
                                        builder: (context) => const SuccessDialog(
                                            message: "Congratulations!\nYour order is placed!")
                                    ).then((value) {
                                      widget.bloc.removeCart();
                                    });
                                  }
                                });
                              })

                      );
                    },
                    itemCount: products.length,
                  );
                } else {
                  ///If loading
                  return Center(
                    child: Padding(
                      padding: EdgeInsets.all(20),
                      child: CircularProgressIndicator(),
                    ),
                  );
                }
              }),
        ],
      ),
    );
  }


}
