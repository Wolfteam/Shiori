import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:genshindb/application/bloc.dart';
import 'package:genshindb/domain/models/models.dart';
import 'package:genshindb/generated/l10n.dart';
import 'package:genshindb/presentation/shared/bullet_list.dart';
import 'package:genshindb/presentation/shared/item_description_detail.dart';
import 'package:genshindb/presentation/shared/nothing_found_column.dart';
import 'package:genshindb/presentation/shared/utils/toast_utils.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'package:url_launcher/url_launcher.dart';

import 'widgets/game_code_list_item.dart';

class GameCodesPage extends StatefulWidget {
  const GameCodesPage({
    Key key,
  }) : super(key: key);

  @override
  _GameCodesPageState createState() => _GameCodesPageState();
}

class _GameCodesPageState extends State<GameCodesPage> {
  final RefreshController _refreshController = RefreshController(initialRefresh: false);

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
      body: SafeArea(
        child: SmartRefresher(
          header: const MaterialClassicHeader(),
          controller: _refreshController,
          onRefresh: () {
            context.read<GameCodesBloc>().add(const GameCodesEvent.refresh());
          },
          child: BlocConsumer<GameCodesBloc, GameCodesState>(
            listener: (ctx, state) {
              if (!state.isBusy) {
                _refreshController.refreshCompleted();
              }

              if (state.isInternetAvailable == false) {
                ToastUtils.showWarningToast(ToastUtils.of(context), s.noInternetConnection);
              }
            },
            builder: (ctx, state) => state.expiredGameCodes.isEmpty && state.workingGameCodes.isEmpty
                ? state.isBusy
                    ? const Center(child: CircularProgressIndicator())
                    : NothingFoundColumn(msg: '${s.noGameCodesHaveBeenLoaded}\n${s.pullToRefreshItems}', icon: Icons.refresh)
                : SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Container(
                          margin: const EdgeInsets.only(top: 10),
                          child: _buildTableCard(s.workingCodes, state.isBusy, state.workingGameCodes, context),
                        ),
                        _buildTableCard(s.expiredCodes, state.isBusy, state.expiredGameCodes, context),
                      ],
                    ),
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

  Widget _buildTableCard(String title, bool isBusy, List<GameCodeModel> codes, BuildContext context) {
    if (isBusy) {
      return ItemDescriptionDetail(
        title: title,
        body: const SizedBox(height: 200, child: Center(child: CircularProgressIndicator())),
        textColor: Theme.of(context).accentColor,
      );
    }
    return ItemDescriptionDetail(
      title: title,
      textColor: Theme.of(context).accentColor,
      body: codes.isEmpty
          ? Container()
          : Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: codes.map((e) => GameCodeListItem(item: e)).toList(),
            ),
    );
  }

  Future<void> _launchUrl(String url) async {
    if (await canLaunch(url)) {
      await launch(url);
    }
  }

  Future<void> _showInfoDialog(BuildContext context) async {
    final s = S.of(context);
    //TODO: SWIPE TO SEE MORE
    final explanations = [
      s.internetIsRequiredToRefreshItems,
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
