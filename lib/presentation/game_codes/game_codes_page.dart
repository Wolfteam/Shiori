import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:genshindb/application/bloc.dart';
import 'package:genshindb/generated/l10n.dart';
import 'package:genshindb/presentation/shared/bullet_list.dart';
import 'package:genshindb/presentation/shared/item_description_detail.dart';
import 'package:genshindb/presentation/shared/loading.dart';
import 'package:genshindb/presentation/shared/mixins/app_fab_mixin.dart';
import 'package:genshindb/presentation/shared/nothing_found_column.dart';
import 'package:genshindb/presentation/shared/utils/toast_utils.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'package:url_launcher/url_launcher.dart';

import 'widgets/game_code_list_item.dart';

class GameCodesPage extends StatefulWidget {
  const GameCodesPage({
    Key? key,
  }) : super(key: key);

  @override
  _GameCodesPageState createState() => _GameCodesPageState();
}

class _GameCodesPageState extends State<GameCodesPage> with SingleTickerProviderStateMixin, AppFabMixin {
  late RefreshController _refreshController;

  @override
  void initState() {
    super.initState();
    _refreshController = RefreshController();
  }

  @override
  Widget build(BuildContext context) {
    final s = S.of(context);
    return Scaffold(
      appBar: AppBar(
        title: Text(s.gameCodes),
        actions: [
          IconButton(
            icon: const Icon(Icons.open_in_new),
            onPressed: () => _launchUrl('https://genshin.mihoyo.com/en/gift'),
          ),
          IconButton(
            icon: const Icon(Icons.info),
            onPressed: () => _showInfoDialog(context),
          ),
        ],
      ),
      floatingActionButton: getAppFab(),
      body: SafeArea(
        child: BlocConsumer<GameCodesBloc, GameCodesState>(
          listener: (ctx, state) {
            if (!state.isBusy) {
              _refreshController.refreshCompleted();
            }

            if (state.isInternetAvailable == false) {
              ToastUtils.showWarningToast(ToastUtils.of(context), s.noInternetConnection);
            }
          },
          builder: (ctx, state) => SmartRefresher(
            header: const MaterialClassicHeader(),
            controller: _refreshController,
            onRefresh: () {
              context.read<GameCodesBloc>().add(const GameCodesEvent.refresh());
            },
            child: state.expiredGameCodes.isEmpty && state.workingGameCodes.isEmpty
                ? state.isBusy
                    ? const Loading(useScaffold: false)
                    : NothingFoundColumn(msg: '${s.noGameCodesHaveBeenLoaded}\n${s.pullToRefreshItems}', icon: Icons.refresh)
                : CustomScrollView(
                    controller: scrollController,
                    slivers: [
                      if (state.workingGameCodes.isNotEmpty)
                        SliverToBoxAdapter(
                          child: Container(
                            margin: const EdgeInsets.only(top: 10),
                            child: ItemDescriptionDetail(
                              title: s.workingCodes,
                              textColor: Theme.of(context).accentColor,
                              body: Container(),
                            ),
                          ),
                        ),
                      SliverList(
                        delegate: SliverChildBuilderDelegate(
                          (_, index) => GameCodeListItem(item: state.workingGameCodes[index]),
                          childCount: state.workingGameCodes.length,
                        ),
                      ),
                      if (state.expiredGameCodes.isNotEmpty)
                        SliverToBoxAdapter(
                          child: ItemDescriptionDetail(
                            title: s.expiredCodes,
                            textColor: Theme.of(context).accentColor,
                            body: Container(),
                          ),
                        ),
                      SliverList(
                        delegate: SliverChildBuilderDelegate(
                          (_, index) => GameCodeListItem(item: state.expiredGameCodes[index]),
                          childCount: state.expiredGameCodes.length,
                        ),
                      ),
                    ],
                  ),
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _refreshController.dispose();
    super.dispose();
  }

  Future<void> _launchUrl(String url) async {
    if (await canLaunch(url)) {
      await launch(url);
    }
  }

  Future<void> _showInfoDialog(BuildContext context) async {
    final s = S.of(context);
    final explanations = [
      s.internetIsRequiredToRefreshItems,
      s.swipeToSeeMoreOptions,
    ];
    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(s.information),
        content: SingleChildScrollView(
          child: BulletList(items: explanations, fontSize: 14),
        ),
        actions: [
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(s.ok),
          )
        ],
      ),
    );
  }
}
