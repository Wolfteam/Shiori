import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:genshindb/application/bloc.dart';
import 'package:genshindb/domain/enums/enums.dart';
import 'package:genshindb/domain/extensions/string_extensions.dart';
import 'package:genshindb/domain/models/models.dart';
import 'package:genshindb/presentation/artifacts/artifacts_page.dart';
import 'package:genshindb/presentation/characters/characters_page.dart';
import 'package:genshindb/presentation/materials/materials_page.dart';
import 'package:genshindb/presentation/monsters/monsters_page.dart';
import 'package:genshindb/presentation/shared/circle_item.dart';
import 'package:genshindb/presentation/weapons/weapons_page.dart';

class NotificationCircleItem extends StatelessWidget {
  final AppNotificationType type;
  final AppNotificationItemType? itemType;
  final bool showOtherImages;
  final List<NotificationItemImage> images;

  NotificationItemImage get selected => images.firstWhere((el) => el.isSelected);

  const NotificationCircleItem({
    Key? key,
    required this.type,
    required this.images,
    this.showOtherImages = false,
  })  : itemType = null,
        super(key: key);

  const NotificationCircleItem.custom({
    Key? key,
    required this.itemType,
    required this.images,
    this.showOtherImages = false,
  })  : type = AppNotificationType.custom,
        super(key: key);

  @override
  Widget build(BuildContext context) {
    final ignored = [AppNotificationType.resin, AppNotificationType.custom];
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Center(
          child: CircleItem(
            radius: 40,
            image: selected.image,
            onTap: (_) => _onMainIconTap(context),
          ),
        ),
        if (showOtherImages && !ignored.contains(type))
          SizedBox(
            height: 70,
            child: ListView.builder(
              itemCount: images.length,
              shrinkWrap: true,
              scrollDirection: Axis.horizontal,
              itemBuilder: (ctx, index) => _buildCircleAvatar(context, images[index]),
            ),
          ),
      ],
    );
  }

  Widget _buildCircleAvatar(BuildContext context, NotificationItemImage item) {
    final isSelected = selected == item;
    return _buildSelectableImage(context, item.image, isSelected: isSelected);
  }

  Widget _buildSelectableImage(BuildContext context, String theImage, {bool isSelected = false}) {
    final circleItem = CircleItem(image: theImage, onTap: (_) => _changeSelectedImg(theImage, context));
    if (!isSelected) {
      return Center(child: circleItem);
    }
    return Center(
      child: Stack(
        alignment: Alignment.center,
        children: [
          const Positioned(top: 0, right: 0, child: Icon(Icons.check, color: Colors.green)),
          CircleItem(image: theImage, onTap: (_) => _changeSelectedImg(theImage, context)),
        ],
      ),
    );
  }

  Future<void> _onMainIconTap(BuildContext context) async {
    switch (type) {
      case AppNotificationType.resin:
        break;
      case AppNotificationType.expedition:
        _toggleShowOtherImages(context);
        break;
      case AppNotificationType.farmingArtifacts:
        break;
      case AppNotificationType.farmingMaterials:
        _toggleShowOtherImages(context);
        break;
      case AppNotificationType.gadget:
        _toggleShowOtherImages(context);
        break;
      case AppNotificationType.furniture:
      case AppNotificationType.realmCurrency:
        break;
      case AppNotificationType.weeklyBoss:
        _toggleShowOtherImages(context);
        break;
      case AppNotificationType.custom:
        switch (itemType) {
          case AppNotificationItemType.character:
            await _openCharactersPage(context);
            break;
          case AppNotificationItemType.weapon:
            await _openWeaponsPage(context);
            break;
          case AppNotificationItemType.monster:
            await _openMonstersPage(context);
            break;
          case AppNotificationItemType.artifact:
            await _openArtifactsPage(context);
            break;
          case AppNotificationItemType.material:
            await _openMaterialsPage(context);
            break;
          default:
            throw Exception('Invalid app notification type = $type');
        }
        break;
      case AppNotificationType.dailyCheckIn:
        break;
    }
  }

  Future<void> _openCharactersPage(BuildContext context) async {
    final keyName = await CharactersPage.forSelection(context, excludeKeys: [selected.itemKey]);
    _onItemSelected(keyName, context);
  }

  Future<void> _openWeaponsPage(BuildContext context) async {
    final keyName = await WeaponsPage.forSelection(context, excludeKeys: [selected.itemKey]);
    _onItemSelected(keyName, context);
  }

  Future<void> _openMonstersPage(BuildContext context) async {
    final keyName = await MonstersPage.forSelection(context, excludeKeys: [selected.itemKey]);
    _onItemSelected(keyName, context);
  }

  Future<void> _openArtifactsPage(BuildContext context) async {
    final keyName = await ArtifactsPage.forSelection(context, excludeKeys: [selected.itemKey]);
    _onItemSelected(keyName, context);
  }

  Future<void> _openMaterialsPage(BuildContext context) async {
    final keyName = await MaterialsPage.forSelection(context, excludeKeys: [selected.itemKey]);
    _onItemSelected(keyName, context);
  }

  void _onItemSelected(String? keyName, BuildContext context) {
    if (keyName.isNullEmptyOrWhitespace) {
      return;
    }

    context.read<NotificationBloc>().add(NotificationEvent.keySelected(keyName: keyName!));
  }

  void _changeSelectedImg(String newValue, BuildContext context) =>
      context.read<NotificationBloc>().add(NotificationEvent.imageChanged(newValue: newValue));

  void _toggleShowOtherImages(BuildContext context) =>
      context.read<NotificationBloc>().add(NotificationEvent.showOtherImages(show: !showOtherImages));
}
