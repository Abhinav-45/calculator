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
        borderRadius:
            BorderRadius.circular(20), // Match border radius of button
        splashColor: splashColor,
        onTap: press,
        child: Container(
          height: 80,
          width: 80,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(20), // Rounded corners
            boxShadow: [
              BoxShadow(
                color: Color.fromARGB(255, 173, 144, 144)
                    .withOpacity(0.2), // Shadow color
                spreadRadius: 2,
                blurRadius: 4,
                offset: Offset(2, 2), // Shadow offset
              ),
            ],
          ),
          child: Center(
            child: Text(
              value,
              style: TextStyle(
                  fontSize: 20, color: textColor), // Adjusted text size
            ),
          ),
        ),
      ),
    );
  }
}
