import 'dart:io';

import 'package:flutter/material.dart';
import 'package:shiori/domain/assets.dart';
import 'package:shiori/domain/services/genshin_service.dart';
import 'package:shiori/domain/services/resources_service.dart';
import 'package:shiori/injection.dart';
import 'package:shiori/presentation/shared/styles.dart';

class WishResultPage extends StatelessWidget {
  const WishResultPage({super.key});

  @override
  Widget build(BuildContext context) {
    final genshinService = getIt<GenshinService>();
    final resourceService = getIt<ResourceService>();
    final chars = genshinService.characters.getCharactersForCard().where((element) => !element.key.startsWith('traveler')).toList();
    return Scaffold(
      body: Ink(
        decoration: BoxDecoration(
          image: DecorationImage(
            image: AssetImage(Assets.wishBannerResultBackgroundImgPath),
            fit: BoxFit.fill,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Container(
              margin: const EdgeInsets.only(top: 10, right: 20),
              alignment: Alignment.topRight,
              child: CircleAvatar(
                backgroundColor: Styles.wishButtonBackgroundColor,
                radius: 20,
                child: IconButton(
                  onPressed: () => Navigator.pop(context),
                  splashRadius: Styles.mediumButtonSplashRadius,
                  icon: const Icon(Icons.close),
                  color: Colors.black,
                ),
              ),
            ),
            Expanded(
              child: LayoutBuilder(
                builder: (context, constraints) => Center(
                  child: Container(
                    height: constraints.maxWidth * 0.8,
                    constraints: BoxConstraints(
                      maxHeight: constraints.maxHeight * 0.7,
                      minHeight: constraints.maxHeight * 0.4,
                    ),
                    child: ListView.builder(
                      itemCount: chars.length,
                      scrollDirection: Axis.horizontal,
                      itemBuilder: (context, index) => _WishResultItem(
                        image: resourceService.getCharacterImagePath('${chars[index].key}.webp'),
                        rarity: chars[index].stars,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _WishResultItem extends StatelessWidget {
  final String image;
  final int rarity;

  const _WishResultItem({
    required this.image,
    required this.rarity,
  });

  @override
  Widget build(BuildContext context) {
    final boxShadow = rarity == 5
        ? Styles.fiveStarWishResultBoxShadow
        : rarity == 4
            ? Styles.fourStarWishResultBoxShadow
            : Styles.commonWishResultBoxShadow;
    return AspectRatio(
      aspectRatio: 10 / 30,
      child: Container(
        margin: Styles.edgeInsetHorizontal16,
        child: Stack(
          fit: StackFit.passthrough,
          alignment: Alignment.center,
          children: [
            ClipPath(
              clipper: _WishResultImageClipper(),
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: const BorderRadius.all(Radius.elliptical(150, 500)),
                  boxShadow: boxShadow,
                ),
              ),
            ),
            Container(
              margin: const EdgeInsets.symmetric(vertical: 10, horizontal: 8),
              child: ClipPath(
                clipper: _WishResultImageClipper(),
                clipBehavior: Clip.hardEdge,
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    image: DecorationImage(
                      image: AssetImage(Assets.wishBannerItemResultBackgroundImgPath),
                      fit: BoxFit.fill,
                    ),
                  ),
                  child: Image.file(
                    File(image),
                    fit: BoxFit.cover,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

//https://www.flutterclutter.dev/tools/svg-to-flutter-path-converter/
class _WishResultImageClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    final path = Path();
    path.lineTo(size.width / 2, size.height);
    path.cubicTo(size.width * 0.49, size.height, size.width * 0.44, size.height, size.width * 0.38, size.height * 0.98);
    path.cubicTo(size.width * 0.24, size.height * 0.97, size.width * 0.23, size.height * 0.94, size.width * 0.23, size.height * 0.94);
    path.cubicTo(size.width * 0.23, size.height * 0.94, size.width * 0.23, size.height * 0.93, size.width * 0.23, size.height * 0.93);
    path.cubicTo(size.width * 0.23, size.height * 0.93, size.width / 5, size.height * 0.92, size.width * 0.14, size.height * 0.92);
    path.cubicTo(size.width * 0.07, size.height * 0.92, size.width * 0.08, size.height * 0.91, size.width * 0.08, size.height * 0.91);
    path.cubicTo(size.width * 0.08, size.height * 0.91, size.width * 0.08, size.height * 0.9, size.width * 0.08, size.height * 0.9);
    path.cubicTo(0, size.height * 0.9, 0, size.height * 0.88, 0, size.height * 0.88);
    path.cubicTo(0, size.height * 0.88, 0, size.height * 0.12, 0, size.height * 0.12);
    path.cubicTo(0, size.height * 0.1, size.width * 0.08, size.height * 0.1, size.width * 0.08, size.height * 0.1);
    path.cubicTo(size.width * 0.08, size.height * 0.1, size.width * 0.08, size.height * 0.09, size.width * 0.08, size.height * 0.09);
    path.cubicTo(size.width * 0.08, size.height * 0.09, size.width * 0.08, size.height * 0.08, size.width * 0.13, size.height * 0.08);
    path.cubicTo(size.width * 0.19, size.height * 0.08, size.width * 0.23, size.height * 0.07, size.width * 0.23, size.height * 0.07);
    path.cubicTo(size.width * 0.23, size.height * 0.05, size.width * 0.24, size.height * 0.04, size.width * 0.36, size.height * 0.02);
    path.cubicTo(size.width * 0.49, size.height * 0.01, size.width / 2, 0, size.width / 2, 0);
    path.cubicTo(size.width / 2, 0, size.width / 2, 0, size.width / 2, 0);
    path.cubicTo(size.width / 2, 0, size.width * 0.52, size.height * 0.01, size.width * 0.64, size.height * 0.02);
    path.cubicTo(size.width * 0.76, size.height * 0.04, size.width * 0.77, size.height * 0.05, size.width * 0.77, size.height * 0.07);
    path.cubicTo(size.width * 0.77, size.height * 0.07, size.width * 0.81, size.height * 0.08, size.width * 0.87, size.height * 0.08);
    path.cubicTo(size.width * 0.92, size.height * 0.08, size.width * 0.92, size.height * 0.09, size.width * 0.92, size.height * 0.09);
    path.cubicTo(size.width * 0.92, size.height * 0.09, size.width * 0.92, size.height * 0.1, size.width * 0.92, size.height * 0.1);
    path.cubicTo(size.width * 0.92, size.height * 0.1, size.width, size.height * 0.1, size.width, size.height * 0.12);
    path.cubicTo(size.width, size.height * 0.12, size.width, size.height * 0.88, size.width, size.height * 0.88);
    path.cubicTo(size.width, size.height * 0.88, size.width, size.height * 0.9, size.width * 0.92, size.height * 0.9);
    path.cubicTo(size.width * 0.92, size.height * 0.9, size.width * 0.92, size.height * 0.91, size.width * 0.92, size.height * 0.91);
    path.cubicTo(size.width * 0.92, size.height * 0.91, size.width * 0.93, size.height * 0.92, size.width * 0.86, size.height * 0.92);
    path.cubicTo(size.width * 0.8, size.height * 0.92, size.width * 0.77, size.height * 0.93, size.width * 0.77, size.height * 0.93);
    path.cubicTo(size.width * 0.77, size.height * 0.93, size.width * 0.77, size.height * 0.94, size.width * 0.77, size.height * 0.94);
    path.cubicTo(size.width * 0.77, size.height * 0.94, size.width * 0.76, size.height * 0.97, size.width * 0.62, size.height * 0.98);
    path.cubicTo(size.width * 0.55, size.height, size.width / 2, size.height, size.width / 2, size.height);
    path.cubicTo(size.width / 2, size.height, size.width / 2, size.height, size.width / 2, size.height);
    path.cubicTo(size.width / 2, size.height, size.width / 2, size.height, size.width / 2, size.height);
    return path;
  }

  @override
  bool shouldReclip(covariant CustomClipper<Path> oldClipper) {
    return false;
  }
}
