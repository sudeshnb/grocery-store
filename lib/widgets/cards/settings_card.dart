import 'package:flutter/material.dart';
import 'package:grocery/models/state_models/theme_model.dart';
import 'package:provider/provider.dart';

class SettingsCard extends StatelessWidget {
  final String title;
  final IconData iconData;
  final void Function() onTap;

  const SettingsCard({
    required this.title,
    required this.iconData,
    required this.onTap});





  @override
  Widget build(BuildContext context) {
    final themeModel = Provider.of<ThemeModel>(context);

    return Container(
      decoration: BoxDecoration(
          color: themeModel.secondBackgroundColor,
          borderRadius:const BorderRadius.all(Radius.circular(15))),
      margin:const EdgeInsets.only(
        bottom: 10,
        left: 20,
        right: 20,
      ),
      //   padding: EdgeInsets.all(20),
      child: ListTile(
        shape: RoundedRectangleBorder(
          borderRadius:const BorderRadius.all(Radius.circular(15)),
        ),
        onTap: onTap,
        leading: Icon(
          iconData,
          color: themeModel.accentColor,
        ),
        title: Text(
            title,
          style: themeModel.theme.textTheme.bodyText1,
        ),
        trailing: Icon(
          Icons.navigate_next,
          color: themeModel.textColor,
        ),
      ),
    );
  }
}
