import 'package:flutter/material.dart';
import 'package:shiori/domain/enums/enums.dart';

extension AppThemeTypeExtensions on AppAccentColorType {
  Color getAccentColor() {
    switch (this) {
      case AppAccentColorType.blue:
        return Colors.blue;
      case AppAccentColorType.green:
        return Colors.green;
      case AppAccentColorType.pink:
        return Colors.pink;
      case AppAccentColorType.brown:
        return Colors.brown;
      case AppAccentColorType.red:
        return Colors.red;
      case AppAccentColorType.cyan:
        return Colors.cyan;
      case AppAccentColorType.indigo:
        return Colors.indigo;
      case AppAccentColorType.purple:
        return Colors.purple;
      case AppAccentColorType.deepPurple:
        return Colors.deepPurple;
      case AppAccentColorType.grey:
        return Colors.grey;
      case AppAccentColorType.orange:
        return Colors.orange;
      case AppAccentColorType.yellow:
        return Colors.yellow;
      case AppAccentColorType.blueGrey:
        return Colors.blueGrey;
      case AppAccentColorType.teal:
        return Colors.teal;
      case AppAccentColorType.amber:
        return Colors.amber;
    }
  }

  ThemeData getThemeData(AppThemeType theme, bool useDarkAmoledTheme) {
    final color = getAccentColor();
    final brightness = switch (theme) {
      AppThemeType.dark => Brightness.dark,
      AppThemeType.light => Brightness.light,
    };

    final ColorScheme colorScheme = ColorScheme.fromSeed(seedColor: color, brightness: brightness);
    final themeData = ThemeData.from(colorScheme: colorScheme, useMaterial3: true);
    if (!useDarkAmoledTheme || brightness == Brightness.light) {
      return themeData;
    }

    const almostBlackColor = Color.fromARGB(255, 20, 20, 20);
    return themeData.copyWith(
      scaffoldBackgroundColor: Colors.black,
      popupMenuTheme: const PopupMenuThemeData(color: almostBlackColor),
      bottomSheetTheme: const BottomSheetThemeData(backgroundColor: almostBlackColor),
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(backgroundColor: almostBlackColor),
      cardColor: almostBlackColor,
      dialogBackgroundColor: almostBlackColor,
      colorScheme: colorScheme.copyWith(surface: almostBlackColor),
    );
  }
}
