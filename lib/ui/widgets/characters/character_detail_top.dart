import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../bloc/bloc.dart';
import '../../../common/extensions/element_type_extensions.dart';
import '../common/loading.dart';
import 'character_detail.dart';

class CharacterDetailTop extends StatelessWidget {
  const CharacterDetailTop({Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final mediaQuery = MediaQuery.of(context);
    final isPortrait = mediaQuery.orientation == Orientation.portrait;
    final descriptionWidth = mediaQuery.size.width / (isPortrait ? 1.2 : 2);
    //TODO: IM NOT SURE HOW THIS WILL LOOK LIKE IN BIGGER DEVICES
    // final padding = mediaQuery.padding;
    // final screenHeight = mediaQuery.size.height - padding.top - padding.bottom;

    return BlocBuilder<CharacterBloc, CharacterState>(
      builder: (ctx, state) => state.map(
        loading: (_) => const Loading(useScaffold: false),
        loaded: (state) => Container(
          color: state.elementType.getElementColorFromContext(context),
          child: Stack(
            fit: StackFit.passthrough,
            alignment: Alignment.center,
            children: <Widget>[
              Align(
                alignment: Alignment.topRight,
                child: Container(
                  transform: Matrix4.translationValues(60, -30, 0.0),
                  child: Opacity(
                    opacity: 0.5,
                    child: Image.asset(
                      state.secondFullImage ?? state.fullImage,
                      width: 350,
                      height: imgHeight,
                    ),
                  ),
                ),
              ),
              Align(
                alignment: Alignment.topLeft,
                child: Image.asset(
                  state.fullImage,
                  width: 340,
                  height: imgHeight,
                ),
              ),
              Align(
                alignment: Alignment.bottomCenter,
                child: Container(
                  width: descriptionWidth,
                  margin: const EdgeInsets.symmetric(horizontal: 30),
                  child: CharacterDetailGeneralCard(
                    elementType: state.elementType,
                    isFemale: state.isFemale,
                    name: state.name,
                    rarity: state.rarity,
                    region: state.region,
                    role: state.role,
                    weaponType: state.weaponType,
                  ),
                ),
              ),
              Positioned(
                top: 0.0,
                left: 0.0,
                right: 0.0,
                child: AppBar(backgroundColor: Colors.transparent, elevation: 0.0),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
