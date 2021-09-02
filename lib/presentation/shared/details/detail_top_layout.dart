import 'package:flutter/material.dart';
import 'package:responsive_builder/responsive_builder.dart';

import 'constants.dart';

class DetailTopLayout extends StatelessWidget {
  final String fullImage;
  final String? secondFullImage;
  final Color? color;
  final Widget generalCard;
  final Widget? appBar;
  final Decoration? decoration;

  final bool isAnSmallImage;
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
              isAnSmallImage: isAnSmallImage,
            ),
          Align(
            alignment: imgAlignment,
            child: Image.asset(
              fullImage,
              fit: BoxFit.contain,
              filterQuality: FilterQuality.high,
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

  const ShadowImage({
    Key? key,
    required this.fullImage,
    this.secondFullImage,
    this.isAnSmallImage = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final mediaQuery = MediaQuery.of(context);
    final isPortrait = mediaQuery.orientation == Orientation.portrait;
    if (!isPortrait) {
      return Align(
        alignment: Alignment.topRight,
        child: Opacity(
          opacity: 0.5,
          child: Image.asset(
            secondFullImage ?? fullImage,
            fit: BoxFit.contain,
            filterQuality: FilterQuality.high,
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
            fit: BoxFit.contain,
            filterQuality: FilterQuality.high,
          ),
        ),
      ),
    );
  }
}
