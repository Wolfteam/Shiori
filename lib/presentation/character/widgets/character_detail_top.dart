import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shiori/application/bloc.dart';
import 'package:shiori/generated/l10n.dart';
import 'package:shiori/presentation/character/widgets/character_detail.dart';
import 'package:shiori/presentation/character/widgets/character_detail_general_card.dart';
import 'package:shiori/presentation/shared/details/detail_top_layout.dart';
import 'package:shiori/presentation/shared/extensions/element_type_extensions.dart';
import 'package:shiori/presentation/shared/extensions/i18n_extensions.dart';
import 'package:shiori/presentation/shared/loading.dart';
import 'package:shiori/presentation/shared/styles.dart';

class CharacterDetailTop extends StatelessWidget {
  const CharacterDetailTop({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final s = S.of(context);
    return BlocBuilder<CharacterBloc, CharacterState>(
      builder: (ctx, state) => state.map(
        loading: (_) => const Loading(useScaffold: false),
        loaded: (state) => DetailTopLayout(
          color: state.elementType.getElementColorFromContext(context),
          fullImage: state.fullImage,
          secondFullImage: state.secondFullImage,
          charDescriptionHeight: 260,
          generalCard: CharacterDetailGeneralCard(
            elementType: state.elementType,
            isFemale: state.isFemale,
            name: state.name,
            rarity: state.rarity,
            region: state.region,
            role: s.translateCharacterRoleType(state.role),
            weaponType: state.weaponType,
            birthday: state.birthday,
          ),
          appBar: AppBar(
            backgroundColor: Colors.transparent,
            elevation: 0.0,
            actions: [
              BlocBuilder<CharacterBloc, CharacterState>(
                builder: (context, state) => state.map(
                  loading: (_) => const Loading(useScaffold: false),
                  loaded: (state) => IconButton(
                    icon: Icon(state.isInInventory ? Icons.favorite : Icons.favorite_border),
                    color: Colors.red,
                    splashRadius: Styles.mediumButtonSplashRadius,
                    onPressed: () => _favoriteCharacter(state.key, state.isInInventory, context),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _favoriteCharacter(String key, bool isInInventory, BuildContext context) {
    final event = !isInInventory ? CharacterEvent.addToInventory(key: key) : CharacterEvent.deleteFromInventory(key: key);
    context.read<CharacterBloc>().add(event);
  }
}
