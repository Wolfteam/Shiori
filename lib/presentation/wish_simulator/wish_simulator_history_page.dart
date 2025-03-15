import 'dart:ui';

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
import 'package:shiori/presentation/shared/item_popupmenu_filter.dart';
import 'package:shiori/presentation/shared/loading.dart';
import 'package:shiori/presentation/shared/nothing_found_column.dart';
import 'package:shiori/presentation/shared/styles.dart';
import 'package:shiori/presentation/weapon/weapon_page.dart';

class _CustomRoute extends PageRoute<void> {
  final WidgetBuilder builder;

  _CustomRoute({required this.builder});

  @override
  bool get opaque => false;

  @override
  Duration get transitionDuration => Duration.zero;

  @override
  bool get barrierDismissible => true;

  @override
  Color? get barrierColor => null;

  @override
  String? get barrierLabel => null;

  @override
  bool get maintainState => true;

  @override
  String get debugLabel => '${super.debugLabel}(${settings.name})';

  @override
  Widget buildPage(BuildContext context, Animation<double> animation, Animation<double> secondaryAnimation) {
    final result = builder(context);
    return Semantics(
      scopesRoute: true,
      explicitChildNodes: true,
      child: result,
    );
  }

  @override
  Widget buildTransitions(BuildContext context, Animation<double> animation, Animation<double> secondaryAnimation, Widget child) {
    final PageTransitionsTheme theme = Theme.of(context).pageTransitionsTheme;
    return theme.buildTransitions(this, context, animation, secondaryAnimation, child);
  }
}

class WishSimulatorHistoryPage extends StatelessWidget {
  final BannerItemType bannerType;

  const WishSimulatorHistoryPage({super.key, required this.bannerType});

  static Future<void> transparentRoute(BuildContext context, BannerItemType bannerType) async {
    final route = _CustomRoute(
      builder: (context) => WishSimulatorHistoryPage(bannerType: bannerType),
    );

    await Navigator.push(context, route);
    await route.completed;
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider<WishSimulatorPullHistoryBloc>(
      create: (context) => Injection.wishSimulatorPullHistoryBloc..add(WishSimulatorPullHistoryEvent.init(bannerType: bannerType)),
      child: BlocBuilder<WishSimulatorPullHistoryBloc, WishSimulatorPullHistoryState>(
        builder: (context, state) => Scaffold(
          appBar: _CustomAppBar(
            bannerType: state.map(loading: (_) => bannerType, loaded: (state) => state.bannerType),
            showDeleteIcon: state.map(loading: (_) => false, loaded: (state) => state.items.isNotEmpty),
          ),
          backgroundColor: Theme.of(context).colorScheme.surface.withOpacity(0.8),
          body: SafeArea(
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 6.0, sigmaY: 6.0),
              child: Center(
                child: state.map(
                  loading: (_) => const Loading(useScaffold: false),
                  loaded: (state) => state.items.isEmpty
                      ? const NothingFoundColumn()
                      : SingleChildScrollView(
                          child: _Table(items: state.items),
                        ),
                ),
              ),
            ),
          ),
          bottomNavigationBar: state.maybeMap(
            loaded: (state) => state.items.isEmpty
                ? null
                : Container(
                    margin: Styles.edgeInsetAll15,
                    child: _TablePagination(
                      maxPage: state.maxPage,
                      currentPage: state.currentPage,
                    ),
                  ),
            orElse: () => null,
          ),
        ),
      ),
    );
  }
}

class _CustomAppBar extends StatefulWidget implements PreferredSizeWidget {
  final BannerItemType bannerType;
  final bool showDeleteIcon;

  const _CustomAppBar({
    required this.bannerType,
    required this.showDeleteIcon,
  });

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  @override
  _CustomAppBarState createState() => _CustomAppBarState();
}

class _CustomAppBarState extends State<_CustomAppBar> {
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final s = S.of(context);
    return AppBar(
      centerTitle: false,
      title: Text(
        '${s.wishHistory} (${s.translateBannerItemType(widget.bannerType)})',
        overflow: TextOverflow.ellipsis,
        style: theme.textTheme.titleLarge,
      ),
      actions: [
        ItemPopupMenuFilter<BannerItemType>(
          tooltipText: s.bannerType,
          selectedValue: widget.bannerType,
          values: BannerItemType.values,
          onSelected: (val) => context.read<WishSimulatorPullHistoryBloc>().add(WishSimulatorPullHistoryEvent.init(bannerType: val)),
          icon: const Icon(Icons.filter_alt),
          splashRadius: Styles.smallButtonSplashRadius,
          itemText: (val, _) => s.translateBannerItemType(val),
        ),
        if (widget.showDeleteIcon)
          IconButton(
            icon: const Icon(Icons.clear_all),
            splashRadius: Styles.smallButtonSplashRadius,
            tooltip: s.deleteAllItems,
            onPressed: () => showDialog<bool>(
              context: context,
              builder: (context) => ConfirmDialog(
                content: s.confirmQuestion,
                title: s.deleteAllItems,
              ),
            ).then((confirmed) {
              if (confirmed == true && context.mounted) {
                context.read<WishSimulatorPullHistoryBloc>().add(WishSimulatorPullHistoryEvent.deleteData(bannerType: widget.bannerType));
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
    final theme = Theme.of(context);
    final s = S.of(context);
    final textStyle = theme.textTheme.bodyLarge!.copyWith(fontWeight: FontWeight.bold);
    return DataTable(
      showCheckboxColumn: false,
      columnSpacing: 0,
      columns: <DataColumn>[
        DataColumn(
          tooltip: s.wishHistoryItemType,
          label: Expanded(
            child: Text(
              s.wishHistoryItemType,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.center,
              style: textStyle,
              maxLines: 2,
            ),
          ),
        ),
        DataColumn(
          tooltip: s.wishHistoryItemName,
          label: Expanded(
            child: Text(
              s.wishHistoryItemName,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.center,
              style: textStyle,
              maxLines: 2,
            ),
          ),
        ),
        DataColumn(
          tooltip: s.wishHistoryTimeReceived,
          label: Expanded(
            child: Text(
              s.wishHistoryTimeReceived,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.center,
              style: textStyle,
              maxLines: 2,
            ),
          ),
        ),
      ],
      rows: items.mapIndex((e, index) => _buildRow(index, e, context, s)).toList(),
    );
  }

  DataRow _buildRow(int index, WishSimulatorBannerItemPullHistoryModel item, BuildContext context, S s) {
    final mq = MediaQuery.of(context);
    final width = mq.size.width * 0.8 / 3;
    TextStyle? nameStyle;
    String name = item.name;
    if (item.rarity > WishBannerConstants.minObtainableRarity) {
      final color = item.rarity == WishBannerConstants.maxObtainableRarity
          ? Styles.fiveStarWishResultBackgroundColor
          : Styles.fourStarWishResultBackgroundColor;
      final defaultStyle = DefaultTextStyle.of(context).style;
      name += ' (${s.wishHistoryXStar(item.rarity)})';
      nameStyle = defaultStyle.copyWith(color: color);
    }
    final isTapEnabled = [ItemType.character, ItemType.weapon].contains(item.type);
    return DataRow(
      color: WidgetStateProperty.resolveWith<Color?>((states) {
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
          SizedBox(
            width: width,
            child: Center(
              child: Tooltip(
                message: s.translateItemType(item.type),
                child: Text(
                  s.translateItemType(item.type),
                  overflow: TextOverflow.ellipsis,
                  textAlign: TextAlign.center,
                  maxLines: 2,
                ),
              ),
            ),
          ),
        ),
        DataCell(
          SizedBox(
            width: width,
            child: Center(
              child: Tooltip(
                message: name,
                child: Text(
                  name,
                  style: nameStyle,
                  overflow: TextOverflow.ellipsis,
                  textAlign: TextAlign.center,
                  maxLines: 2,
                ),
              ),
            ),
          ),
        ),
        DataCell(
          SizedBox(
            width: width,
            child: Center(
              child: Tooltip(
                message: item.pulledOn,
                child: Text(
                  item.pulledOn,
                  overflow: TextOverflow.ellipsis,
                  textAlign: TextAlign.center,
                  maxLines: 2,
                ),
              ),
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
    final s = S.of(context);
    const double iconSize = 40;
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      mainAxisSize: MainAxisSize.min,
      children: [
        IconButton(
          icon: const Icon(Icons.chevron_left),
          splashRadius: Styles.smallButtonSplashRadius,
          iconSize: iconSize,
          tooltip: s.previousPage,
          onPressed: currentPage - 1 <= 0
              ? null
              : () => context.read<WishSimulatorPullHistoryBloc>().add(WishSimulatorPullHistoryEvent.pageChanged(page: currentPage - 1)),
        ),
        Text(
          '$currentPage',
          overflow: TextOverflow.ellipsis,
        ),
        IconButton(
          icon: const Icon(Icons.chevron_right),
          splashRadius: Styles.smallButtonSplashRadius,
          iconSize: iconSize,
          tooltip: s.nextPage,
          onPressed: currentPage + 1 > maxPage
              ? null
              : () => context.read<WishSimulatorPullHistoryBloc>().add(WishSimulatorPullHistoryEvent.pageChanged(page: currentPage + 1)),
        ),
      ],
    );
  }
}
