import 'package:flutter/material.dart';

class notificationTest extends StatefulWidget {
  const notificationTest({Key? key}) : super(key: key);

  @override
  State<notificationTest> createState() => _notificationTestState();
}

class _notificationTestState extends State<notificationTest> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.pink[100],
      body: Center(
        child: Text('Gotcha Code working'),
      ),
    );
  }
}
