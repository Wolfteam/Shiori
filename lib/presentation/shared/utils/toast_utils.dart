import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';

enum ToastType {
  info,
  succeed,
  warning,
  error,
}

enum ToastDurationType {
  normal,
  long,
}

class ToastUtils {
  static const Duration defaultToastDuration = Duration(seconds: 2);

  static FToast of(BuildContext context) {
    final fToast = FToast();
    fToast.init(context);
    return fToast;
  }

  static void showSucceedToast(FToast toast, String msg, {ToastDurationType durationType = ToastDurationType.normal}) =>
      _showToast(toast, msg, Colors.white, ToastType.succeed, durationType);

  static void showInfoToast(FToast toast, String msg, {ToastDurationType durationType = ToastDurationType.normal}) =>
      _showToast(toast, msg, Colors.white, ToastType.info, durationType);

  static void showWarningToast(FToast toast, String msg, {ToastDurationType durationType = ToastDurationType.normal}) =>
      _showToast(toast, msg, Colors.white, ToastType.warning, durationType);

  static void showErrorToast(FToast toast, String msg, {ToastDurationType durationType = ToastDurationType.normal}) =>
      _showToast(toast, msg, Colors.white, ToastType.error, durationType);

  static void _showToast(
    FToast toast,
    String msg,
    Color textColor,
    ToastType type,
    ToastDurationType durationType,
  ) {
    Duration duration;
    switch (durationType) {
      case ToastDurationType.normal:
        duration = defaultToastDuration;
      case ToastDurationType.long:
        duration = Duration(seconds: defaultToastDuration.inSeconds * 2);
    }
    toast.showToast(
      child: _ToastBody(msg: msg, textColor: textColor, type: type),
      gravity: ToastGravity.BOTTOM,
      toastDuration: duration,
    );
  }
}

class _ToastBody extends StatelessWidget {
  final String msg;
  final Color textColor;
  final ToastType type;

  const _ToastBody({
    required this.msg,
    required this.textColor,
    required this.type,
  });

  @override
  Widget build(BuildContext context) {
    Color bgColor;
    Icon icon;
    switch (type) {
      case ToastType.info:
        bgColor = Colors.blue;
        icon = const Icon(Icons.info, color: Colors.white);
      case ToastType.succeed:
        bgColor = Colors.green;
        icon = const Icon(Icons.check, color: Colors.white);
      case ToastType.warning:
        bgColor = Colors.orange;
        icon = const Icon(Icons.warning, color: Colors.white);
      case ToastType.error:
        bgColor = Colors.red;
        icon = const Icon(Icons.dangerous, color: Colors.white);
      default:
        throw Exception('Invalid toast type = $type');
    }
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
