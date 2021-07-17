import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:genshindb/application/bloc.dart';
import 'package:genshindb/generated/l10n.dart';
import 'package:genshindb/presentation/character/widgets/character_detail.dart';
import 'package:genshindb/presentation/character/widgets/character_detail_general_card.dart';
import 'package:genshindb/presentation/shared/extensions/element_type_extensions.dart';
import 'package:genshindb/presentation/shared/extensions/i18n_extensions.dart';
import 'package:genshindb/presentation/shared/loading.dart';
import 'package:responsive_builder/responsive_builder.dart';

class CharacterDetailTop extends StatelessWidget {
  const CharacterDetailTop({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final s = S.of(context);
    final mediaQuery = MediaQuery.of(context);
    final isPortrait = mediaQuery.orientation == Orientation.portrait;
    final imgHeight = mediaQuery.size.height;
    final device = getDeviceType(mediaQuery.size);
    final descriptionWidth = (mediaQuery.size.width / (isPortrait ? 1 : 2)) / (device == DeviceScreenType.mobile ? 1.2 : 2);

    return BlocBuilder<CharacterBloc, CharacterState>(
      builder: (ctx, state) => state.map(
        loading: (_) => const Loading(useScaffold: false),
        loaded: (state) => Container(
          height: isPortrait ? getTopHeightForPortrait(context) : null,
          color: state.elementType.getElementColorFromContext(context),
          child: Stack(
            fit: StackFit.passthrough,
            alignment: Alignment.center,
            children: <Widget>[
              ShadowImage(fullImage: state.fullImage, secondFullImage: state.secondFullImage),
              Align(
                alignment: Alignment.bottomLeft,
                child: Image.asset(
                  state.fullImage,
                  fit: BoxFit.fill,
                  width: isPortrait ? 340 : null,
                  height: isPortrait ? imgHeight : null,
                ),
              ),
              Align(
                alignment: isPortrait ? Alignment.center : Alignment.bottomCenter,
                child: SizedBox(
                  height: charDescriptionHeight,
                  width: descriptionWidth,
                  child: CharacterDetailGeneralCard(
                    elementType: state.elementType,
                    isFemale: state.isFemale,
                    name: state.name,
                    rarity: state.rarity,
                    region: state.region,
                    role: s.translateCharacterType(state.role),
                    weaponType: state.weaponType,
                    birthday: state.birthday,
                  ),
                ),
              ),
              Positioned(
                top: 0.0,
                left: 0.0,
                right: 0.0,
                child: AppBar(
                  backgroundColor: Colors.transparent,
                  elevation: 0.0,
                  actions: [
                    BlocBuilder<CharacterBloc, CharacterState>(
                      builder: (ctx, state) => state.map(
                        loading: (_) => const Loading(useScaffold: false),
                        loaded: (state) => IconButton(
                          icon: Icon(state.isInInventory ? Icons.favorite : Icons.favorite_border),
                          color: Colors.red,
                          onPressed: () => _favoriteCharacter(state.key, state.isInInventory, context),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _favoriteCharacter(String key, bool isInInventory, BuildContext context) {
    final event = !isInInventory ? InventoryEvent.addCharacter(key: key) : InventoryEvent.deleteCharacter(key: key);
    context.read<InventoryBloc>().add(event);
  }
}

class ShadowImage extends StatelessWidget {
  final String fullImage;
  final String? secondFullImage;

  const ShadowImage({
    Key? key,
    required this.fullImage,
    this.secondFullImage,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final mediaQuery = MediaQuery.of(context);
    final isPortrait = mediaQuery.orientation == Orientation.portrait;
    final imgHeight = mediaQuery.size.height;
    if (!isPortrait) {
      return Positioned(
        top: 0,
        right: -40,
        bottom: 30,
        child: Opacity(
          opacity: 0.5,
          child: Image.asset(
            secondFullImage ?? fullImage,
            fit: BoxFit.fill,
            width: isPortrait ? 350 : null,
            height: isPortrait ? imgHeight : null,
          ),
        ),
      );
    }
    return Align(
      alignment: Alignment.bottomRight,
      child: Container(
        transform: Matrix4.translationValues(60, -30, 0.0),
        child: Opacity(
          opacity: 0.5,
          child: Image.asset(
            secondFullImage ?? fullImage,
            fit: BoxFit.fill,
            width: isPortrait ? 350 : null,
            height: isPortrait ? imgHeight : null,
          ),
        ),
      ),
    );
  }
}
