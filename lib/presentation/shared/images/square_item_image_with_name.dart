import 'package:flutter/material.dart';
import 'package:shiori/presentation/shared/images/square_item_image.dart';
import 'package:shiori/presentation/shared/styles.dart';

class SquareItemImageWithName extends StatelessWidget {
  final String itemKey;
  final String name;
  final String image;
  final double width;
  final double height;
  final VoidCallback? onTap;

  const SquareItemImageWithName({
    required this.itemKey,
    required this.name,
    required this.image,
    required this.width,
    required this.height,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      margin: Styles.edgeInsetHorizontal10,
      child: InkWell(
        onTap: onTap,
        child: SizedBox(
          width: width,
          height: height,
          child: Stack(
            alignment: Alignment.center,
            fit: StackFit.expand,
            children: [
              AbsorbPointer(
                child: SquareItemImage(
                  image: image,
                  size: 35,
                ),
              ),
              Align(
                alignment: Alignment.bottomCenter,
                child: Container(
                  width: width,
                  decoration: Styles.commonCardBoxDecoration,
                  child: Tooltip(
                    message: name,
                    child: Text(
                      name,
                      textAlign: TextAlign.center,
                      overflow: TextOverflow.ellipsis,
                      style: theme.textTheme.titleSmall!.copyWith(fontWeight: FontWeight.bold, color: Colors.white),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
