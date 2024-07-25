import 'package:flutter/material.dart';

class CirclButton extends StatelessWidget {
  final String value;
  final Color? color;
  final VoidCallback press;
  const CirclButton(
      {super.key,
      required this.value,
      required this.press,
      this.color = const Color(0xff251919)});

  static const splashColor = Colors.white24;
  static const textColor = Color(0xffd8c2c0);

  @override
  Widget build(BuildContext context) {
    return InkResponse(
      splashColor: splashColor,
      radius: 15,
      onTap: press,
      child: Container(
        height: 73,
        width: 73,
        decoration: BoxDecoration(shape: BoxShape.circle, color: color),
        child: Center(
          child: Text(
            value,
            style: const TextStyle(fontSize: 24, color: textColor),
          ),
        ),
      ),
    );
  }
}
