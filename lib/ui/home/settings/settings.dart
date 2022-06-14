import 'package:flutter/material.dart';
import 'package:grocery/models/state_models/settings_model.dart';
import 'package:grocery/models/state_models/theme_model.dart';
import 'package:grocery/services/auth.dart';
import 'package:grocery/services/database.dart';

import 'package:grocery/ui/addresses/addresses.dart';
import 'package:grocery/ui/home/settings/update_info.dart';
import 'package:grocery/ui/home/settings/upload_image.dart';
import 'package:grocery/ui/orders/orders.dart';
import 'package:grocery/widgets/cards/settings_card.dart';
import 'package:grocery/widgets/dialogs/reminder_dialog.dart';
import 'package:grocery/widgets/transparent_image.dart';
import 'package:provider/provider.dart';

class Settings extends StatelessWidget {
  final SettingsModel model;

  const Settings({required this.model});

  static Widget create(BuildContext context) {
    final auth = Provider.of<AuthBase>(context);
    final database = Provider.of<Database>(context);
    return ChangeNotifierProvider<SettingsModel>(
      create: (context) => SettingsModel(auth: auth, database: database),
      child: Consumer<SettingsModel>(builder: (context, model, _) {
        return Settings(
          model: model,
        );
      }),
    );
  }

  @override
  Widget build(BuildContext context) {
    final themeModel = Provider.of<ThemeModel>(context);
    return ListView(
      children: [
        ///Profile information
        Container(
          margin: EdgeInsets.only(bottom: 20),
          padding: EdgeInsets.all(20),
          decoration: BoxDecoration(
              color: themeModel.secondBackgroundColor,
              borderRadius: BorderRadius.only(
                  bottomRight: Radius.circular(15),
                  bottomLeft: Radius.circular(15)),
              boxShadow: [
                BoxShadow(
                    blurRadius: 30,
                    offset: Offset(0, 5),
                    color: themeModel.shadowColor)
              ]),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              GestureDetector(
                onTap: () {
                  UploadImage.create(context).then((value) {
                    if (value ?? false) {
                      model.updateWidget();
                    }
                  });
                },
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(30),
                  child: FadeInImage(
                    placeholder: MemoryImage(kTransparentImage),
                    image: (model.profileImage != null)
                        ? NetworkImage(model.profileImage!)
                        : AssetImage('images/settings/profile.png')
                            as ImageProvider,
                    width: 60,
                    height: 60,
                    fit: BoxFit.cover,
                  ),
                ),
              ),
              Expanded(child: GestureDetector(
                onTap: () {
                  UpdateInfo.create(context).then((value) {
                    if (value != null) {
                      model.updateWidget();
                    }
                  });
                },
                child: Container(
                  color: Colors.transparent,
                  padding: EdgeInsets.only(left: 10),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                          padding: EdgeInsets.only(bottom: 2),
                          child: Text(
                            model.displayName ?? '',
                            style: themeModel.theme.textTheme.headline3,
                          )),
                      Text(
                        model.email ?? '',
                        style: themeModel.theme.textTheme.bodyText1!
                            .apply(color: themeModel.secondTextColor),
                      )
                    ],
                  ),
                ),
              )),
              IconButton(
                onPressed: () async{
                 /* UpdateInfo.create(context).then((value) {
                    if (value != null) {
                      model.updateWidget();
                    }
                  });

                  */


                },
                icon: Icon(
                  Icons.edit,
                  color: themeModel.textColor,
                ),
              ),
            ],
          ),
        ),

        ///Orders
        SettingsCard(
            title: "My orders",
            iconData: Icons.view_headline,
            onTap: () {
              Orders.create(context);
            }),

        ///Addresses
        SettingsCard(
            title: "My addresses",
            iconData: Icons.location_on,
            onTap: () {
              Addresses.createWithScaffold(context);
            }),

        ///Live chat: this features will be added soon
        SettingsCard(
            title: "Live chat",
            iconData: Icons.chat,
            onTap: () {
              showDialog(
                  context: context,
                  builder: (context) => const ReminderDialog(
                      message: 'This feature will be added soon'));
            }),

        /// Dark <--> Light mode switch button
        Container(
          decoration: BoxDecoration(
              color: themeModel.secondBackgroundColor,
              borderRadius: BorderRadius.all(Radius.circular(15))),

          margin: EdgeInsets.only(
            bottom: 10,
            left: 20,
            right: 20,
          ),
          //   padding: EdgeInsets.all(20),
          child: ListTile(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.all(Radius.circular(15)),
            ),
            onTap: () {
              themeModel.updateTheme();
            },
            leading: Icon(
              Icons.star_border,
              color: themeModel.accentColor,
            ),
            title: Text(
              'Dark mode',
              style: themeModel.theme.textTheme.bodyText1,
            ),
            trailing: Switch(
              activeColor: themeModel.accentColor,
              value: themeModel.theme.brightness == Brightness.dark,
              onChanged: (value) {
                themeModel.updateTheme();
              },
            ),
          ),
        ),

        ///Logout
        Container(
          decoration: BoxDecoration(
              color: themeModel.secondBackgroundColor,
              borderRadius: BorderRadius.all(Radius.circular(15))),

          margin: EdgeInsets.only(bottom: 40, left: 20, right: 20, top: 20),
          //   padding: EdgeInsets.all(20),
          child: ListTile(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.all(Radius.circular(15)),
              ),
              onTap: () {
                model.signOut(context);
              },
              leading: Icon(
                Icons.exit_to_app,
                color: Colors.red,
              ),
              title: Text(
                'Logout',
                style: themeModel.theme.textTheme.bodyText1,
              )),
        ),
      ],
    );
  }
}
