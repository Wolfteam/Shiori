import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:genshindb/application/bloc.dart';
import 'package:genshindb/presentation/shared/circle_character.dart';
import 'package:genshindb/presentation/shared/loading.dart';
import 'package:genshindb/presentation/shared/styles.dart';

class TierListFab extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return BlocBuilder<TierListBloc, TierListState>(
      builder: (ctx, state) => state.map(
        loading: (_) => const Loading(useScaffold: false),
        loaded: (state) => !state.readyToSave
            ? Container(
                color: Colors.black.withOpacity(0.5),
                child: SizedBox(
                  height: 100,
                  child: ListView(
                    padding: EdgeInsets.zero,
                    physics: const BouncingScrollPhysics(),
                    shrinkWrap: true,
                    scrollDirection: Axis.horizontal,
                    children: state.charsAvailable.map((e) => _buildDraggableItem(e)).toList(),
                  ),
                ),
              )
            : Container(),
      ),
    );
  }

  Widget _buildDraggableItem(String charImg) {
    return Draggable<String>(
      data: charImg,
      feedback: CircleCharacter(image: charImg, forDrag: true),
      childWhenDragging: CircleAvatar(
        backgroundColor: Colors.black.withOpacity(0.4),
        radius: 40,
      ),
      child: Container(
        margin: Styles.edgeInsetHorizontal16,
        child: CircleCharacter(image: charImg, radius: 40),
      ),
    );
  }
}
