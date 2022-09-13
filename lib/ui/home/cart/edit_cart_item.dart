import 'package:decimal/decimal.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:grocery/models/data_models/unit.dart';
import 'package:grocery/models/state_models/edit_cart_model.dart';
import 'package:grocery/models/state_models/theme_model.dart';

class EditCarItem extends StatelessWidget {
  final EditCartModel model;

  const EditCarItem({Key? key, required this.model}) : super(key: key);

  static Widget create({
    required num? pricePerKg,
    required num pricePerPiece,
    required int quantity,
    required Future Function(String, int) updateQuantity,
    required Future Function(String, String) updateUnit,
    required String reference,
    required String initialUnitTitle,
  }) {
    return ChangeNotifierProvider<EditCartModel>(
      create: (context) => EditCartModel(
          pricePerKg: pricePerKg,
          pricePerPiece: pricePerPiece,
          quantity: quantity,
          updateQuantity: updateQuantity,
          unitTitle: initialUnitTitle,
          updateUnit: updateUnit,
          reference: reference),
      child: Consumer<EditCartModel>(
        builder: (context, model, _) {
          return EditCarItem(
            model: model,
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final themeModel = Provider.of<ThemeModel>(context);

    List<Unit> units = model.units;
    int selectedUnit = units.indexOf(
        units.where((unit) => unit.title == model.unitTitle).toList()[0]);

    return Container(
      decoration: BoxDecoration(
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(15),
            topRight: Radius.circular(15),
          ),
          color: themeModel.secondBackgroundColor),
      padding: const EdgeInsets.all(20),
      child: Wrap(
        children: [
          Align(
              alignment: Alignment.center,
              child: Text(
                "Edit",
                style: themeModel.theme.textTheme.headline2,
              )),
          Padding(
            padding: const EdgeInsets.only(top: 20),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      ///Increase quantity button
                      IconButton(
                        icon: Icon(
                          Icons.add,
                          color: themeModel.secondTextColor,
                        ),
                        onPressed: () async {
                          model.add();
                        },
                      ),

                      Text(
                        model.quantity.toString(),
                        style: themeModel.theme.textTheme.headline3,
                      ),

                      ///Decrease quantity button
                      IconButton(
                        icon: Icon(
                          Icons.remove,
                          color: themeModel.secondTextColor,
                        ),
                        onPressed: () async {
                          model.minus();
                        },
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: List.generate(units.length, (index) {
                      return Padding(
                        padding: EdgeInsets.only(
                          top: (index == 0) ? 0 : 10,
                        ),
                        child: GestureDetector(
                            onTap: () {
                              model.selectUnit(index);
                            },
                            child: Text(
                              units[index].title,
                              style: themeModel.theme.textTheme.headline3!
                                  .apply(
                                      color: (selectedUnit == index)
                                          ? themeModel.accentColor
                                          : themeModel.secondTextColor),
                            )),
                      );
                    }),
                  ),
                ),
                Expanded(
                    child: Align(
                  alignment: Alignment.center,
                  child: Text(
                    "${Decimal.parse(model.quantity.toString()) * Decimal.parse(units[selectedUnit].price.toString())}\$",
                    style: themeModel.theme.textTheme.bodyText1!
                        .apply(color: themeModel.priceColor),
                  ),
                ))
              ],
            ),
          )
        ],
      ),
    );
  }
}
