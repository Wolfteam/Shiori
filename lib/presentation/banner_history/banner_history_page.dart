import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shiori/application/bloc.dart';
import 'package:shiori/generated/l10n.dart';
import 'package:shiori/injection.dart';
import 'package:shiori/presentation/banner_history/widgets/content.dart';
import 'package:shiori/presentation/banner_history/widgets/fixed_header_row.dart';
import 'package:shiori/presentation/banner_history/widgets/fixed_left_column.dart';
import 'package:shiori/presentation/shared/app_fab.dart';
import 'package:shiori/presentation/shared/mixins/app_fab_mixin.dart';
import 'package:shiori/presentation/shared/sync_controller.dart';

const double _firstCellWidth = 150;
const double _firstCellHeight = 70;
const double _cellWidth = 100;
const double _cellHeight = 120;

class BannerHistoryPage extends StatefulWidget {
  const BannerHistoryPage({Key? key}) : super(key: key);

  @override
  State<BannerHistoryPage> createState() => _BannerHistoryPageState();
}

class _BannerHistoryPageState extends State<BannerHistoryPage> with SingleTickerProviderStateMixin, AppFabMixin {
  late final ScrollController _fixedHeaderScrollController;
  late final ScrollController _fixedLeftColumnScrollController;
  late final SyncScrollController _syncScrollController;

  @override
  void initState() {
    _fixedHeaderScrollController = ScrollController();
    _fixedLeftColumnScrollController = ScrollController();
    _syncScrollController = SyncScrollController([_fixedHeaderScrollController, _fixedLeftColumnScrollController]);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final s = S.of(context);
    const margin = EdgeInsets.all(4.0);
    return BlocProvider(
      create: (_) => Injection.bannerHistoryBloc..add(const BannerHistoryEvent.init()),
      child: Scaffold(
        appBar: AppBar(title: Text(s.bannerHistory)),
        body: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            NotificationListener<ScrollNotification>(
              onNotification: (scrollInfo) {
                _syncScrollController.processNotification(scrollInfo, _fixedHeaderScrollController);
                return true;
              },
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                controller: _fixedHeaderScrollController,
                child: BlocBuilder<BannerHistoryBloc, BannerHistoryState>(
                  builder: (ctx, state) => FixedHeaderRow(
                    versions: state.versions,
                    margin: margin,
                    firstCellWidth: _firstCellWidth,
                    firstCellHeight: _firstCellHeight,
                    cellWidth: _cellWidth,
                    cellHeight: 60,
                  ),
                ),
              ),
            ),
            Flexible(
              child: SingleChildScrollView(
                controller: scrollController,
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    BlocBuilder<BannerHistoryBloc, BannerHistoryState>(
                      builder: (ctx, state) => FixedLeftColumn(
                        margin: margin,
                        cellWidth: _firstCellWidth,
                        cellHeight: _cellHeight,
                        items: state.banners,
                      ),
                    ),
                    Flexible(
                      child: NotificationListener<ScrollNotification>(
                        onNotification: (scrollInfo) {
                          _syncScrollController.processNotification(scrollInfo, _fixedLeftColumnScrollController);
                          return true;
                        },
                        child: SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          controller: _fixedLeftColumnScrollController,
                          child: BlocBuilder<BannerHistoryBloc, BannerHistoryState>(
                            builder: (ctx, state) => Content(
                              banners: state.banners,
                              versions: state.versions,
                              margin: margin,
                              cellWidth: _cellWidth,
                              cellHeight: _cellHeight,
                            ),
                          ),
                        ),
                      ),
                    )
                  ],
                ),
              ),
            ),
          ],
        ),
        floatingActionButton: AppFab(
          hideFabAnimController: hideFabAnimController,
          scrollController: scrollController,
          mini: false,
        ),
      ),
    );
  }
}
