import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:linked_scroll_controller/linked_scroll_controller.dart';
import 'package:responsive_builder/responsive_builder.dart';
import 'package:shiori/application/bloc.dart';
import 'package:shiori/domain/enums/enums.dart';
import 'package:shiori/domain/extensions/string_extensions.dart';
import 'package:shiori/domain/models/models.dart';
import 'package:shiori/generated/l10n.dart';
import 'package:shiori/injection.dart';
import 'package:shiori/presentation/banner_history/widgets/content.dart';
import 'package:shiori/presentation/banner_history/widgets/fixed_header_row.dart';
import 'package:shiori/presentation/banner_history/widgets/fixed_left_column.dart';
import 'package:shiori/presentation/shared/app_fab.dart';
import 'package:shiori/presentation/shared/extensions/i18n_extensions.dart';
import 'package:shiori/presentation/shared/item_popupmenu_filter.dart';
import 'package:shiori/presentation/shared/mixins/app_fab_mixin.dart';
import 'package:shiori/presentation/shared/nothing_found_column.dart';

const double _tabletFirstCellWidth = 150;
const double _mobileFirstCellWidth = 120;
const double _firstCellHeight = 70;
const double _tabletCellWidth = 100;
const double _mobileCellWidth = 80;
const double _cellHeight = 120;

class BannerHistoryPage extends StatefulWidget {
  const BannerHistoryPage({super.key});

  @override
  State<BannerHistoryPage> createState() => _BannerHistoryPageState();
}

class _BannerHistoryPageState extends State<BannerHistoryPage> with SingleTickerProviderStateMixin, AppFabMixin {
  late final LinkedScrollControllerGroup _verticalControllers;
  late final LinkedScrollControllerGroup _horizontalControllers;
  late final ScrollController _fixedHeaderScrollController;
  late final ScrollController _fixedLeftColumnScrollController;
  late final ScrollController _fabController;

  @override
  void initState() {
    _verticalControllers = LinkedScrollControllerGroup();
    _horizontalControllers = LinkedScrollControllerGroup();

    _fixedHeaderScrollController = _horizontalControllers.addAndGet();
    _fixedLeftColumnScrollController = _verticalControllers.addAndGet();
    _fabController = _verticalControllers.addAndGet();

    //another hack here, for some reason I had to invert the fab scroll listener
    setFabScrollListener(_fabController, inverted: true);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    const margin = EdgeInsets.all(4.0);
    double firstCellWidth = _tabletFirstCellWidth;
    double cellWidth = _tabletCellWidth;
    if (getDeviceType(MediaQuery.of(context).size) == DeviceScreenType.mobile) {
      firstCellWidth = _mobileFirstCellWidth;
      cellWidth = _mobileCellWidth;
    }
    return BlocProvider(
      create: (_) => Injection.bannerHistoryBloc..add(const BannerHistoryEvent.init()),
      child: Scaffold(
        appBar: const _AppBar(),
        floatingActionButton: AppFab(
          hideFabAnimController: hideFabAnimController,
          scrollController: _fabController,
        ),
        body: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            BlocBuilder<BannerHistoryBloc, BannerHistoryState>(
              builder: (ctx, state) => FixedHeaderRow(
                type: state.type,
                versions: state.versions,
                selectedVersions: state.selectedVersions,
                margin: margin,
                firstCellWidth: firstCellWidth,
                firstCellHeight: _firstCellHeight,
                cellWidth: cellWidth,
                cellHeight: 60,
                controller: _fixedHeaderScrollController,
              ),
            ),
            Expanded(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  BlocBuilder<BannerHistoryBloc, BannerHistoryState>(
                    builder: (ctx, state) => FixedLeftColumn(
                      margin: margin,
                      cellWidth: firstCellWidth,
                      cellHeight: _cellHeight,
                      items: state.banners,
                      controller: _fabController,
                    ),
                  ),
                  Expanded(
                    child: BlocBuilder<BannerHistoryBloc, BannerHistoryState>(
                      builder: (ctx, state) => state.banners.isEmpty
                          ? const NothingFoundColumn()
                          : Container(
                              //this margin is a kinda hack xd
                              margin: const EdgeInsets.only(left: 8),
                              child: Content(
                                banners: state.banners,
                                versions: state.versions,
                                margin: margin,
                                cellWidth: cellWidth,
                                cellHeight: _cellHeight,
                                verticalController: _fixedLeftColumnScrollController,
                                horizontalControllerGroup: _horizontalControllers,
                                maxNumberOfItems: state.maxNumberOfItems,
                              ),
                            ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _fixedHeaderScrollController.dispose();
    _fixedLeftColumnScrollController.dispose();
    super.dispose();
  }
}

class _AppBar extends StatelessWidget implements PreferredSizeWidget {
  const _AppBar();

  @override
  Widget build(BuildContext context) {
    final s = S.of(context);
    return BlocBuilder<BannerHistoryBloc, BannerHistoryState>(
      builder: (ctx, state) => AppBar(
        title: Text(s.bannerHistory),
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () => showSearch<List<String>>(
              context: context,
              delegate: _AppBarSearchDelegate(
                ctx.read<BannerHistoryBloc>().getItemsForSearch(),
                [...state.selectedItemKeys],
              ),
            ).then((keys) {
              if (keys == null) {
                return;
              }
              context.read<BannerHistoryBloc>().add(BannerHistoryEvent.itemsSelected(keys: keys));
            }),
          ),
          ItemPopupMenuFilter<BannerHistoryItemType>(
            tooltipText: s.bannerType,
            selectedValue: state.type,
            values: BannerHistoryItemType.values,
            onSelected: (val) => context.read<BannerHistoryBloc>().add(BannerHistoryEvent.typeChanged(type: val)),
            icon: const Icon(Icons.swap_horiz),
            itemText: (val, _) => s.translateBannerHistoryItemType(val),
          ),
          ItemPopupMenuFilter<BannerHistorySortType>(
            tooltipText: s.sortType,
            selectedValue: state.sortType,
            values: BannerHistorySortType.values,
            onSelected: (val) => context.read<BannerHistoryBloc>().add(BannerHistoryEvent.sortTypeChanged(type: val)),
            icon: const Icon(Icons.sort),
            itemText: (val, _) => s.translateBannerHistorySortType(val),
          ),
        ],
      ),
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}

class _AppBarSearchDelegate extends SearchDelegate<List<String>> {
  final List<ItemCommonWithName> items;
  final List<String> selected;

  _AppBarSearchDelegate(this.items, this.selected);

  @override
  List<Widget> buildActions(BuildContext context) => [
        IconButton(
          icon: const Icon(Icons.check, color: Colors.green),
          onPressed: () => close(context, selected),
        ),
        IconButton(
          icon: const Icon(Icons.clear, color: Colors.red),
          onPressed: () {
            if (query.isNullEmptyOrWhitespace) {
              close(context, []);
            } else {
              query = '';
            }
          },
        )
      ];

  @override
  Widget buildLeading(BuildContext context) => IconButton(
        icon: const Icon(Icons.arrow_back),
        onPressed: () => close(context, selected),
      );

  @override
  Widget buildResults(BuildContext context) => Text(query);

  @override
  Widget buildSuggestions(BuildContext context) {
    final possibilities = query.isNullEmptyOrWhitespace ? items : items.where((el) => el.name.toLowerCase().contains(query.toLowerCase())).toList();
    possibilities.sort((x, y) => x.name.compareTo(y.name));

    return StatefulBuilder(
      builder: (BuildContext context, StateSetter setState) => ListView.builder(
        itemCount: possibilities.length,
        itemBuilder: (ctx, index) {
          final item = possibilities[index];
          final isSelected = selected.any((el) => el == item.key);
          return ListTile(
            title: Text(item.name),
            leading: isSelected ? const Icon(Icons.check) : null,
            minLeadingWidth: 10,
            onTap: () {
              if (isSelected) {
                setState(() => selected.remove(item.key));
              } else {
                setState(() => selected.add(item.key));
              }
            },
          );
        },
      ),
    );
  }
}
