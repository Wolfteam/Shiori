import 'package:flutter/material.dart';
import 'package:genshindb/presentation/character/widgets/character_detail.dart';
import 'package:genshindb/presentation/shared/styles.dart';
import 'package:responsive_builder/responsive_builder.dart';

import 'constants.dart';

class DetailBottomPortraitLayout extends StatelessWidget {
  final List<Widget> children;
  final bool isAnSmallImage;

  const DetailBottomPortraitLayout({
    Key? key,
    required this.children,
    this.isAnSmallImage = true,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final maxTopHeight = getTopMarginForPortrait(context, charDescriptionHeight, isAnSmallImage);
    final device = getDeviceType(size);
    final width = size.width * (device == DeviceScreenType.mobile ? 0.9 : 0.8);
    return SizedBox(
      width: width,
      child: Card(
        margin: EdgeInsets.only(top: maxTopHeight),
        shape: Styles.cardItemDetailShape,
        child: Padding(
          padding: Styles.edgeInsetAll10,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: children,
          ),
        ),
      ),
    );
  }
}
