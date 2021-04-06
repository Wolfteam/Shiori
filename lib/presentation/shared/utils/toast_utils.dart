import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';

enum ToastType {
  info,
  succeed,
  warning,
  error,
}

class ToastUtils {
  static Duration toastDuration = const Duration(seconds: 2);

  static FToast of(BuildContext context) {
    final fToast = FToast();
    fToast.init(context);
    return fToast;
  }

  static void showSucceedToast(FToast toast, String msg) => _showToast(toast, msg, Colors.white, ToastType.succeed);

  static void showInfoToast(FToast toast, String msg) => _showToast(toast, msg, Colors.white, ToastType.info);

  static void showWarningToast(FToast toast, String msg) => _showToast(toast, msg, Colors.white, ToastType.warning);

  static void showErrorToast(FToast toast, String msg) => _showToast(toast, msg, Colors.white, ToastType.error);

  static void _showToast(
    FToast toast,
    String msg,
    Color textColor,
    ToastType type,
  ) {
    Color bgColor;
    Icon icon;
    switch (type) {
      case ToastType.info:
        bgColor = Colors.blue;
        icon = const Icon(Icons.info, color: Colors.white);
        break;
      case ToastType.succeed:
        bgColor = Colors.green;
        icon = const Icon(Icons.check, color: Colors.white);
        break;
      case ToastType.warning:
        bgColor = Colors.orange;
        icon = const Icon(Icons.warning, color: Colors.white);
        break;
      case ToastType.error:
        bgColor = Colors.red;
        icon = const Icon(Icons.dangerous, color: Colors.white);
        break;
      default:
        throw Exception('Invalid toast type = $type');
    }

    final widget = _buildToast(msg, textColor, bgColor, icon, toast.context);
    toast.showToast(
      child: widget,
      gravity: ToastGravity.BOTTOM,
      toastDuration: toastDuration,
    );
  }

  static Widget _buildToast(String msg, Color textColor, Color bgColor, Icon icon, BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 12.0),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(25.0),
        color: bgColor,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          icon,
          const SizedBox(width: 10.0),
          Flexible(
            child: Text(
              msg,
              style: TextStyle(color: textColor),
            ),
          ),
        ],
      ),
    );
  }
}
