import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shiori/application/bloc.dart';
import 'package:shiori/domain/models/models.dart';
import 'package:shiori/presentation/shared/images/circle_character.dart';
import 'package:shiori/presentation/shared/styles.dart';

class TierListFab extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return BlocBuilder<TierListBloc, TierListState>(
      builder: (ctx, state) => !state.readyToSave
          ? Container(
              color: Colors.black.withOpacity(0.5),
              child: SizedBox(
                height: 100,
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
    return Draggable<ItemCommon>(
      data: item,
      feedback: CircleCharacter.fromItem(item: item, forDrag: true),
      childWhenDragging: CircleAvatar(
        backgroundColor: Colors.black.withOpacity(0.4),
        radius: 40,
      ),
      child: Container(
        margin: Styles.edgeInsetHorizontal16,
        child: CircleCharacter.fromItem(item: item, radius: 40),
      ),
    );
  }
}
