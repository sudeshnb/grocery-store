import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';

class SocialButton extends StatelessWidget {
  final String path;
  final Color color;
  final void Function() onPressed;

  const SocialButton(
      {Key? key,
      required this.path,
      required this.color,
      required this.onPressed})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return RawMaterialButton(
      onPressed: onPressed,
      elevation: 1.0,
      fillColor: color,
      child: SvgPicture.asset(
        path,
        height: 20,
      ),
      padding: const EdgeInsets.all(20.0),
      shape: const CircleBorder(),
    );
  }
}
