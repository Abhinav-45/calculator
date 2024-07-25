import 'package:calculator/screens/home.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class CalcApp extends StatelessWidget {
  final GoRouter _router = GoRouter(
    initialLocation: '/home',
    routes: [
      GoRoute(
        path: '/home',
        builder: (context, state) => const HomeScreen(),
      ),
    ],
  );

  CalcApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(routerConfig: _router);
  }
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(
      options: const FirebaseOptions(
          apiKey: "AIzaSyCfI0L2Ux2OJUn8rg_Gkr28dfRiwe2ic1c",
          authDomain: "calculator-fde0f.firebaseapp.com",
          projectId: "calculator-fde0f",
          storageBucket: "calculator-fde0f.appspot.com",
          messagingSenderId: "141934244235",
          appId: "1:141934244235:web:51ba653452c938174bbf8e"));

  runApp(CalcApp());
}
