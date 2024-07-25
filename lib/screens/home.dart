import 'package:calculator/screens/history.dart';
import 'package:flutter/material.dart';
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

  String devID = '';

  static const backgroundColor = Color(0xff1a1111);
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
          )
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            _buildDisplay(),
            _buildScientificButtonsRow1(),
            _buildScientificButtonsRow2(),
            _buildButtons(),
          ],
        ),
      ),
    );
  }

  Widget _buildDisplay() {
    return Expanded(
      child: SingleChildScrollView(
        child: Container(
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
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildScientificButtonsRow1() {
    List<String> functions = ['sin', 'cos', 'tan', 'ln', '√', 'x²'];
    return _buildHorizontalScrollableRow(functions);
  }

  Widget _buildScientificButtonsRow2() {
    List<String> functions = ['sin⁻¹', 'cos⁻¹', 'tan⁻¹', '^', 'π', 'e'];
    return _buildHorizontalScrollableRow(functions);
  }

  Widget _buildHorizontalScrollableRow(List<String> functions) {
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
                child: CirclButton(
                  value: value,
                  color: buttonColor2,
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
          return CirclButton(
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
    switch (value) {
      case 'sin':
      case 'cos':
      case 'tan':
      case 'sin⁻¹':
      case 'cos⁻¹':
      case 'tan⁻¹':
      case '^':
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
        question += '3.141592653589793';
        break;
      case 'e':
        question += '2.718281828459045';
        break;
    }
  }

  void _evaluateExpression() async {
    try {
      String modifiedQues = question
          .replaceAll('×', '*')
          .replaceAll('÷', '/')
          .replaceAll('sin⁻¹', 'arcsin')
          .replaceAll('cos⁻¹', 'arccos')
          .replaceAll('tan⁻¹', 'arctan');
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
      answer = 'Error';
    }

    setState(() {});
  }
}
