import 'package:flutter/material.dart';
import 'package:shiori/domain/assets.dart';
import 'package:shiori/domain/services/genshin_service.dart';
import 'package:shiori/domain/services/resources_service.dart';
import 'package:shiori/injection.dart';
import 'package:shiori/presentation/shared/styles.dart';
import 'package:shiori/presentation/wish_simulator/widgets/wish_result_item.dart';

class WishResultPage extends StatelessWidget {
  const WishResultPage({super.key});

  @override
  Widget build(BuildContext context) {
    final genshinService = getIt<GenshinService>();
    final resourceService = getIt<ResourceService>();
    final chars = genshinService.characters.getCharactersForCard().where((element) => !element.key.startsWith('traveler')).toList();
    return Scaffold(
      body: Ink(
        decoration: BoxDecoration(
          image: DecorationImage(
            image: AssetImage(Assets.wishBannerResultBackgroundImgPath),
            fit: BoxFit.fill,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Container(
              margin: const EdgeInsets.only(top: 10, right: 20),
              alignment: Alignment.topRight,
              child: CircleAvatar(
                backgroundColor: Styles.wishButtonBackgroundColor,
                radius: 20,
                child: IconButton(
                  onPressed: () => Navigator.pop(context),
                  splashRadius: Styles.mediumButtonSplashRadius,
                  icon: const Icon(Icons.close),
                  color: Colors.black,
                ),
              ),
            ),
            Expanded(
              child: LayoutBuilder(
                builder: (context, constraints) => Center(
                  child: Container(
                    height: constraints.maxWidth * 0.8,
                    constraints: BoxConstraints(
                      maxHeight: constraints.maxHeight * 0.7,
                      minHeight: constraints.maxHeight * 0.4,
                    ),
                    child: ListView.builder(
                      itemCount: chars.length,
                      scrollDirection: Axis.horizontal,
                      itemBuilder: (context, index) => WishResultItem.character(
                        image: resourceService.getCharacterImagePath('${chars[index].key}.webp'),
                        rarity: chars[index].stars,
                        elementType: chars[index].elementType,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
