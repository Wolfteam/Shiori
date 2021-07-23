import 'package:flutter/material.dart';
import 'package:responsive_builder/responsive_builder.dart';

import 'constants.dart';

const double _imageWidthOnPortrait = 350;

double? _getWidthToUse(
  BuildContext context, {
  double? widthOnPortrait,
  double? widthOnLandscape,
  bool isAnSmallImage = false,
}) {
  final mediaQuery = MediaQuery.of(context);
  final isPortrait = mediaQuery.orientation == Orientation.portrait;
  // final size = getDeviceType(mediaQuery.size);
  if (isPortrait) {
    final value = widthOnPortrait ?? _imageWidthOnPortrait;
    // final newValue = size == DeviceScreenType.mobile
    //     ? !isAnSmallImage
    //         ? value
    //         : (value / 2)
    //     : value;
    // if (isAnSmallImage && newValue > 250) {
    //   return 250;
    // }
    return value;
  }

  final value = widthOnLandscape ?? _imageWidthOnPortrait;
  return isAnSmallImage ? value / 2 : value;
}

double? _getHeightToUse(
  BuildContext context, {
  double? heightOnPortrait,
  double? heightOnLandscape,
  bool isAnSmallImage = false,
}) {
  final mediaQuery = MediaQuery.of(context);
  final isPortrait = mediaQuery.orientation == Orientation.portrait;
  // final size = getDeviceType(mediaQuery.size);
  final imgHeight = mediaQuery.size.height;
  if (isPortrait) {
    final value = heightOnPortrait ?? imgHeight;
    // final newValue = size == DeviceScreenType.mobile
    //     ? !isAnSmallImage
    //         ? value
    //         : (value / 2)
    //     : value;

    // if (isAnSmallImage && newValue > 250) {
    //   return 250;
    // }
    return value;
  }

  final value = heightOnLandscape ?? imgHeight;
  return isAnSmallImage ? value / 2 : value;
}

class DetailTopLayout extends StatelessWidget {
  final String fullImage;
  final String? secondFullImage;
  final Color? color;
  final Widget generalCard;
  final Widget? appBar;
  final Decoration? decoration;

  final bool isAnSmallImage;
  final double? widthOnPortrait;
  final double? heightOnPortrait;

  final double? widthOnLandscape;
  final double? heightOnLandscape;

  final bool showShadowImage;

  final double charDescriptionHeight;

  const DetailTopLayout({
    Key? key,
    required this.fullImage,
    this.secondFullImage,
    this.color,
    required this.generalCard,
    this.appBar,
    this.decoration,
    this.widthOnPortrait,
    this.heightOnPortrait,
    this.widthOnLandscape,
    this.heightOnLandscape,
    this.isAnSmallImage = false,
    this.showShadowImage = true,
    this.charDescriptionHeight = 240,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final mediaQuery = MediaQuery.of(context);
    final isPortrait = mediaQuery.orientation == Orientation.portrait;
    final device = getDeviceType(mediaQuery.size);
    final descriptionWidth = (mediaQuery.size.width / (isPortrait ? 1 : 2)) / (device == DeviceScreenType.mobile ? 1.2 : 1.5);
    final imgAlignment = showShadowImage
        ? isPortrait
            ? Alignment.centerLeft
            : Alignment.bottomLeft
        : Alignment.center;
    return Container(
      height: isPortrait ? getTopHeightForPortrait(context, isAnSmallImage) : null,
      color: color,
      decoration: decoration,
      child: Stack(
        fit: StackFit.passthrough,
        alignment: Alignment.center,
        children: <Widget>[
          if (showShadowImage)
            ShadowImage(
              fullImage: fullImage,
              secondFullImage: secondFullImage,
              widthOnLandscape: widthOnLandscape,
              heightOnLandscape: heightOnLandscape,
              isAnSmallImage: isAnSmallImage,
              heightOnPortrait: heightOnPortrait,
              widthOnPortrait: widthOnPortrait,
            ),
          Align(
            alignment: imgAlignment,
            child: Image.asset(
              fullImage,
              fit: BoxFit.fill,
              width: _getWidthToUse(
                context,
                widthOnPortrait: widthOnPortrait,
                widthOnLandscape: widthOnLandscape,
                isAnSmallImage: isAnSmallImage,
              ),
              height: _getHeightToUse(
                context,
                heightOnPortrait: heightOnPortrait,
                heightOnLandscape: heightOnLandscape,
                isAnSmallImage: isAnSmallImage,
              ),
            ),
          ),
          Align(
            alignment: isPortrait ? Alignment.center : Alignment.bottomCenter,
            child: SizedBox(
              height: charDescriptionHeight,
              width: descriptionWidth,
              child: generalCard,
            ),
          ),
          Positioned(
            top: 0.0,
            left: 0.0,
            right: 0.0,
            child: appBar ?? const SizedBox(),
          ),
        ],
      ),
    );
  }
}

class ShadowImage extends StatelessWidget {
  final String fullImage;
  final String? secondFullImage;

  final bool isAnSmallImage;
  final double? widthOnPortrait;
  final double? heightOnPortrait;

  final double? widthOnLandscape;
  final double? heightOnLandscape;

  const ShadowImage({
    Key? key,
    required this.fullImage,
    this.secondFullImage,
    this.widthOnPortrait,
    this.heightOnPortrait,
    this.widthOnLandscape,
    this.heightOnLandscape,
    this.isAnSmallImage = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final mediaQuery = MediaQuery.of(context);
    final isPortrait = mediaQuery.orientation == Orientation.portrait;
    if (!isPortrait) {
      return Positioned(
        top: 0,
        right: -40,
        bottom: 30,
        child: Opacity(
          opacity: 0.5,
          child: Image.asset(
            secondFullImage ?? fullImage,
            fit: BoxFit.fill,
            width: _getWidthToUse(
              context,
              widthOnPortrait: widthOnPortrait,
              widthOnLandscape: widthOnLandscape,
              isAnSmallImage: isAnSmallImage,
            ),
            height: _getHeightToUse(
              context,
              heightOnPortrait: heightOnPortrait,
              heightOnLandscape: heightOnLandscape,
              isAnSmallImage: isAnSmallImage,
            ),
          ),
        ),
      );
    }
    return Align(
      alignment: Alignment.centerRight,
      child: Container(
        transform: Matrix4.translationValues(isAnSmallImage ? 30 : 60, isAnSmallImage ? -10 : -30, 0.0),
        child: Opacity(
          opacity: 0.5,
          child: Image.asset(
            secondFullImage ?? fullImage,
            fit: BoxFit.fill,
            width: _getWidthToUse(
              context,
              widthOnPortrait: widthOnPortrait,
              widthOnLandscape: widthOnLandscape,
              isAnSmallImage: isAnSmallImage,
            ),
            height: _getHeightToUse(
              context,
              heightOnPortrait: heightOnPortrait,
              heightOnLandscape: heightOnLandscape,
              isAnSmallImage: isAnSmallImage,
            ),
          ),
        ),
      ),
    );
  }
}
