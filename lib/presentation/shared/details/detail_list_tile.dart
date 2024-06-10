import 'dart:io';

import 'package:flutter/material.dart';
import 'package:shiori/domain/assets.dart';
import 'package:shiori/domain/extensions/string_extensions.dart';
import 'package:shiori/presentation/shared/styles.dart';
import 'package:shiori/presentation/shared/utils/size_utils.dart';

class DetailListTile extends StatelessWidget {
  final String title;
  final String? subtitle;
  final Color color;
  final Widget leading;

  const DetailListTile({
    super.key,
    required this.title,
    this.subtitle,
    required this.color,
    required this.leading,
  });

  DetailListTile.icon({
    required this.title,
    this.subtitle,
    required this.color,
    required IconData icon,
  }) : leading = _LeadingIcon(icon: icon, color: color);

  DetailListTile.image({
    required this.title,
    this.subtitle,
    required this.color,
    required String image,
  }) : leading = _LeadingImage(color: color, image: image);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final titleStyle = theme.textTheme.bodyLarge!.copyWith(color: theme.colorScheme.onSurface);
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        children: [
          leading,
          const SizedBox(width: 5),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(title, style: titleStyle),
                if (subtitle.isNotNullEmptyOrWhitespace)
                  Text(
                    subtitle!,
                    style: theme.textTheme.bodyMedium!.copyWith(color: color),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _LeadingImage extends StatelessWidget {
  final String? image;
  final Color color;

  const _LeadingImage({
    this.image,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    final double size = SizeUtils.getSizeForSquareImages(context).height;
    return Container(
      height: size,
      width: size,
      decoration: BoxDecoration(
        color: color,
        shape: BoxShape.circle,
      ),
      alignment: Alignment.center,
      padding: Styles.edgeInsetAll10,
      child: image == Assets.noImageAvailablePath || image == null
          ? Image.asset(Assets.noImageAvailablePath, width: size, height: size, fit: BoxFit.cover)
          : Image.file(File(image!), width: size, height: size, fit: BoxFit.cover),
    );
  }
}

class _LeadingIcon extends StatelessWidget {
  final IconData icon;
  final Color color;

  const _LeadingIcon({
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    final double size = SizeUtils.getSizeForSquareImages(context).height;
    return Container(
      height: size,
      width: size,
      decoration: BoxDecoration(
        color: color,
        shape: BoxShape.circle,
      ),
      alignment: Alignment.center,
      child: Icon(icon, color: Colors.white, size: size / 1.25),
    );
  }
}
