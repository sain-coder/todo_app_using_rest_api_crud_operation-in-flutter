import 'package:flutter/material.dart';
import 'dart:async';
import '../screens/todo_list_screen.dart';

class SplashServices {
  void splash(BuildContext context) {
    Timer(const Duration(seconds: 3), () {
      Navigator.push(
          context, MaterialPageRoute(builder: (context) => const TodoList()));
    });
  }
}
