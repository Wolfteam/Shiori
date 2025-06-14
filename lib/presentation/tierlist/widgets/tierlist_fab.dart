import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shiori/application/bloc.dart';
import 'package:shiori/domain/models/models.dart';
import 'package:shiori/presentation/shared/images/character_icon_image.dart';
import 'package:shiori/presentation/shared/styles.dart';

class TierListFab extends StatelessWidget {
  final double height;

  const TierListFab({super.key, required this.height});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<TierListBloc, TierListState>(
      builder: (ctx, state) => !state.readyToSave && state.charsAvailable.isNotEmpty
          ? ColoredBox(
              color: Colors.black.withValues(alpha: 0.5),
              child: SizedBox(
                height: height,
                width: double.infinity,
                child: ListView(
                  padding: EdgeInsets.zero,
                  physics: const BouncingScrollPhysics(),
                  shrinkWrap: true,
                  scrollDirection: Axis.horizontal,
                  children: state.charsAvailable.map((e) => _DraggableItem(item: e)).toList(),
                ),
              ),
            )
          : Container(),
    );
  }
}

class _DraggableItem extends StatelessWidget {
  final ItemCommon item;

  const _DraggableItem({required this.item});

  @override
  Widget build(BuildContext context) {
    const double radius = 40;
    return Draggable<ItemCommon>(
      data: item,
      feedback: CharacterIconImage.circleItem(item: item, forDrag: true),
      childWhenDragging: CircleAvatar(
        backgroundColor: Colors.black.withValues(alpha: 0.4),
        radius: radius,
      ),
      child: Container(
        margin: Styles.edgeInsetHorizontal16,
        child: CharacterIconImage.circleItem(
          item: item,
          size: radius,
          gradient: Styles.blackGradientForCircleItems,
        ),
      ),
    );
  }
}
