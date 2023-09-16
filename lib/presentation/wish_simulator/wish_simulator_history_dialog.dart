import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shiori/application/bloc.dart';
import 'package:shiori/domain/enums/enums.dart';
import 'package:shiori/domain/extensions/iterable_extensions.dart';
import 'package:shiori/domain/models/models.dart';
import 'package:shiori/domain/wish_banner_constants.dart';
import 'package:shiori/generated/l10n.dart';
import 'package:shiori/injection.dart';
import 'package:shiori/presentation/character/character_page.dart';
import 'package:shiori/presentation/shared/dialogs/confirm_dialog.dart';
import 'package:shiori/presentation/shared/extensions/i18n_extensions.dart';
import 'package:shiori/presentation/shared/extensions/media_query_extensions.dart';
import 'package:shiori/presentation/shared/item_popupmenu_filter.dart';
import 'package:shiori/presentation/shared/loading.dart';
import 'package:shiori/presentation/shared/nothing_found_column.dart';
import 'package:shiori/presentation/shared/styles.dart';
import 'package:shiori/presentation/weapon/weapon_page.dart';

class WishSimulatorHistoryDialog extends StatelessWidget {
  final BannerItemType bannerType;

  const WishSimulatorHistoryDialog({super.key, required this.bannerType});

  @override
  Widget build(BuildContext context) {
    final mq = MediaQuery.of(context);
    final s = S.of(context);
    return BlocProvider<WishSimulatorPullHistoryBloc>(
      create: (context) => Injection.wishSimulatorPullHistoryBloc..add(WishSimulatorPullHistoryEvent.init(bannerType: bannerType)),
      child: BlocBuilder<WishSimulatorPullHistoryBloc, WishSimulatorPullHistoryState>(
        builder: (context, state) => AlertDialog(
          title: _TableTitle(
            bannerType: state.map(loading: (_) => bannerType, loaded: (state) => state.bannerType),
            showDeleteIcon: state.map(loading: (_) => false, loaded: (state) => state.items.isNotEmpty),
          ),
          content: SizedBox(
            width: mq.getWidthForDialogs(),
            height: mq.getHeightForDialogs(WishSimulatorPullHistoryBloc.take + 2),
            child: state.map(
              loading: (_) => const Loading(useScaffold: false),
              loaded: (state) => state.allItems.isEmpty
                  ? const NothingFoundColumn()
                  : SingleChildScrollView(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          SingleChildScrollView(
                            scrollDirection: Axis.horizontal,
                            child: _Table(items: state.items),
                          ),
                          _TablePagination(maxPage: state.maxPage, currentPage: state.currentPage),
                        ],
                      ),
                    ),
            ),
          ),
          actions: [
            ElevatedButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text(s.ok),
            ),
          ],
        ),
      ),
    );
  }
}

class _TableTitle extends StatelessWidget {
  final BannerItemType bannerType;
  final bool showDeleteIcon;

  const _TableTitle({
    required this.bannerType,
    required this.showDeleteIcon,
  });

  @override
  Widget build(BuildContext context) {
    final s = S.of(context);
    final title = '${s.wishHistory} (${s.translateBannerItemType(bannerType)})';
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Expanded(
          child: Tooltip(
            message: title,
            child: Text(
              title,
              overflow: TextOverflow.ellipsis,
              maxLines: 2,
            ),
          ),
        ),
        const Spacer(),
        ItemPopupMenuFilter<BannerItemType>(
          tooltipText: s.bannerType,
          selectedValue: bannerType,
          values: BannerItemType.values,
          onSelected: (val) => context.read<WishSimulatorPullHistoryBloc>().add(WishSimulatorPullHistoryEvent.init(bannerType: val)),
          icon: const Icon(Icons.filter_alt),
          splashRadius: Styles.smallButtonSplashRadius,
          itemText: (val, _) => s.translateBannerItemType(val),
        ),
        if (showDeleteIcon)
          IconButton(
            icon: const Icon(Icons.clear_all),
            splashRadius: Styles.smallButtonSplashRadius,
            onPressed: () => showDialog<bool>(
              context: context,
              builder: (context) => ConfirmDialog(
                content: s.confirmQuestion,
                title: s.deleteAllItems,
              ),
            ).then((confirmed) {
              if (confirmed == true) {
                context.read<WishSimulatorPullHistoryBloc>().add(WishSimulatorPullHistoryEvent.deleteData(bannerType: bannerType));
              }
            }),
          ),
      ],
    );
  }
}

class _Table extends StatelessWidget {
  final List<WishSimulatorBannerItemPullHistoryModel> items;

  const _Table({required this.items});

  @override
  Widget build(BuildContext context) {
    final s = S.of(context);
    final mq = MediaQuery.of(context);
    final width = mq.getWidthForDialogs();
    return SizedBox(
      width: width * 1.5,
      child: DataTable(
        showCheckboxColumn: false,
        columns: <DataColumn>[
          DataColumn(
            tooltip: s.itemType,
            label: Expanded(
              child: Text(
                s.itemType,
                overflow: TextOverflow.ellipsis,
                textAlign: TextAlign.center,
              ),
            ),
          ),
          DataColumn(
            tooltip: s.itemName,
            label: Expanded(
              child: Text(
                s.itemName,
                overflow: TextOverflow.ellipsis,
                textAlign: TextAlign.center,
              ),
            ),
          ),
          DataColumn(
            tooltip: s.timeReceived,
            label: Expanded(
              child: Text(
                s.timeReceived,
                overflow: TextOverflow.ellipsis,
                textAlign: TextAlign.center,
              ),
            ),
          ),
        ],
        rows: items.mapIndex((e, index) => _buildRow(index, e, width, context, s)).toList(),
      ),
    );
  }

  DataRow _buildRow(int index, WishSimulatorBannerItemPullHistoryModel item, double width, BuildContext context, S s) {
    TextStyle? nameStyle;
    String name = item.name;
    if (item.rarity > WishBannerConstants.minObtainableRarity) {
      final color = item.rarity == WishBannerConstants.maxObtainableRarity
          ? Styles.fiveStarWishResultBackgroundColor
          : Styles.fourStarWishResultBackgroundColor;
      final defaultStyle = DefaultTextStyle.of(context).style;
      name += ' (${s.xStar(item.rarity)})';
      nameStyle = defaultStyle.copyWith(color: color, fontWeight: FontWeight.bold);
    }
    final isTapEnabled = [ItemType.character, ItemType.weapon].contains(item.type);
    return DataRow(
      color: MaterialStateProperty.resolveWith<Color?>((states) {
        if (index.isEven) {
          return Colors.grey.withOpacity(0.3);
        }
        return null;
      }),
      onSelectChanged: !isTapEnabled
          ? null
          : (_) => item.type == ItemType.character ? CharacterPage.route(item.key, context) : WeaponPage.route(item.key, context),
      cells: [
        DataCell(
          Center(
            child: Text(
              s.translateItemType(item.type),
              overflow: TextOverflow.ellipsis,
              maxLines: 1,
              textAlign: TextAlign.center,
            ),
          ),
        ),
        DataCell(
          Center(
            child: Text(
              name,
              style: nameStyle,
              overflow: TextOverflow.ellipsis,
              maxLines: 2,
              textAlign: TextAlign.center,
            ),
          ),
        ),
        DataCell(
          Center(
            child: Text(
              item.pulledOn,
              overflow: TextOverflow.ellipsis,
              maxLines: 2,
              textAlign: TextAlign.center,
            ),
          ),
        ),
      ],
    );
  }
}

class _TablePagination extends StatelessWidget {
  final int maxPage;
  final int currentPage;

  const _TablePagination({
    required this.maxPage,
    required this.currentPage,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        IconButton(
          icon: const Icon(Icons.chevron_left),
          splashRadius: Styles.smallButtonSplashRadius,
          onPressed: currentPage - 1 <= 0
              ? null
              : () => context.read<WishSimulatorPullHistoryBloc>().add(WishSimulatorPullHistoryEvent.pageChanged(page: currentPage - 1)),
        ),
        Text('$currentPage'),
        IconButton(
          icon: const Icon(Icons.chevron_right),
          splashRadius: Styles.smallButtonSplashRadius,
          onPressed: currentPage + 1 > maxPage
              ? null
              : () => context.read<WishSimulatorPullHistoryBloc>().add(WishSimulatorPullHistoryEvent.pageChanged(page: currentPage + 1)),
        ),
      ],
    );
  }
}
