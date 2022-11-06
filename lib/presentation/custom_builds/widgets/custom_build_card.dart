import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:responsive_builder/responsive_builder.dart';
import 'package:shiori/application/bloc.dart';
import 'package:shiori/domain/enums/enums.dart';
import 'package:shiori/domain/models/models.dart';
import 'package:shiori/generated/l10n.dart';
import 'package:shiori/presentation/artifacts/widgets/artifact_card.dart';
import 'package:shiori/presentation/custom_build/custom_build_page.dart';
import 'package:shiori/presentation/shared/character_stack_image.dart';
import 'package:shiori/presentation/shared/dialogs/confirm_dialog.dart';
import 'package:shiori/presentation/shared/extensions/element_type_extensions.dart';
import 'package:shiori/presentation/shared/extensions/i18n_extensions.dart';
import 'package:shiori/presentation/shared/styles.dart';
import 'package:shiori/presentation/weapons/widgets/weapon_card.dart';

class CustomBuildCard extends StatelessWidget {
  final CustomBuildModel item;

  const CustomBuildCard({
    super.key,
    required this.item,
  });

  @override
  Widget build(BuildContext context) {
    final device = getDeviceType(MediaQuery.of(context).size);
    final s = S.of(context);
    final theme = Theme.of(context);
    String subtitle = s.translateCharacterRoleType(item.type);
    if (item.subType != CharacterRoleSubType.none) {
      subtitle += ' - ${s.translateCharacterRoleSubType(item.subType)}';
    }
    final color = item.character.elementType.getElementColorFromContext(context);
    return InkWell(
      onTap: () => _goToDetailsPage(context),
      child: Card(
        clipBehavior: Clip.hardEdge,
        elevation: Styles.cardTenElevation,
        color: color,
        shadowColor: Colors.transparent,
        child: Row(
          children: [
            Expanded(
              flex: device == DeviceScreenType.tablet ? 40 : 35,
              child: CharacterStackImage(
                name: item.character.name,
                image: item.character.image,
                rarity: item.character.stars,
                height: 350,
              ),
            ),
            Expanded(
              flex: device == DeviceScreenType.tablet ? 60 : 65,
              child: Padding(
                padding: Styles.edgeInsetHorizontal5,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Tooltip(
                                message: item.title,
                                child: Text(
                                  item.title,
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                  style: theme.textTheme.headline5!.copyWith(fontWeight: FontWeight.bold, color: Colors.white),
                                ),
                              ),
                              Text(
                                subtitle,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
                              ),
                            ],
                          ),
                        ),
                        Tooltip(
                          message: s.delete,
                          child: IconButton(
                            splashRadius: Styles.smallButtonSplashRadius,
                            icon: const Icon(Icons.delete, color: Colors.white),
                            onPressed: () => _showDeleteDialog(context),
                          ),
                        ),
                      ],
                    ),
                    Text(s.weapons, style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
                    SizedBox(
                      height: 100,
                      child: ListView.builder(
                        physics: const BouncingScrollPhysics(),
                        scrollDirection: Axis.horizontal,
                        itemCount: item.weapons.length,
                        itemBuilder: (ctx, index) {
                          final weapon = item.weapons[index];
                          final child = WeaponCard.withoutDetails(
                            keyName: weapon.key,
                            name: weapon.name,
                            rarity: weapon.rarity,
                            image: weapon.image,
                            isComingSoon: false,
                            imgHeight: 50,
                            imgWidth: 60,
                          );
                          return child;
                        },
                      ),
                    ),
                    Text(s.artifacts, style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
                    SizedBox(
                      height: 110,
                      child: ListView.builder(
                        physics: const BouncingScrollPhysics(),
                        scrollDirection: Axis.horizontal,
                        itemCount: item.artifacts.length,
                        itemBuilder: (ctx, index) {
                          final artifact = item.artifacts[index];
                          return ArtifactCard.withoutDetails(
                            name: s.translateStatTypeWithoutValue(artifact.statType),
                            image: artifact.image,
                            rarity: artifact.rarity,
                            keyName: artifact.key,
                            imgWidth: 55,
                            imgHeight: 45,
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),
            )
          ],
        ),
      ),
    );
  }

  Future<void> _goToDetailsPage(BuildContext context) async {
    final bloc = context.read<CustomBuildsBloc>();
    final route = MaterialPageRoute(
      builder: (ctx) => BlocProvider.value(
        value: bloc,
        child: CustomBuildPage(itemKey: item.key),
      ),
    );
    await Navigator.push(context, route);
  }

  Future<void> _showDeleteDialog(BuildContext context) {
    final s = S.of(context);
    return showDialog(
      context: context,
      builder: (_) => ConfirmDialog(
        title: s.delete,
        content: s.confirmQuestion,
        onOk: () => context.read<CustomBuildsBloc>().add(CustomBuildsEvent.delete(key: item.key)),
      ),
    );
  }
}
