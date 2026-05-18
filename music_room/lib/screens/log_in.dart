import 'package:flutter/material.dart';

class LogInPage extends StatefulWidget {
  const LogInPage({super.key});

  @override
  State<LogInPage> createState() => _LogInPageState();
}

class _LogInPageState extends State<LogInPage> {
  bool knowUser = false;

  void _onSignInSelected() {
    setState(() {
      knowUser = false;
    });
  }

  void _onLogInSelected() {
    setState(() {
      knowUser = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(,
    )
  }

}