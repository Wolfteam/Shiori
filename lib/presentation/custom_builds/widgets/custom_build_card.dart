import 'package:flutter/material.dart';
import 'package:responsive_builder/responsive_builder.dart';
import 'package:shiori/domain/models/models.dart';
import 'package:shiori/generated/l10n.dart';
import 'package:shiori/presentation/artifacts/widgets/artifact_card.dart';
import 'package:shiori/presentation/custom_build/custom_build_page.dart';
import 'package:shiori/presentation/shared/character_stack_image.dart';
import 'package:shiori/presentation/shared/extensions/element_type_extensions.dart';
import 'package:shiori/presentation/shared/styles.dart';
import 'package:shiori/presentation/weapons/widgets/weapon_card.dart';

class CustomBuildCard extends StatelessWidget {
  final CustomBuildModel item;

  const CustomBuildCard({
    Key? key,
    required this.item,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final device = getDeviceType(MediaQuery.of(context).size);
    final s = S.of(context);
    final theme = Theme.of(context);
    return InkWell(
      onTap: () => _goToDetailsPage(context),
      child: Card(
        clipBehavior: Clip.hardEdge,
        // shape: Styles.mainCardShape,
        elevation: Styles.cardTenElevation,
        color: item.character.elementType.getElementColorFromContext(context),
        shadowColor: Colors.transparent,
        // margin: Styles.edgeInsetVertical5,
        child: Row(
          // crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Expanded(
              flex: device == DeviceScreenType.tablet ? 40 : 35,
              child: CharacterStackImage(
                name: item.character.name,
                image: item.character.image,
                rarity: item.character.stars,
              ),
            ),
            Expanded(
              flex: device == DeviceScreenType.tablet ? 60 : 65,
              child: Padding(
                padding: Styles.edgeInsetHorizontal5,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text(
                      item.title,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: theme.textTheme.headline5!.copyWith(fontWeight: FontWeight.bold),
                    ),
                    Text('Weapons', style: TextStyle(fontWeight: FontWeight.bold)),
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
                    Text('Artifacts', style: TextStyle(fontWeight: FontWeight.bold)),
                    SizedBox(
                      height: 110,
                      child: ListView.builder(
                        physics: const BouncingScrollPhysics(),
                        scrollDirection: Axis.horizontal,
                        itemCount: item.artifacts.length,
                        itemBuilder: (ctx, index) {
                          return ArtifactCard.withoutDetails(
                            name: 'Hp',
                            image: item.artifacts[index].image,
                            rarity: item.artifacts[index].rarity,
                            keyName: item.artifacts[index].key,
                            imgWidth: 55,
                            imgHeight: 45,
                          );
                        },
                      ),
                    )
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
    final route = MaterialPageRoute(builder: (ctx) => CustomBuildPage(itemKey: item.key));
    await Navigator.push(context, route);
  }
}
