import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:grocery/blocs/addresses_bloc.dart';
import 'package:grocery/models/data_models/address.dart';
import 'package:grocery/models/state_models/theme_model.dart';
import 'package:grocery/ui/addresses/add_address.dart';
import 'package:grocery/widgets/buttons/default_button.dart';

class AddressCard extends StatelessWidget {
  final Address address;
  const AddressCard({
    Key? key,
    required this.address,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final themeModel = Provider.of<ThemeModel>(context);
    final bloc = Provider.of<AddressesBloc>(context);

    return GestureDetector(
      child: Container(
        margin: const EdgeInsets.only(top: 10),
        decoration: BoxDecoration(
            color: themeModel.secondBackgroundColor,
            borderRadius: const BorderRadius.all(Radius.circular(15)),
            boxShadow: [
              BoxShadow(
                  blurRadius: 2,
                  offset: const Offset(0, 5),
                  color: themeModel.shadowColor)
            ]),
        child: Stack(
          children: [
            Padding(
              padding: const EdgeInsets.only(
                  left: 20, right: 10, bottom: 10, top: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    address.name,
                    style: themeModel.theme.textTheme.headline3,
                  ),
                  Padding(
                      padding: const EdgeInsets.only(top: 10),
                      child: Text(
                        address.address,
                        style: themeModel.theme.textTheme.bodyText1!.apply(
                          color: themeModel.secondTextColor,
                        ),
                      )),
                  Padding(
                      padding: const EdgeInsets.only(top: 10),
                      child: Text(
                        "${address.city == null ? "" : address.city! + ", "}${address.state}, ${address.country}, ${address.zipCode} ",
                        style: themeModel.theme.textTheme.bodyText1!
                            .apply(color: themeModel.secondTextColor),
                      )),
                  Row(
                    children: [
                      Text(
                        address.phone,
                        style: themeModel.theme.textTheme.bodyText1!
                            .apply(color: themeModel.secondTextColor),
                      ),
                      const Spacer(),
                      Checkbox(
                        key: Key(address.id),
                        value: address.selected,
                        onChanged: (value) {
                          if (!address.selected) {
                            bloc.setSelectedAddress(address.id);
                          }
                        },
                      )
                    ],
                  ),
                ],
              ),
            ),
            Align(
              alignment: Alignment.topRight,
              child: IconButton(
                icon: Icon(
                  Icons.close,
                  color: themeModel.secondTextColor,
                ),
                onPressed: () {
                  ///Show delete dialog when clicking
                  showModalBottomSheet(
                      context: context,
                      builder: (context) {
                        return Container(
                          decoration: BoxDecoration(
                              borderRadius: const BorderRadius.only(
                                topLeft: Radius.circular(15),
                                topRight: Radius.circular(15),
                              ),
                              color: themeModel.theme.backgroundColor),
                          padding: const EdgeInsets.all(20),
                          child: Wrap(
                            children: [
                              Align(
                                alignment: Alignment.center,
                                child: Text(
                                  "Are you Sure?",
                                  style: themeModel.theme.textTheme.headline2!,
                                ),
                              ),
                              Align(
                                alignment: Alignment.center,
                                child: Padding(
                                  padding: const EdgeInsets.all(20),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      DefaultButton(
                                        widget: Text(
                                          "Cancel",
                                          style: themeModel
                                              .theme.textTheme.headline3!
                                              .apply(
                                                  color: themeModel
                                                      .secondTextColor),
                                        ),
                                        onPressed: () {
                                          Navigator.pop(context);
                                        },
                                        color: themeModel.secondTextColor,
                                        border: true,
                                      ),
                                      Padding(
                                        padding:
                                            const EdgeInsets.only(left: 20),
                                        child: DefaultButton(
                                            widget: Text(
                                              "Delete",
                                              style: themeModel
                                                  .theme.textTheme.headline3!
                                                  .apply(color: Colors.white),
                                            ),
                                            onPressed: () async {
                                              await bloc
                                                  .deleteAddress(address.id);
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
                },
              ),
            ),
          ],
        ),
      ),
      onTap: () {
        AddAddress.create(context, address: address);
      },
    );
  }
}
