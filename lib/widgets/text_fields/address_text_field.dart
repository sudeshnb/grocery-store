import 'package:flutter/material.dart';
import 'package:grocery/models/state_models/theme_model.dart';
import 'package:provider/provider.dart';

class AddressTextField extends StatelessWidget {
  final TextEditingController controller;
  final FocusNode focusNode;
  final TextInputType textInputType;
  final TextInputAction textInputAction;
  final String labelText;
  final Function(String) onSubmitted;
  final bool error;
  // ignore: prefer_typing_uninitialized_variables
  final enabled;
  final bool obscureText;

  const AddressTextField(
      {Key? key,
      required this.controller,
      required this.focusNode,
      required this.textInputType,
      required this.textInputAction,
      required this.labelText,
      required this.onSubmitted,
      required this.error,
      required this.enabled,
      this.obscureText = false})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    final themeModel = Provider.of<ThemeModel>(context);

    return Container(
      decoration: BoxDecoration(
          color: themeModel.secondBackgroundColor,
          borderRadius: const BorderRadius.all(Radius.circular(15)),
          border: Border.all(
              color: (error) ? Colors.red : themeModel.secondBackgroundColor,
              width: 2)),
      padding: const EdgeInsets.all(10),
      child: TextField(
        enabled: enabled,
        textCapitalization: TextCapitalization.words,
        keyboardType: textInputType,
        textInputAction: textInputAction,
        controller: controller,
        focusNode: focusNode,
        obscureText: obscureText,
        onSubmitted: onSubmitted,
        onChanged: (value) {},
        decoration: InputDecoration(
            border: InputBorder.none,
            focusedBorder: InputBorder.none,
            enabledBorder: InputBorder.none,
            errorBorder: InputBorder.none,
            disabledBorder: InputBorder.none,
            labelText: labelText,
            contentPadding: const EdgeInsets.only(left: 20, right: 20)),
      ),
    );
  }
}
