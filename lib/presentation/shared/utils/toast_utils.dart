import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';

class ToastUtils {
  static void showSucceedToast(
    String msg, {
    Color textColor = Colors.white,
    Color bgColor = Colors.green,
  }) {
    _showToast(msg, textColor, bgColor);
  }

  static void showInfoToast(
    String msg, {
    Color textColor = Colors.white,
    Color bgColor = Colors.blue,
  }) {
    _showToast(msg, textColor, bgColor);
  }

  static void showWarningToast(
    String msg, {
    Color textColor = Colors.white,
    Color bgColor = Colors.orange,
  }) {
    _showToast(msg, textColor, bgColor);
  }

  static void showErrorToast(
    String msg, {
    Color textColor = Colors.white,
    Color bgColor = Colors.red,
  }) {
    _showToast(msg, textColor, bgColor);
  }

  static void _showToast(
    String msg,
    Color textColor,
    Color bgColor, {
    Toast length = Toast.LENGTH_SHORT,
  }) {
    Fluttertoast.showToast(
      msg: msg,
      toastLength: length,
      gravity: ToastGravity.BOTTOM,
      backgroundColor: bgColor,
      textColor: textColor,
      fontSize: 16.0,
    );
  }
}
