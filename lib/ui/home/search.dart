import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:provider/provider.dart';

import 'package:grocery/blocs/search_bloc.dart';
import 'package:grocery/models/data_models/product.dart';
import 'package:grocery/models/state_models/home_model.dart';
import 'package:grocery/models/state_models/theme_model.dart';
import 'package:grocery/services/auth.dart';
import 'package:grocery/services/database.dart';
import 'package:grocery/ui/product_details/product_details.dart';
import 'package:grocery/widgets/cards/product_card.dart';
import 'package:grocery/widgets/dialogs/success_dialog.dart';
import 'package:grocery/widgets/fade_in.dart';
import 'package:grocery/widgets/text_fields/search_text_field.dart';

class Search extends StatefulWidget {
  final SearchBloc bloc;

  const Search({
    Key? key,
    required this.bloc,
  }) : super(key: key);

  static Widget create(BuildContext context) {
    final database = Provider.of<Database>(context);
    final auth = Provider.of<AuthBase>(context);
    return Provider<SearchBloc>(
      create: (context) => SearchBloc(database: database, auth: auth),
      child: Consumer<SearchBloc>(
        builder: (context, bloc, _) {
          return Search(
            bloc: bloc,
          );
        },
      ),
    );
  }

  @override
  _SearchState createState() => _SearchState();
}

class _SearchState extends State<Search> {
  TextEditingController searchController = TextEditingController();

  ScrollController scrollController = ScrollController();

  @override
  Widget build(BuildContext context) {
    final themeModel = Provider.of<ThemeModel>(context);
    double width = MediaQuery.of(context).size.width;

    return NotificationListener(
        onNotification: (ScrollNotification notification) {
          if (notification is ScrollEndNotification) {
            if (scrollController.position.extentAfter == 0) {
              if (searchController.text.isNotEmpty) {
                widget.bloc.loadProducts(searchController.text, 10);
              }
            }
          }
          return false;
        },
        child: ListView(
          controller: scrollController,
          physics: const AlwaysScrollableScrollPhysics(),
          children: [
            Padding(
              padding: const EdgeInsets.all(20),
              child: Align(
                  alignment: Alignment.center,
                  child: Text(
                    "Search",
                    style: themeModel.theme.textTheme.headline3,
                  )),
            ),

            ///Search field
            Padding(
              padding: const EdgeInsets.only(left: 20, right: 20),
              child: SearchTextField(
                  textEditingController: searchController,
                  onChanged: (value) {
                    if (searchController.text.length == 1) {
                      if (searchController.text[0] !=
                          searchController.text[0].toUpperCase()) {
                        searchController.text = searchController.text
                            .replaceFirst(searchController.text[0],
                                searchController.text[0].toUpperCase());
                        searchController.selection = TextSelection.fromPosition(
                            TextPosition(offset: searchController.text.length));
                      }
                    }
                  },
                  onSubmitted: (value) {
                    if (searchController.text.isNotEmpty) {
                      widget.bloc.clearHistory();
                      widget.bloc.loadProducts(searchController.text, 10);
                    }

                    setState(() {});
                  }),
            ),

            /// if there is data in textField
            (searchController.text.isNotEmpty)
                ? StreamBuilder<List<Product>>(
                    stream: widget.bloc.productsStream,
                    builder: (context, snapshot) {
                      if (snapshot.hasData) {
                        List<Product> products = snapshot.data!;

                        if (products.isEmpty) {
                          ///If nothing found
                          return Padding(
                            padding: const EdgeInsets.only(top: 50),
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
                                        child: Text('Nothing found!',
                                            style: themeModel
                                                .theme.textTheme.headline3!
                                                .apply(
                                                    color:
                                                        themeModel.accentColor),
                                            textAlign: TextAlign.center))
                                  ]),
                            ),
                          );
                        } else {
                          ///If there are products
                          return GridView.count(
                            crossAxisCount: width ~/ 180,
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            padding: const EdgeInsets.only(
                                left: 16, right: 16, top: 20, bottom: 80),
                            children:
                                List.generate(snapshot.data!.length, (index) {
                              return FadeIn(
                                child: ProductCard(
                                    product: products[index],
                                    onTap: () {
                                      ProductDetails.create(
                                              context, products[index])
                                          .then((value) {
                                        if (value != null) {
                                          final homeModel =
                                              Provider.of<HomeModel>(context,
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
                                    }),
                              );
                            }),
                          );
                        }
                      } else if (snapshot.hasError) {
                        ///If there is an error
                        return FadeIn(
                          child: Center(
                              child: Padding(
                            padding: const EdgeInsets.only(top: 50),
                            child: SvgPicture.asset(
                              'images/state_images/error.svg',
                              width: width * 0.5,
                              fit: BoxFit.cover,
                            ),
                          )),
                        );
                      } else {
                        ///If Loading
                        return const Center(
                          child: CircularProgressIndicator(),
                        );
                      }
                    },
                  )
                : const SizedBox(),
          ],
        ));
  }
}
