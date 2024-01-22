import 'dart:io';

import 'package:flutter/material.dart';
import 'package:shiori/presentation/shared/details/constants.dart';
import 'package:transparent_image/transparent_image.dart';

class DetailMainContent extends StatelessWidget {
  final String fullImage;
  final String? secondFullImage;
  final Color? color;
  final Widget generalCard;
  final List<Widget> appBarActions;
  final Decoration? decoration;

  final bool isAnSmallImage;
  final bool showShadowImage;

  const DetailMainContent({
    super.key,
    required this.fullImage,
    this.secondFullImage,
    this.color,
    required this.generalCard,
    this.appBarActions = const <Widget>[],
    this.decoration,
    this.isAnSmallImage = false,
    this.showShadowImage = true,
  });

  @override
  Widget build(BuildContext context) {
    final mediaQuery = MediaQuery.of(context);
    final isPortrait = mediaQuery.orientation == Orientation.portrait;
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
        fit: StackFit.expand,
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
            child: _Image(fullImage: fullImage),
          ),
          Align(
            alignment: isPortrait ? Alignment.bottomCenter : Alignment.bottomCenter,
            child: generalCard,
          ),
          Positioned(
            top: 0.0,
            left: 0.0,
            right: 0.0,
            child: AppBar(
              backgroundColor: Colors.transparent,
              surfaceTintColor: Colors.transparent,
              elevation: 0.0,
              actions: appBarActions,
            ),
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
    super.key,
    required this.fullImage,
    this.secondFullImage,
    this.isAnSmallImage = false,
  });

  @override
  Widget build(BuildContext context) {
    final mediaQuery = MediaQuery.of(context);
    final isPortrait = mediaQuery.orientation == Orientation.portrait;
    if (!isPortrait) {
      return Align(
        alignment: Alignment.topRight,
        child: Opacity(
          opacity: 0.5,
          child: _Image(fullImage: fullImage, secondFullImage: secondFullImage),
        ),
      );
    }
    return Align(
      alignment: Alignment.centerRight,
      child: Container(
        transform: Matrix4.translationValues(isAnSmallImage ? 30 : 60, isAnSmallImage ? -10 : -30, 0.0),
        child: Opacity(
          opacity: 0.5,
          child: _Image(fullImage: fullImage, secondFullImage: secondFullImage),
        ),
      ),
    );
  }
}

class _Image extends StatelessWidget {
  final String fullImage;
  final String? secondFullImage;

  const _Image({
    required this.fullImage,
    this.secondFullImage,
  });

  @override
  Widget build(BuildContext context) {
    return FadeInImage(
      placeholder: MemoryImage(kTransparentImage),
      fit: BoxFit.contain,
      filterQuality: FilterQuality.high,
      image: FileImage(File(secondFullImage ?? fullImage)),
    );
  }
}
