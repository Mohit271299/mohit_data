import 'package:db/testdata.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();

  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: const TestDatabase(),
      theme: ThemeData(
        primaryColor: Colors.yellow,
        dividerColor: Colors.white,
        scaffoldBackgroundColor: Colors.white,
        backgroundColor: Colors.black,
      ),
    );
  }
}
