import 'dart:io';

import 'package:flutter/material.dart';
import 'package:responsive_builder/responsive_builder.dart';
import 'package:shiori/domain/assets.dart';
import 'package:shiori/domain/enums/enums.dart';
import 'package:shiori/domain/extensions/weapon_type_extensions.dart';
import 'package:shiori/presentation/character/character_page.dart';
import 'package:shiori/presentation/shared/extensions/element_type_extensions.dart';
import 'package:shiori/presentation/shared/styles.dart';
import 'package:shiori/presentation/weapon/weapon_page.dart';

class WishResultItem extends StatefulWidget {
  final String itemKey;
  final String image;
  final int rarity;
  final String bottomImg;
  final bool isCharacter;

  WishResultItem.character({
    required this.itemKey,
    required this.image,
    required this.rarity,
    required ElementType elementType,
  })  : isCharacter = true,
        bottomImg = elementType.getElementAssetPath();

  WishResultItem.weapon({
    required this.itemKey,
    required this.image,
    required this.rarity,
    required WeaponType weaponType,
  })  : isCharacter = false,
        bottomImg = weaponType.getWeaponNormalSkillAssetPath();

  @override
  State<WishResultItem> createState() => _WishResultItemState();
}

class _WishResultItemState extends State<WishResultItem> {
  bool _showZoom = false;

  @override
  Widget build(BuildContext context) {
    final boxShadow = widget.rarity == 5
        ? Styles.fiveStarWishResultBoxShadow
        : widget.rarity == 4
            ? Styles.fourStarWishResultBoxShadow
            : Styles.commonWishResultBoxShadow;

    final size = getDeviceType(MediaQuery.of(context).size);
    final double aspectRatio = switch (size) {
      DeviceScreenType.mobile => 9 / 20,
      DeviceScreenType.tablet => 9 / 25,
      _ => 8 / 30,
    };

    return AspectRatio(
      aspectRatio: aspectRatio,
      child: GestureDetector(
        onTap: () async {
          if (widget.isCharacter) {
            await CharacterPage.route(widget.itemKey, context);
            return;
          }

          await WeaponPage.route(widget.itemKey, context);
        },
        child: MouseRegion(
          onEnter: (event) {
            setState(() {
              _showZoom = true;
            });
          },
          onExit: (event) {
            setState(() {
              _showZoom = false;
            });
          },
          child: AnimatedScale(
            duration: const Duration(milliseconds: 50),
            scale: _showZoom ? 1.05 : 1,
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
                        File(widget.image),
                        fit: BoxFit.fill,
                      ),
                    ),
                  ),
                ),
                _BottomPart(image: widget.bottomImg, rarity: widget.rarity),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _BottomPart extends StatelessWidget {
  final String image;
  final int rarity;

  const _BottomPart({
    required this.image,
    required this.rarity,
  });

  @override
  Widget build(BuildContext context) {
    return ClipPath(
      clipper: _WishResultImageClipper(),
      child: Align(
        alignment: Alignment.bottomCenter,
        child: DecoratedBox(
          decoration: BoxDecoration(boxShadow: Styles.commonBlackShadow),
          child: Container(
            margin: const EdgeInsets.only(bottom: 45),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: [
                FractionallySizedBox(
                  widthFactor: 0.5,
                  child: Image.asset(image),
                ),
                Wrap(
                  alignment: WrapAlignment.center,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  children: List.generate(
                    rarity,
                    (index) => const Icon(
                      Icons.star,
                      size: 15,
                      color: Colors.yellow,
                    ),
                  ),
                ),
              ],
            ),
          ),
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
