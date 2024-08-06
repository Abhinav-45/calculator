import 'package:calculator/screens/history.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:math_expressions/math_expressions.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../utils/device_info.dart';
import '../widgets/buttons.dart';

import 'package:shared_preferences/shared_preferences.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  var question = '';
  var answer = '';
  bool isDegree = false;
  bool showScientificButtons = false;
  bool isInverse = false; // Track if inverse functions are active

  String devID = '';

  static const backgroundColor = Color(0xff141414);
  static const buttonColor1 = Color(0xff594319);
  static const buttonColor2 = Color(0xff5d3f3d);
  static const buttonColor3 = Color(0xff733331);
  static const buttonColor4 = Color(0xff251919);
  static const textColor1 = Color(0xfff1dedd);
  static const textColor2 = Colors.white;
  static const double buttonSize = 70;

  @override
  void initState() {
    super.initState();
    _loadDeviceId();
  }

  Future<void> _loadDeviceId() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? storedDevID = prefs.getString('device_id');
    if (storedDevID == null) {
      String newDevID = await getDeviceId();
      await prefs.setString('device_id', newDevID);
      setState(() {
        devID = newDevID;
      });
    } else {
      setState(() {
        devID = storedDevID;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        leading: TextButton(
          child: Text(
            'INV',
            style: TextStyle(color: Colors.white, fontSize: Checkbox.width),
          ),
          onPressed: () {
            setState(() {
              isInverse =
                  !isInverse; // Toggle between normal and inverse scientific functions
            });
          },
        ),
        backgroundColor: backgroundColor,
        actions: [
          IconButton(
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => HistScreen(
                    deviceId: devID,
                  ),
                ),
              );
            },
            icon: const Icon(
              Icons.history,
              color: textColor2,
            ),
          ),
          TextButton(
            onPressed: () {
              setState(() {
                isDegree = !isDegree; // Toggle between degrees and radians
              });
            },
            child: Text(
              isDegree ? 'DEG' : 'RAD',
              style: TextStyle(color: textColor1, fontSize: 20),
            ),
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            _buildDisplay(),
            // _dividerLine(),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 10),
              child: IconButton(
                onPressed: () {
                  setState(() {
                    showScientificButtons =
                        !showScientificButtons; // Toggle visibility
                  });
                },
                icon: Icon(
                  showScientificButtons
                      ? Icons.arrow_drop_down_sharp
                      : Icons.arrow_drop_up_sharp,
                  color: Colors.white,
                ),
              ),
            ),
            if (showScientificButtons) ...[
              _buildScientificSection(), // Show scientific buttons if toggled
            ],
            _buildButtons(),
          ],
        ),
      ),
    );
  }

  Widget _dividerLine() {
    return Divider(
      color: Colors.white,
    );
  }

  Widget _buildDisplay() {
    return Expanded(
      child: SingleChildScrollView(
        child: Container(
          // color: backgroundColor,
          padding: const EdgeInsets.all(15),
          alignment: Alignment.centerRight,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              SingleChildScrollView(
                scrollDirection: Axis.vertical,
                child: Text(
                  question,
                  style: const TextStyle(fontSize: 35, color: textColor1),
                  textAlign: TextAlign.right,
                ),
              ),
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Text(
                  answer,
                  style: const TextStyle(fontSize: 30, color: textColor2),
                  textAlign: TextAlign.right,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildScientificSection() {
    List<String> functions;
    if (isInverse) {
      functions = ['sin⁻¹', 'cos⁻¹', 'tan⁻¹', 'x²'];
    } else {
      functions = ['sin', 'cos', 'tan', '√'];
    }

    return Column(
      children: [
        // Scientific Buttons Rows
        _buildScientificButtonsRow(functions),
        _buildScientificButtonsRow(['π', 'e', 'ln', '^']),
      ],
    );
  }

  Widget _buildScientificButtonsRow(List<String> functions) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: functions.map((String value) {
            return Padding(
              padding: const EdgeInsets.only(left: 5, right: 10),
              child: SizedBox(
                width: buttonSize,
                height: buttonSize,
                child: SquareButton(
                  value: value,
                  color: backgroundColor,
                  press: () => _onButtonPress(value),
                ),
              ),
            );
          }).toList(),
        ),
      ),
    );
  }

  Widget _buildButtons() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 15),
      child: Column(
        children: [
          _buildButtonRow(['AC', '(  )', '%', '÷'],
              [buttonColor1, buttonColor2, buttonColor2, buttonColor2]),
          const SizedBox(height: 10),
          _buildButtonRow(['7', '8', '9', '×'],
              [buttonColor4, buttonColor4, buttonColor4, buttonColor2]),
          const SizedBox(height: 10),
          _buildButtonRow(['4', '5', '6', '-'],
              [buttonColor4, buttonColor4, buttonColor4, buttonColor2]),
          const SizedBox(height: 10),
          _buildButtonRow(['1', '2', '3', '+'],
              [buttonColor4, buttonColor4, buttonColor4, buttonColor2]),
          const SizedBox(height: 10),
          _buildButtonRow(['0', '.', '⌫', '='],
              [buttonColor4, buttonColor4, buttonColor4, buttonColor3]),
        ],
      ),
    );
  }

  Widget _buildButtonRow(List<String> values, List<Color?> colors) {
    return Padding(
      padding: const EdgeInsets.only(left: 5, right: 5),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: List.generate(values.length, (index) {
          return SquareButton(
            value: values[index],
            color: colors[index],
            press: () => _onButtonPress(values[index]),
          );
        }),
      ),
    );
  }

  void _onButtonPress(String value) {
    setState(() {
      if (isOperator(value)) {
        if (question.isNotEmpty && isOperator(question[question.length - 1])) {
          question = question.substring(0, question.length - 1) + value;
        } else if (question.isEmpty && value == '-') {
          question += value;
        } else if (question.isNotEmpty) {
          question += value;
        }
      } else {
        switch (value) {
          case 'AC':
            question = '';
            answer = '';
            break;
          case '(  )':
            int openCount = _countOpenParentheses(question);
            int closeCount = _countCloseParentheses(question);

            if (openCount > closeCount) {
              question += ")";
            } else {
              question += "(";
            }
            break;
          case '⌫':
            if (question.isNotEmpty) {
              question = question.substring(0, question.length - 1);
            }
            break;
          case '=':
            _evaluateExpression();
            break;
          case 'INV':
            // INV button is handled in AppBar
            break;
          case 'sin':
          case 'cos':
          case 'tan':
          case 'ln':
          case '√':
          case 'x²':
          case 'π':
          case 'e':
          case 'sin⁻¹':
          case 'cos⁻¹':
          case 'tan⁻¹':
          case '^':
            _handleScientificOperation(value);
            break;
          default:
            question += value;
            break;
        }
      }
    });
  }

  int _countOpenParentheses(String expr) {
    return expr.split("(").length - 1;
  }

  int _countCloseParentheses(String expr) {
    return expr.split(")").length - 1;
  }

  bool isOperator(String value) {
    return value == '+' || value == '-' || value == '×' || value == '÷';
  }

  void _handleScientificOperation(String value) {
    if (isInverse) {
      switch (value) {
        case 'sin⁻¹':
        case 'cos⁻¹':
        case 'tan⁻¹':
        case 'x²':
          question += '$value(';
          break;
        case '^':
          question += '^2';
          break;
        case 'π':
          question += 'π';
          break;
        case 'e':
          question += 'e';
          break;
      }
    } else {
      switch (value) {
        case 'sin':
        case 'cos':
        case 'tan':
        case 'ln':
          question += '$value(';
          break;
        case '√':
          question += 'sqrt(';
          break;
        case 'x²':
          question += '^2';
          break;
        case 'π':
          question += 'π';
          break;
        case 'e':
          question += 'e';
          break;
      }
    }
  }

  void _evaluateExpression() async {
    try {
      // Initial expression modifications
      String modifiedQues = question
          .replaceAll('×', '*')
          .replaceAll('÷', '/')
          .replaceAll('sin⁻¹', 'arcsin')
          .replaceAll('cos⁻¹', 'arccos')
          .replaceAll('tan⁻¹', 'arctan')
          .replaceAll('π', '3.141592653589793')
          .replaceAll('e', '2.718281828459045');

      if (isDegree) {
        // Convert degrees to radians for trigonometric functions
        modifiedQues = modifiedQues.replaceAllMapped(
          RegExp(r'(sin|cos|tan|arcsin|arccos|arctan)\(([^)]+)\)'),
          (match) {
            String func = match.group(1)!;
            String arg = match.group(2)!;
            // Ensure that we handle cases where the argument may already be a valid number or expression
            return '$func($arg * 3.141592653589793 / 180)';
          },
        );
      }

      print('Modified Question: $modifiedQues'); // Debug print

      // Parse and evaluate the expression
      Parser p = Parser();
      Expression exp = p.parse(modifiedQues);
      ContextModel cm = ContextModel();
      double eval = exp.evaluate(EvaluationType.REAL, cm);

      if (eval.isNaN) {
        answer = 'Error: Not a Number';
      } else {
        answer = eval.toString();
      }

      // Get a unique device ID
      String deviceId = await getDeviceId();
      devID = deviceId;

      // Save to a device-specific Firestore collection
      await FirebaseFirestore.instance
          .collection('devices')
          .doc(deviceId)
          .collection('history')
          .add({
        'question': question,
        'answer': answer,
        'timestamp': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      print('Error: $e'); // Debug print
      answer = 'Error';
    }

    setState(() {});
  }
}
