import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:genshindb/application/bloc.dart';
import 'package:genshindb/generated/l10n.dart';
import 'package:genshindb/presentation/character/widgets/character_detail.dart';
import 'package:genshindb/presentation/character/widgets/character_detail_general_card.dart';
import 'package:genshindb/presentation/shared/details/detail_top_layout.dart';
import 'package:genshindb/presentation/shared/extensions/element_type_extensions.dart';
import 'package:genshindb/presentation/shared/extensions/i18n_extensions.dart';
import 'package:genshindb/presentation/shared/loading.dart';

class CharacterDetailTop extends StatelessWidget {
  const CharacterDetailTop({
    Key? key,
  }) : super(key: key);

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
            role: s.translateCharacterType(state.role),
            weaponType: state.weaponType,
            birthday: state.birthday,
          ),
          appBar: AppBar(
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
      ),
    );
  }

  void _favoriteCharacter(String key, bool isInInventory, BuildContext context) {
    final event = !isInInventory ? InventoryEvent.addCharacter(key: key) : InventoryEvent.deleteCharacter(key: key);
    context.read<InventoryBloc>().add(event);
  }
}
