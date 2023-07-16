import 'package:flutter/material.dart';

class Styles {
  static const String appIconPath = 'assets/icon/icon.png';

  static double cardBottomRadius = 30;
  static double cardTopRadius = 10;

  static BorderRadius mainCardBorderRadius = BorderRadius.only(
    bottomLeft: Radius.circular(cardBottomRadius),
    bottomRight: Radius.circular(cardBottomRadius),
    topLeft: Radius.circular(cardTopRadius),
    topRight: Radius.circular(cardTopRadius),
  );

  static BorderRadius homeCardItemBorderRadius = BorderRadius.circular(40);

  static final RoundedRectangleBorder cardShape = RoundedRectangleBorder(borderRadius: BorderRadius.circular(10));
  static final RoundedRectangleBorder mainCardShape = RoundedRectangleBorder(borderRadius: mainCardBorderRadius);
  static final RoundedRectangleBorder floatingCardShape = RoundedRectangleBorder(borderRadius: BorderRadius.circular(20));

  static const double cardThreeElevation = 3;
  static const double cardTenElevation = 10;

  static const edgeInsetAll15 = EdgeInsets.all(15);
  static const edgeInsetAll10 = EdgeInsets.all(10);
  static const edgeInsetAll5 = EdgeInsets.all(5);
  static const edgeInsetAll0 = EdgeInsets.zero;
  static const edgeInsetHorizontal16 = EdgeInsets.symmetric(horizontal: 16);
  static const edgeInsetVertical5 = EdgeInsets.symmetric(vertical: 5);
  static const edgeInsetHorizontal5 = EdgeInsets.symmetric(horizontal: 5);
  static const edgeInsetVertical16 = EdgeInsets.symmetric(vertical: 16);
  static const edgeInsetVertical10 = EdgeInsets.symmetric(vertical: 10);
  static const edgeInsetHorizontal10 = EdgeInsets.symmetric(horizontal: 10);

  static const modalBottomSheetShape = RoundedRectangleBorder(
    borderRadius: BorderRadius.only(
      topRight: Radius.circular(35),
      topLeft: Radius.circular(35),
    ),
  );
  static const modalBottomSheetContainerMargin = EdgeInsets.only(left: 10, right: 10, bottom: 10);
  static const modalBottomSheetContainerPadding = EdgeInsets.only(left: 10, right: 10, top: 10);

  static const listItemWithIconOffset = Offset(-20, 0);

  static final cardItemDetailShape = RoundedRectangleBorder(
    borderRadius: BorderRadius.only(
      topRight: Radius.circular(cardBottomRadius),
      topLeft: Radius.circular(cardBottomRadius),
    ),
  );

  static const double materialCardHeight = 270;
  static const double materialCardWidth = 220;
  static const double homeCardHeight = 170;
  static const double homeCardWidth = 280;
  static const double birthdayCardWidth = 300;

  static const endDrawerFilterItemMargin = EdgeInsets.only(top: 20);
  static const double endDrawerIconSize = 40;

  static const double smallButtonSplashRadius = 18;
  static const double mediumButtonSplashRadius = 25;
  static const double mediumBigButtonSplashRadius = mediumButtonSplashRadius * 1.3;

  static double getIconSizeForItemPopupMenuFilter(bool forEndDrawer, bool forDefaultIcons) {
    if (forDefaultIcons) {
      return forEndDrawer ? 36 : 24;
    }
    return forEndDrawer ? 26 : 18;
  }

  static const Color paimonColor = Color.fromARGB(255, 191, 138, 104);

  static LinearGradient blackGradientForCircleItems = LinearGradient(
    colors: [Colors.black.withOpacity(0.6), Colors.black.withOpacity(0.8)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const Color wishButtonBackgroundColor = Color(0xffe0ddd4);
  static const Color fiveStarWishResultBackgroundColor = Color(0xfff9aa02);
  static const Color fourStarWishResultBackgroundColor = Color(0xffb912d6);
  static const Color commonStarWishResultBackgroundColor = Color.fromRGBO(170, 200, 241, 1);

  static const LinearGradient fiveStarWishResultGradient = LinearGradient(
    colors: [
      fiveStarWishResultBackgroundColor,
      Color.fromRGBO(255, 255, 255, 1),
      fiveStarWishResultBackgroundColor,
    ],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const List<BoxShadow> fiveStarWishResultBoxShadow = [
    BoxShadow(
      color: Colors.white,
      blurRadius: 20,
      spreadRadius: -20,
      blurStyle: BlurStyle.outer,
    ),
    BoxShadow(
      color: Styles.fiveStarWishResultBackgroundColor,
      blurRadius: 25,
      spreadRadius: -20,
      blurStyle: BlurStyle.outer,
    ),
    BoxShadow(
      color: Styles.fiveStarWishResultBackgroundColor,
      blurRadius: 15,
      spreadRadius: -20,
      blurStyle: BlurStyle.outer,
    ),
  ];

  static const List<BoxShadow> fourStarWishResultBoxShadow = [
    BoxShadow(
      color: Colors.white,
      blurRadius: 20,
      spreadRadius: -20,
      blurStyle: BlurStyle.outer,
    ),
    BoxShadow(
      color: Styles.fourStarWishResultBackgroundColor,
      blurRadius: 25,
      spreadRadius: -20,
      blurStyle: BlurStyle.outer,
    ),
    BoxShadow(
      color: Styles.fourStarWishResultBackgroundColor,
      blurRadius: 15,
      spreadRadius: -20,
      blurStyle: BlurStyle.outer,
    ),
  ];

  static const List<BoxShadow> commonWishResultBoxShadow = [
    BoxShadow(
      color: Styles.commonStarWishResultBackgroundColor,
      blurRadius: 25,
      spreadRadius: -20,
      blurStyle: BlurStyle.outer,
    ),
    BoxShadow(
      color: Colors.white,
      blurRadius: 10,
      spreadRadius: -20,
      blurStyle: BlurStyle.outer,
    ),
    BoxShadow(
      color: Styles.commonStarWishResultBackgroundColor,
      blurRadius: 15,
      spreadRadius: -20,
      blurStyle: BlurStyle.outer,
    ),
  ];
}
