import 'package:decimal/decimal.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:grocery/models/state_models/select_menu_model.dart';
import 'package:grocery/models/state_models/theme_model.dart';
import 'package:grocery/models/data_models/unit.dart';
import 'package:grocery/widgets/fade_in.dart';
import 'package:provider/provider.dart';

class SelectMenu extends StatefulWidget {
  final SelectMenuModel model;

  static Widget create() {
    return Consumer<SelectMenuModel>(
      builder: (context, model, _) {
        return SelectMenu(
          model: model,
        );
      },
    );
  }

  const SelectMenu({required this.model});

  @override
  _SelectMenuState createState() => _SelectMenuState();
}

class _SelectMenuState extends State<SelectMenu>
    with TickerProviderStateMixin<SelectMenu> {
  @override
  Widget build(BuildContext context) {
    final themeModel = Provider.of<ThemeModel>(context);

    List<Unit> units = widget.model.units;

    return Container(
      margin: EdgeInsets.only(left: 20, right: 20, top: 20),
      padding: EdgeInsets.all(20),
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
              Expanded(
                  child: Text(
                    "Quantity",
                    style: themeModel.theme.textTheme.headline3,
                  )),
              Expanded(
                  child: Align(
                    alignment: Alignment.center,
                    child: Text(
                      "${widget.model.quantity} ${units[widget.model.selectedUnit].title}",
                      style: themeModel.theme.textTheme.headline3,
                    ),
                  )),
              Expanded(
                child: Align(
                  alignment: Alignment.centerRight,
                  child: IconButton(
                    icon: Icon(
                      (widget.model.isOpen)
                          ? Icons.keyboard_arrow_up
                          : Icons.keyboard_arrow_down,
                      color: themeModel.textColor,
                    ),
                    padding: EdgeInsets.all(0),
                    onPressed: () {
                      widget.model.updateWidgetStatus();
                    },
                  ),
                ),
              )
            ],
          ),
          (widget.model.isOpen)
              ? FadeIn(
                  child: Padding(
                    padding: EdgeInsets.only(top: 20),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              IconButton(
                                icon: Icon(
                                  Icons.add,
                                  color: themeModel.textColor,
                                ),

                                ///Increase quantity
                                onPressed: () {
                                  widget.model.add();
                                },
                              ),
                              Padding(
                                  padding: EdgeInsets.only(left: 18, right: 18),
                                  child: Text(
                                    widget.model.quantity.toString(),
                                    style: themeModel.theme.textTheme.headline3,
                                  )),
                              IconButton(
                                icon: Icon(
                                  Icons.remove,
                                  color: themeModel.textColor,
                                ),

                                ///Decrease quantity
                                onPressed: () {
                                  widget.model.minus();
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
                                    ///Change Unit
                                    onTap: () {
                                      widget.model.selectUnit(index);
                                    },
                                    child: Text(units[index].title,
                                        style: themeModel
                                            .theme.textTheme.headline3!
                                            .apply(
                                                color: (widget.model
                                                            .selectedUnit ==
                                                        index)
                                                    ? themeModel.accentColor
                                                    : themeModel.textColor)),
                                  ));
                            }),
                          ),
                        ),
                        Expanded(
                            child: Align(
                              alignment: Alignment.centerRight,

                              child: Text(
                                "${(Decimal.parse(widget.model.quantity.toString())) * Decimal.parse(units[widget.model.selectedUnit].price.toString())}\$",
                                style: themeModel.theme.textTheme.bodyText1!
                                    .apply(color: themeModel.priceColor),
                              ),
                            ))
                      ],
                    ),
                  ),
                )
              : SizedBox(),
        ],
      ),
    );
  }
}
