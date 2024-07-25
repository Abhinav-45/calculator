import 'package:flutter/material.dart';

class CirclButton extends StatelessWidget {
  final String value;
  final Color? color;
  final VoidCallback press;
  const CirclButton(
      {required this.value,
      required this.press,
      this.color = const Color(0xff251919)});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: InkResponse(
        splashColor: Colors.white24,
        radius: 15,
        onTap: press,
        child: Container(
          height: 73,
          decoration: BoxDecoration(shape: BoxShape.circle, color: color),
          child: Center(
            child: Text(
              value,
              style: TextStyle(fontSize: 25, color: Color(0xffd8c2c0)),
            ),
          ),
        ),
      ),
    );
  }
}
