import 'package:flutter/material.dart';
import 'package:shiori/domain/models/models.dart';
import 'package:shiori/generated/l10n.dart';
import 'package:shiori/presentation/shared/details/detail_section.dart';
import 'package:shiori/presentation/shared/images/square_item_image_with_name.dart';
import 'package:shiori/presentation/shared/utils/size_utils.dart';

typedef OnTap = void Function(String key);

class DetailHorizontalList extends StatelessWidget {
  final Color color;
  final String title;
  final List<ItemCommonWithName> items;
  final OnTap onTap;
  final VoidCallback onButtonTap;

  const DetailHorizontalList({
    required this.color,
    required this.title,
    required this.items,
    required this.onTap,
    required this.onButtonTap,
  });

  @override
  Widget build(BuildContext context) {
    final s = S.of(context);
    return DetailSection.complex(
      title: title,
      color: color,
      children: [
        DetailHorizontalListView(
          onTap: onTap,
          items: items,
        ),
        DetailHorizontalListButton(
          color: color,
          title: s.seeAll,
          onTap: onButtonTap,
        ),
      ],
    );
  }
}

class DetailHorizontalListView extends StatelessWidget {
  final List<ItemCommonWithName> items;
  final OnTap onTap;
  final bool useSmallImageSize;

  const DetailHorizontalListView({
    required this.items,
    required this.onTap,
    this.useSmallImageSize = false,
  });

  @override
  Widget build(BuildContext context) {
    final Size size = SizeUtils.getSizeForSquareImages(context, smallImage: useSmallImageSize);
    return SizedBox(
      height: size.height + 10,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: items.length,
        itemBuilder: (context, index) {
          final e = items[index];
          return SquareItemImageWithName(
            itemKey: e.key,
            name: e.name,
            image: e.iconImage,
            width: size.width,
            height: size.width,
            onTap: () => onTap(e.key),
          );
        },
      ),
    );
  }
}

class DetailHorizontalListButton extends StatelessWidget {
  final Color color;
  final String? title;
  final VoidCallback onTap;

  const DetailHorizontalListButton({
    required this.color,
    this.title,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final s = S.of(context);
    return Align(
      alignment: Alignment.centerRight,
      child: TextButton.icon(
        icon: const Icon(Icons.chevron_right),
        label: Text(title ?? s.seeAll),
        style: TextButton.styleFrom(foregroundColor: color),
        onPressed: onTap,
      ),
    );
  }
}
