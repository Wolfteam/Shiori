import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shiori/application/bloc.dart';
import 'package:shiori/injection.dart';
import 'package:shiori/presentation/banner_history_count/widgets/content.dart';
import 'package:shiori/presentation/banner_history_count/widgets/custom_app_bar.dart';
import 'package:shiori/presentation/banner_history_count/widgets/left_item_card.dart';
import 'package:shiori/presentation/banner_history_count/widgets/version_cell_card.dart';
import 'package:shiori/presentation/banner_history_count/widgets/version_cell_text.dart';
import 'package:shiori/presentation/shared/app_fab.dart';
import 'package:shiori/presentation/shared/mixins/app_fab_mixin.dart';
import 'package:two_dimensional_scrollables/two_dimensional_scrollables.dart';

const double _firstCellWidth = 120;
const double _firstCellHeight = 75;
const double _cellWidth = 100;
const double _cellHeight = 120;

class BannerHistoryCountPage extends StatefulWidget {
  const BannerHistoryCountPage({super.key});

  @override
  State<BannerHistoryCountPage> createState() => _BannerHistoryCountPageState();
}

class _BannerHistoryCountPageState extends State<BannerHistoryCountPage> with SingleTickerProviderStateMixin, AppFabMixin {
  @override
  Widget build(BuildContext context) {
    const margin = EdgeInsets.all(4.0);
    return BlocProvider(
      create: (_) => Injection.bannerHistoryCountBloc..add(const BannerHistoryCountEvent.init()),
      child: Scaffold(
        appBar: const CustomAppBar(),
        floatingActionButton: AppFab(
          hideFabAnimController: hideFabAnimController,
          scrollController: scrollController,
        ),
        body: SafeArea(
          child: BlocBuilder<BannerHistoryCountBloc, BannerHistoryCountState>(
            builder: (context, state) => TableView.builder(
              pinnedColumnCount: 1,
              pinnedRowCount: 1,
              verticalDetails: ScrollableDetails.vertical(
                controller: scrollController,
              ),
              columnCount: state.versions.length + 1,
              rowCount: state.banners.length + 1,
              columnBuilder: (index) => TableSpan(
                extent: FixedTableSpanExtent(index == 0 ? _firstCellWidth : _cellWidth),
              ),
              rowBuilder: (index) => TableSpan(
                extent: FixedTableSpanExtent(index == 0 ? _firstCellHeight : _cellHeight),
              ),
              diagonalDragBehavior: DiagonalDragBehavior.free,
              cellBuilder: (context, vicinity) {
                final Widget child = switch (vicinity) {
                  _ when vicinity.column == 0 && vicinity.row == 0 => VersionsCellText(
                      type: state.type,
                      margin: margin,
                    ),
                  _ when vicinity.column > 0 && vicinity.row == 0 => VersionCellCard(
                      version: state.versions[vicinity.column - 1],
                      isSelected: state.selectedVersions.contains(state.versions[vicinity.column - 1]),
                      margin: margin,
                      cellWidth: _cellWidth,
                      cellHeight: 60,
                    ),
                  _ when vicinity.column == 0 && vicinity.row > 0 => LeftItemCard(
                      itemKey: state.banners[vicinity.row - 1].key,
                      type: state.banners[vicinity.row - 1].type,
                      name: state.banners[vicinity.row - 1].name,
                      image: state.banners[vicinity.row - 1].iconImage,
                      rarity: state.banners[vicinity.row - 1].rarity,
                      numberOfTimesReleased: state.banners[vicinity.row - 1].numberOfTimesReleased,
                      margin: margin,
                    ),
                  _ => ContentCard(
                      banner: state.banners[vicinity.row - 1],
                      margin: margin,
                      version: state.versions[vicinity.column - 1],
                      number: state.banners[vicinity.row - 1].versions.firstWhere((el) => el.version == state.versions[vicinity.column - 1]).number,
                    ),
                };
                return TableViewCell(child: child);
              },
            ),
          ),
        ),
      ),
    );
  }
}
