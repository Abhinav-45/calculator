import 'package:flutter/material.dart';

class SquareButton extends StatelessWidget {
  final String value;
  final Color? color;
  final VoidCallback press;

  const SquareButton({
    super.key,
    required this.value,
    required this.press,
    this.color = const Color(0xff251919),
  });

  static const splashColor = Colors.white;
  static const textColor = Color(0xffd8c2c0);

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(20),
        splashColor: splashColor,
        onTap: press,
        child: Container(
          height: 80,
          width: 80,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: const Color.fromARGB(255, 173, 144, 144).withOpacity(0.2),
                spreadRadius: 2,
                blurRadius: 4,
                offset: const Offset(2, 2),
              ),
            ],
          ),
          child: Center(
            child: Text(
              value,
              style: const TextStyle(fontSize: 20, color: textColor),
            ),
          ),
        ),
      ),
    );
  }
}
