import 'package:flutter/material.dart';

extension FocusScopeNodeExtensions on FocusScopeNode {
  void removeFocus() {
    if (!hasPrimaryFocus && focusedChild != null) {
      focusedChild!.unfocus();
    }
  }
}
