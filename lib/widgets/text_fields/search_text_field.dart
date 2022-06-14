import 'package:flutter/material.dart';
import 'package:grocery/models/state_models/theme_model.dart';
import 'package:provider/provider.dart';

class SearchTextField extends StatelessWidget {
  final TextEditingController textEditingController;
  final Function(String value) onSubmitted;
  final Function(String value) onChanged;

  const SearchTextField({
   required this.textEditingController,
    required this.onSubmitted,
    required  this.onChanged});

  @override
  Widget build(BuildContext context) {
    final themeModel=Provider.of<ThemeModel>(context);

    return Container(
      margin:const EdgeInsets.only(
        top: 10,
      ),
      padding:const EdgeInsets.only(left: 10, right: 10),
      decoration: BoxDecoration(
          color: themeModel.secondBackgroundColor,
          borderRadius:const BorderRadius.all(Radius.circular(15)),
          boxShadow: [
            BoxShadow(
                blurRadius: 5,
                offset: Offset(0, 5),
                color: themeModel.shadowColor)
          ]),
      child: TextField(
        textCapitalization: TextCapitalization.words,
        controller: textEditingController,
        onSubmitted: onSubmitted,
        onChanged: onChanged,
        decoration:const InputDecoration(
            border: InputBorder.none,
            focusedBorder: InputBorder.none,
            enabledBorder: InputBorder.none,
            errorBorder: InputBorder.none,
            disabledBorder: InputBorder.none,
            contentPadding: EdgeInsets.symmetric(vertical: 10, horizontal: 10),
            hintText: 'Search..'),
      ),
    );
  }
}
