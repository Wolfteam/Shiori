import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'package:shiori/application/bloc.dart';
import 'package:shiori/domain/models/models.dart';
import 'package:shiori/generated/l10n.dart';
import 'package:shiori/injection.dart';
import 'package:shiori/presentation/game_codes/widgets/game_code_list_item.dart';
import 'package:shiori/presentation/shared/details/detail_section.dart';
import 'package:shiori/presentation/shared/dialogs/info_dialog.dart';
import 'package:shiori/presentation/shared/loading.dart';
import 'package:shiori/presentation/shared/mixins/app_fab_mixin.dart';
import 'package:shiori/presentation/shared/nothing_found_column.dart';
import 'package:shiori/presentation/shared/styles.dart';
import 'package:shiori/presentation/shared/utils/toast_utils.dart';
import 'package:url_launcher/url_launcher.dart';

class GameCodesPage extends StatefulWidget {
  const GameCodesPage({super.key});

  @override
  _GameCodesPageState createState() => _GameCodesPageState();
}

class _GameCodesPageState extends State<GameCodesPage> with SingleTickerProviderStateMixin, AppFabMixin {
  @override
  Widget build(BuildContext context) {
    final s = S.of(context);
    return BlocProvider<GameCodesBloc>(
      create: (ctx) => Injection.gameCodesBloc..add(const GameCodesEvent.init()),
      child: Scaffold(
        appBar: AppBar(
          title: Text(s.gameCodes),
          actions: [
            IconButton(
              icon: const Icon(Icons.open_in_new),
              splashRadius: Styles.mediumButtonSplashRadius,
              onPressed: () => _launchUrl('https://genshin.mihoyo.com/en/gift'),
            ),
            BlocBuilder<GameCodesBloc, GameCodesState>(
              builder: (ctx, state) => IconButton(
                icon: const Icon(Icons.refresh),
                splashRadius: Styles.mediumButtonSplashRadius,
                onPressed: state.isBusy ? null : () => ctx.read<GameCodesBloc>().add(const GameCodesEvent.refresh()),
              ),
            ),
            IconButton(
              icon: const Icon(Icons.info),
              splashRadius: Styles.mediumButtonSplashRadius,
              onPressed: () => _showInfoDialog(context),
            ),
          ],
        ),
        floatingActionButton: getAppFab(),
        body: SafeArea(
          child: BlocConsumer<GameCodesBloc, GameCodesState>(
            listener: (ctx, state) {
              if (state.isInternetAvailable == false) {
                ToastUtils.showWarningToast(ToastUtils.of(ctx), s.noInternetConnection);
              }

              if (state.unknownErrorOccurred) {
                ToastUtils.showWarningToast(ToastUtils.of(ctx), s.unknownError);
              }
            },
            builder: (ctx, state) => _Layout(
              working: state.workingGameCodes,
              expired: state.expiredGameCodes,
              isBusy: state.isBusy,
              scrollController: scrollController,
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _launchUrl(String url) async {
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    }
  }

  Future<void> _showInfoDialog(BuildContext context) async {
    final s = S.of(context);
    final explanations = [
      s.internetIsRequiredToRefreshItems,
      s.swipeToSeeMoreOptions,
    ];
    await showDialog(context: context, builder: (context) => InfoDialog(explanations: explanations));
  }
}

class _Layout extends StatelessWidget {
  final List<GameCodeModel> working;
  final List<GameCodeModel> expired;
  final bool isBusy;
  final ScrollController scrollController;

  const _Layout({
    required this.working,
    required this.expired,
    required this.isBusy,
    required this.scrollController,
  });

  @override
  Widget build(BuildContext context) {
    final isPortrait = MediaQuery.of(context).orientation == Orientation.portrait;
    if (isBusy) {
      return const Loading(useScaffold: false);
    }

    if (working.isEmpty && expired.isEmpty) {
      return const _NothingHasBeenLoaded();
    }

    return isPortrait
        ? _PortraitLayout(working: working, expired: expired, scrollController: scrollController)
        : _LandScapeLayout(working: working, expired: expired, scrollController: scrollController);
  }
}

class _NothingHasBeenLoaded extends StatefulWidget {
  const _NothingHasBeenLoaded();

  @override
  __NothingHasBeenLoadedState createState() => __NothingHasBeenLoadedState();
}

class __NothingHasBeenLoadedState extends State<_NothingHasBeenLoaded> {
  late RefreshController _refreshController;

  @override
  void initState() {
    super.initState();
    _refreshController = RefreshController();
  }

  @override
  Widget build(BuildContext context) {
    final s = S.of(context);
    return SmartRefresher(
      header: const MaterialClassicHeader(),
      controller: _refreshController,
      onRefresh: () => context.read<GameCodesBloc>().add(const GameCodesEvent.refresh()),
      child: NothingFoundColumn(
        msg: '${s.noGameCodesHaveBeenLoaded}\n${s.pullToRefreshItems}',
        icon: Icons.refresh,
      ),
    );
  }

  @override
  void dispose() {
    _refreshController.dispose();
    super.dispose();
  }
}

class _PortraitLayout extends StatefulWidget {
  final List<GameCodeModel> working;
  final List<GameCodeModel> expired;
  final ScrollController scrollController;

  const _PortraitLayout({
    required this.working,
    required this.expired,
    required this.scrollController,
  });

  @override
  __PortraitLayoutState createState() => __PortraitLayoutState();
}

class __PortraitLayoutState extends State<_PortraitLayout> {
  late RefreshController _refreshController;

  @override
  void initState() {
    super.initState();
    _refreshController = RefreshController();
  }

  @override
  Widget build(BuildContext context) {
    final s = S.of(context);
    final theme = Theme.of(context);
    return BlocListener<GameCodesBloc, GameCodesState>(
      listener: (ctx, state) {
        if (!state.isBusy) {
          _refreshController.refreshCompleted();
        }
      },
      child: SmartRefresher(
        header: const MaterialClassicHeader(),
        controller: _refreshController,
        onRefresh: () => context.read<GameCodesBloc>().add(const GameCodesEvent.refresh()),
        child: CustomScrollView(
          controller: widget.scrollController,
          slivers: [
            if (widget.working.isNotEmpty)
              SliverToBoxAdapter(
                child: DetailSection(
                  title: s.workingCodes,
                  color: theme.colorScheme.secondary,
                  margin: Styles.edgeInsetHorizontal16,
                ),
              ),
            SliverList.builder(
              itemBuilder: (_, index) => GameCodeListItem(item: widget.working[index]),
              itemCount: widget.working.length,
            ),
            if (widget.expired.isNotEmpty)
              SliverToBoxAdapter(
                child: DetailSection(
                  title: s.expiredCodes,
                  color: theme.colorScheme.secondary,
                  margin: Styles.edgeInsetHorizontal16,
                ),
              ),
            SliverList.builder(
              itemBuilder: (_, index) => GameCodeListItem(item: widget.expired[index]),
              itemCount: widget.expired.length,
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _refreshController.dispose();
    super.dispose();
  }
}

class _LandScapeLayout extends StatefulWidget {
  final List<GameCodeModel> working;
  final List<GameCodeModel> expired;
  final ScrollController scrollController;

  const _LandScapeLayout({
    required this.working,
    required this.expired,
    required this.scrollController,
  });

  @override
  __LandScapeLayoutState createState() => __LandScapeLayoutState();
}

class __LandScapeLayoutState extends State<_LandScapeLayout> {
  late RefreshController _leftRefreshController;
  late RefreshController _rightRefreshController;

  @override
  void initState() {
    super.initState();
    _leftRefreshController = RefreshController();
    _rightRefreshController = RefreshController();
  }

  @override
  Widget build(BuildContext context) {
    final s = S.of(context);
    final theme = Theme.of(context);
    return BlocListener<GameCodesBloc, GameCodesState>(
      listener: (ctx, state) {
        if (!state.isBusy) {
          _leftRefreshController.refreshCompleted();
          _rightRefreshController.refreshCompleted();
        }
      },
      child: Row(
        children: [
          Expanded(
            child: SmartRefresher(
              header: const MaterialClassicHeader(),
              controller: _leftRefreshController,
              onRefresh: () => context.read<GameCodesBloc>().add(const GameCodesEvent.refresh()),
              child: CustomScrollView(
                slivers: [
                  SliverToBoxAdapter(
                    child: DetailSection(
                      title: s.workingCodes,
                      color: theme.colorScheme.secondary,
                      margin: Styles.edgeInsetHorizontal16,
                    ),
                  ),
                  SliverList.builder(
                    itemBuilder: (_, index) => GameCodeListItem(item: widget.working[index]),
                    itemCount: widget.working.length,
                  ),
                ],
              ),
            ),
          ),
          Expanded(
            child: SmartRefresher(
              header: const MaterialClassicHeader(),
              controller: _rightRefreshController,
              onRefresh: () => context.read<GameCodesBloc>().add(const GameCodesEvent.refresh()),
              child: CustomScrollView(
                controller: widget.scrollController,
                slivers: [
                  SliverToBoxAdapter(
                    child: DetailSection(
                      title: s.expiredCodes,
                      color: theme.colorScheme.secondary,
                      margin: Styles.edgeInsetHorizontal16,
                    ),
                  ),
                  SliverList.builder(
                    itemBuilder: (_, index) => GameCodeListItem(item: widget.expired[index]),
                    itemCount: widget.expired.length,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _leftRefreshController.dispose();
    _rightRefreshController.dispose();
    super.dispose();
  }
}
