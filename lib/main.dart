import 'package:flutter/material.dart';
import 'screens/login_screen.dart';

import 'package:flutter_dotenv/flutter_dotenv.dart';

void main() async {
  await dotenv.load(fileName: ".env");
  runApp(const PaceUpApp());
}

class PaceUpApp extends StatelessWidget {
  const PaceUpApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'PaceUp',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
        useMaterial3: true,
      ),
      home: const LoginScreen(),
      debugShowCheckedModeBanner: false,
    );
  }
}
