import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shiori/application/bloc.dart';
import 'package:shiori/domain/enums/enums.dart';
import 'package:shiori/domain/extensions/string_extensions.dart';
import 'package:shiori/domain/models/models.dart';
import 'package:shiori/presentation/artifacts/artifacts_page.dart';
import 'package:shiori/presentation/characters/characters_page.dart';
import 'package:shiori/presentation/materials/materials_page.dart';
import 'package:shiori/presentation/monsters/monsters_page.dart';
import 'package:shiori/presentation/shared/images/circle_item_image.dart';
import 'package:shiori/presentation/weapons/weapons_page.dart';

class NotificationCircleItem extends StatelessWidget {
  final AppNotificationType type;
  final AppNotificationItemType? itemType;
  final bool showOtherImages;
  final List<NotificationItemImage> images;

  NotificationItemImage get selected => images.firstWhere((el) => el.isSelected);

  const NotificationCircleItem({
    super.key,
    required this.type,
    required this.images,
    this.showOtherImages = false,
  }) : itemType = null;

  const NotificationCircleItem.custom({
    super.key,
    required this.itemType,
    required this.images,
    this.showOtherImages = false,
  }) : type = AppNotificationType.custom;

  @override
  Widget build(BuildContext context) {
    final ignored = [AppNotificationType.resin, AppNotificationType.custom];
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (images.isNotEmpty)
          Center(
            child: CircleItemImage(
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
    final circleItem = CircleItemImage(
      image: theImage,
      fit: BoxFit.contain,
      onTap: (_) => _changeSelectedImg(theImage, context),
    );
    if (!isSelected) {
      return Center(child: circleItem);
    }
    return Center(
      child: Stack(
        alignment: Alignment.center,
        children: [
          circleItem,
          Positioned(
            top: 0,
            right: 0,
            child: DecoratedBox(
              decoration: BoxDecoration(
                color: Colors.green.withOpacity(0.8),
                border: Border.all(color: Colors.green),
                borderRadius: BorderRadius.circular(20),
              ),
              child: const Icon(Icons.check, color: Colors.white),
            ),
          ),
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
      case AppNotificationType.farmingArtifacts:
        break;
      case AppNotificationType.farmingMaterials:
        _toggleShowOtherImages(context);
      case AppNotificationType.gadget:
        _toggleShowOtherImages(context);
      case AppNotificationType.furniture:
      case AppNotificationType.realmCurrency:
        break;
      case AppNotificationType.weeklyBoss:
        _toggleShowOtherImages(context);
      case AppNotificationType.custom:
        switch (itemType) {
          case AppNotificationItemType.character:
            await _openCharactersPage(context);
          case AppNotificationItemType.weapon:
            await _openWeaponsPage(context);
          case AppNotificationItemType.monster:
            await _openMonstersPage(context);
          case AppNotificationItemType.artifact:
            await _openArtifactsPage(context);
          case AppNotificationItemType.material:
            await _openMaterialsPage(context);
          default:
            throw Exception('Invalid app notification type = $type');
        }
      case AppNotificationType.dailyCheckIn:
        break;
    }
  }

  Future<void> _openCharactersPage(BuildContext context) async {
    await CharactersPage.forSelection(context, excludeKeys: [selected.itemKey]).then((keyName) {
      if (context.mounted) {
        _onItemSelected(keyName, context);
      }
    });
  }

  Future<void> _openWeaponsPage(BuildContext context) async {
    await WeaponsPage.forSelection(context, excludeKeys: [selected.itemKey]).then((keyName) {
      if (context.mounted) {
        _onItemSelected(keyName, context);
      }
    });
  }

  Future<void> _openMonstersPage(BuildContext context) async {
    await MonstersPage.forSelection(context, excludeKeys: [selected.itemKey]).then((keyName) {
      if (context.mounted) {
        _onItemSelected(keyName, context);
      }
    });
  }

  Future<void> _openArtifactsPage(BuildContext context) async {
    await ArtifactsPage.forSelection(context, excludeKeys: [selected.itemKey]).then((keyName) {
      if (context.mounted) {
        _onItemSelected(keyName, context);
      }
    });
  }

  Future<void> _openMaterialsPage(BuildContext context) async {
    await MaterialsPage.forSelection(context, excludeKeys: [selected.itemKey]).then((keyName) {
      if (context.mounted) {
        _onItemSelected(keyName, context);
      }
    });
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
