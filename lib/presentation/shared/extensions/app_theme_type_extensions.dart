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
      default:
        throw Exception('The provided accent color = $this is not valid ');
    }
  }

  ThemeData getThemeData(AppThemeType theme) {
    final color = getAccentColor();
    switch (theme) {
      case AppThemeType.dark:
        return ThemeData.dark().copyWith(
          primaryColor: color,
          primaryColorLight: color.withOpacity(0.5),
          primaryColorDark: color,
          colorScheme: ColorScheme.dark(primary: color, secondary: color, primaryVariant: color, secondaryVariant: color),
        );
      case AppThemeType.light:
        return ThemeData.light().copyWith(
          primaryColor: color,
          primaryColorLight: color.withOpacity(0.8),
          primaryColorDark: color,
          colorScheme: ColorScheme.light(primary: color, secondary: color),
        );
      default:
        throw Exception('The provided theme  = $theme is not valid ');
    }
  }
}
