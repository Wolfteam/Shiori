import 'package:flutter/material.dart';
import 'package:shiori/domain/assets.dart';
import 'package:shiori/domain/enums/enums.dart';

class ArtifactImageType extends StatelessWidget {
  final int index;
  final double width;
  final double height;

  const ArtifactImageType({
    Key? key,
    required this.index,
    this.width = 24,
    this.height = 24,
  }) : super(key: key);

  ArtifactImageType.fromType({
    Key? key,
    required ArtifactType type,
    this.width = 24,
    this.height = 24,
  })  : index = type.index,
        super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Image.asset(
      Assets.getArtifactPathFromType(ArtifactType.values[index]),
      width: width,
      height: height,
      color: theme.brightness == Brightness.dark ? Colors.white : Colors.black,
    );
  }
}
