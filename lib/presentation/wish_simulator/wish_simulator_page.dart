import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:responsive_builder/responsive_builder.dart';
import 'package:shiori/application/bloc.dart';
import 'package:shiori/domain/assets.dart';
import 'package:shiori/domain/enums/enums.dart';
import 'package:shiori/domain/extensions/iterable_extensions.dart';
import 'package:shiori/domain/models/models.dart';
import 'package:shiori/generated/l10n.dart';
import 'package:shiori/injection.dart';
import 'package:shiori/presentation/shared/extensions/element_type_extensions.dart';
import 'package:shiori/presentation/shared/loading.dart';
import 'package:shiori/presentation/shared/styles.dart';
import 'package:shiori/presentation/wish_banner_history/banner_history_page.dart';
import 'package:shiori/presentation/wish_simulator/widgets/banner_main_image.dart';
import 'package:shiori/presentation/wish_simulator/widgets/banner_top_image.dart';
import 'package:shiori/presentation/wish_simulator/widgets/wish_button.dart';
import 'package:shiori/presentation/wish_simulator/wish_result_page.dart';
import 'package:shiori/presentation/wish_simulator/wish_simulator_history_dialog.dart';

const double _topIconSize = 40;
const double _topHeight = 100;
const double _wishIconHeight = 45;

class WishSimulatorPage extends StatefulWidget {
  @override
  State<WishSimulatorPage> createState() => _WishSimulatorPageState();
}

class _WishSimulatorPageState extends State<WishSimulatorPage> {
  final centerPageController = PageController();

  @override
  Widget build(BuildContext context) {
    final mq = MediaQuery.of(context);
    final double remainingHeight = mq.size.height - _topHeight - (2 * _wishIconHeight);
    double bannerMaxHeight = remainingHeight * 0.9;
    if (bannerMaxHeight > 700) {
      bannerMaxHeight = 700;
    }
    return BlocProvider<WishSimulatorBloc>(
      create: (context) => Injection.wishSimulatorBloc..add(const WishSimulatorEvent.init()),
      child: Scaffold(
        body: SafeArea(
          child: Ink(
            decoration: BoxDecoration(
              image: DecorationImage(
                image: AssetImage(Assets.wishBannerBackgroundImgPath),
                fit: BoxFit.fill,
              ),
            ),
            child: BlocConsumer<WishSimulatorBloc, WishSimulatorState>(
              listener: (context, state) {
                if (centerPageController.hasClients) {
                  state.maybeMap(
                    loaded: (state) => centerPageController.jumpToPage(
                      state.selectedBannerIndex,
                      // duration: const Duration(milliseconds: 300),
                      // curve: Curves.easeInOut,
                    ),
                    orElse: () {},
                  );
                }
              },
              builder: (context, state) => ResponsiveBuilder(
                builder: (context, sizingInformation) =>
                    (sizingInformation.isMobile || sizingInformation.isTablet) && mq.orientation == Orientation.landscape
                        ? _MobileLandscapeLayout(bannerMaxHeight: bannerMaxHeight, state: state, centerPageController: centerPageController)
                        : _DesktopLayout(bannerMaxHeight: bannerMaxHeight, state: state, centerPageController: centerPageController),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _MobileLandscapeLayout extends StatelessWidget {
  final double bannerMaxHeight;
  final WishSimulatorState state;
  final PageController centerPageController;

  const _MobileLandscapeLayout({
    required this.bannerMaxHeight,
    required this.state,
    required this.centerPageController,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        Stack(
          alignment: Alignment.center,
          children: [
            Container(
              color: Styles.wishTopUnselectedBackgroundColor.withOpacity(0.7),
              width: 70,
              margin: Styles.edgeInsetHorizontal5,
            ),
            Column(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                const Flexible(
                  flex: 12,
                  child: _BackButton(margin: EdgeInsets.zero),
                ),
                Expanded(
                  flex: 76,
                  child: state.map(
                    loading: (_) => const SizedBox.shrink(),
                    loaded: (state) => _FeaturedItemImages(
                      selectedBannerIndex: state.selectedBannerIndex,
                      period: state.period,
                      width: 130,
                      normalHeight: 60,
                      selectedHeight: 70,
                      axis: Axis.vertical,
                    ),
                  ),
                ),
                Flexible(
                  flex: 12,
                  child: _SettingsButton(
                    show: state.maybeMap(loaded: (_) => true, orElse: () => false),
                    margin: EdgeInsets.zero,
                  ),
                ),
              ],
            ),
          ],
        ),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Container(
                  margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                  constraints: BoxConstraints(
                    maxHeight: bannerMaxHeight,
                  ),
                  child: state.map(
                    loading: (_) => const Loading(useScaffold: false),
                    loaded: (state) => _CenterPageView(
                      banners: state.period.banners,
                      controller: centerPageController,
                    ),
                  ),
                ),
              ),
              state.map(
                loading: (_) => const SizedBox.shrink(),
                loaded: (state) => _BottomButtons(
                  iconImage: state.wishIconImage,
                  height: _wishIconHeight,
                  selectedBannerIndex: state.selectedBannerIndex,
                  period: state.period,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _DesktopLayout extends StatelessWidget {
  final double bannerMaxHeight;
  final WishSimulatorState state;
  final PageController centerPageController;

  const _DesktopLayout({
    required this.bannerMaxHeight,
    required this.state,
    required this.centerPageController,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Flexible(
          child: Container(
            margin: Styles.edgeInsetHorizontal10,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                const Flexible(
                  flex: 12,
                  child: _BackButton(margin: EdgeInsets.only(bottom: 10)),
                ),
                Expanded(
                  flex: 76,
                  child: Container(
                    height: _topHeight,
                    alignment: Alignment.center,
                    child: state.map(
                      loading: (_) => const SizedBox.expand(),
                      loaded: (state) => _FeaturedItemImages(
                        selectedBannerIndex: state.selectedBannerIndex,
                        period: state.period,
                        width: 200,
                        normalHeight: 60,
                        selectedHeight: 70,
                      ),
                    ),
                  ),
                ),
                Flexible(
                  flex: 12,
                  child: _SettingsButton(
                    show: state.maybeMap(loaded: (_) => true, orElse: () => false),
                    margin: const EdgeInsets.only(bottom: 10),
                  ),
                ),
              ],
            ),
          ),
        ),
        Container(
          constraints: BoxConstraints(
            maxHeight: bannerMaxHeight,
          ),
          child: FractionallySizedBox(
            widthFactor: 0.9,
            child: state.map(
              loading: (_) => const Loading(useScaffold: false),
              loaded: (state) => _CenterPageView(
                banners: state.period.banners,
                controller: centerPageController,
              ),
            ),
          ),
        ),
        Flexible(
          child: state.map(
            loading: (_) => const SizedBox.shrink(),
            loaded: (state) => _BottomButtons(
              iconImage: state.wishIconImage,
              height: _wishIconHeight,
              selectedBannerIndex: state.selectedBannerIndex,
              period: state.period,
            ),
          ),
        ),
      ],
    );
  }
}

class _FeaturedItemImages extends StatelessWidget {
  final int selectedBannerIndex;
  final WishSimulatorBannerItemsPerPeriodModel period;
  final double width;
  final double normalHeight;
  final double selectedHeight;
  final Axis axis;

  const _FeaturedItemImages({
    required this.selectedBannerIndex,
    required this.period,
    required this.width,
    required this.normalHeight,
    required this.selectedHeight,
    this.axis = Axis.horizontal,
  });

  @override
  Widget build(BuildContext context) {
    final children = period.banners.mapIndex(
      (e, index) {
        final selected = selectedBannerIndex == index;
        return BannerTopImage(
          index: index,
          imagesPath: e.featuredImages,
          width: width,
          height: selected ? selectedHeight : normalHeight,
          selected: selected,
          type: e.type,
          onTap: (index) => context.read<WishSimulatorBloc>().add(WishSimulatorEvent.bannerSelected(index: index)),
        );
      },
    ).toList();
    return SingleChildScrollView(
      scrollDirection: axis,
      physics: const BouncingScrollPhysics(),
      child: axis == Axis.horizontal
          ? Row(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: children,
            )
          : Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: children,
            ),
    );
  }
}

class _CenterPageView extends StatelessWidget {
  final List<WishSimulatorBannerItemModel> banners;
  final PageController controller;

  const _CenterPageView({
    required this.banners,
    required this.controller,
  });

  @override
  Widget build(BuildContext context) {
    final s = S.of(context);
    return PageView.builder(
      itemCount: banners.length,
      controller: controller,
      onPageChanged: (index) => context.read<WishSimulatorBloc>().add(WishSimulatorEvent.bannerSelected(index: index)),
      itemBuilder: (context, index) {
        final banner = banners[index];
        String topTitle;
        Color color;
        switch (banner.type) {
          case BannerItemType.character:
            final elementType = banner.characters.firstWhere((c) => c.key == banner.featuredItems.first.key).elementType;
            topTitle = s.characterEventWish;
            color = elementType.getElementColor(true);
          case BannerItemType.weapon:
            topTitle = s.weaponEventWish;
            color = Colors.orange;
          case BannerItemType.standard:
            topTitle = s.standardEventWish;
            color = Colors.deepPurple;
        }
        return BannerMainImage(
          topTitle: topTitle,
          topTitleColor: color,
          imagePath: banner.image,
          type: banner.type,
        );
      },
    );
  }
}

class _BottomButtons extends StatelessWidget {
  final String iconImage;
  final double height;
  final int selectedBannerIndex;
  final WishSimulatorBannerItemsPerPeriodModel period;

  const _BottomButtons({
    required this.iconImage,
    required this.height,
    required this.selectedBannerIndex,
    required this.period,
  });

  @override
  Widget build(BuildContext context) {
    final s = S.of(context);
    return Container(
      margin: Styles.edgeInsetAll10,
      child: LayoutBuilder(
        builder: (context, constraints) {
          final width = constraints.maxWidth / 3;
          return Wrap(
            crossAxisAlignment: WrapCrossAlignment.center,
            alignment: WrapAlignment.end,
            children: [
              WishButton(
                width: width,
                height: height,
                text: s.wishHistory,
                onTap: () => showDialog(
                  context: context,
                  builder: (context) => WishSimulatorHistoryDialog(bannerType: period.banners[selectedBannerIndex].type),
                ),
              ),
              WishQuantityButton(
                imagePath: iconImage,
                quantity: 1,
                width: width,
                height: height,
                onTap: (qty) => _wish(context, selectedBannerIndex, qty, period),
              ),
              WishQuantityButton(
                imagePath: iconImage,
                quantity: 10,
                width: width,
                height: height,
                onTap: (qty) => _wish(context, selectedBannerIndex, qty, period),
              ),
            ],
          );
        },
      ),
    );
  }

  Future<void> _wish(BuildContext context, int index, int qty, WishSimulatorBannerItemsPerPeriodModel period) {
    return Navigator.push(
      context,
      MaterialPageRoute(
        fullscreenDialog: true,
        builder: (_) => WishResultPage(index: index, qty: qty, period: period),
      ),
    );
  }
}

class _BackButton extends StatelessWidget {
  final EdgeInsets margin;

  const _BackButton({required this.margin});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: margin,
      child: IconButton(
        onPressed: () => Navigator.pop(context),
        icon: const Icon(Icons.chevron_left),
        iconSize: _topIconSize,
        color: Colors.black,
        splashRadius: Styles.mediumButtonSplashRadius,
      ),
    );
  }
}

class _SettingsButton extends StatelessWidget {
  final bool show;
  final EdgeInsets margin;

  const _SettingsButton({required this.show, required this.margin});

  @override
  Widget build(BuildContext context) {
    if (!show) {
      return const SizedBox.shrink();
    }

    return Container(
      margin: margin,
      child: IconButton(
        onPressed: () => _showBannerListSelector(context),
        icon: const Icon(Icons.settings),
        iconSize: _topIconSize,
        color: Colors.black,
        splashRadius: Styles.mediumButtonSplashRadius,
      ),
    );
  }

  Future<void> _showBannerListSelector(BuildContext context) {
    return Navigator.push<WishBannerHistoryPartItemModel>(
      context,
      MaterialPageRoute(builder: (context) => const WishBannerHistoryPage(forSelection: true)),
    ).then((value) {
      if (value == null) {
        return;
      }
      context.read<WishSimulatorBloc>().add(WishSimulatorEvent.periodChanged(version: value.version, from: value.from, until: value.until));
    });
  }
}
