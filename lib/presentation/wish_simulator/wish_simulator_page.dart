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
import 'package:shiori/presentation/wish_banner_history/wish_banner_history_page.dart';
import 'package:shiori/presentation/wish_simulator/widgets/banner_main_image.dart';
import 'package:shiori/presentation/wish_simulator/widgets/banner_top_image.dart';
import 'package:shiori/presentation/wish_simulator/widgets/wish_button.dart';
import 'package:shiori/presentation/wish_simulator/wish_result_page.dart';
import 'package:shiori/presentation/wish_simulator/wish_simulator_history_page.dart';

const double _topIconSize = 40;
const double _topHeight = 100;
const double _wishIconHeight = 60;

class WishSimulatorPage extends StatelessWidget {
  const WishSimulatorPage({super.key});

  @override
  Widget build(BuildContext context) {
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
            child: _Content(),
          ),
        ),
      ),
    );
  }
}

class _Content extends StatefulWidget {
  @override
  State<_Content> createState() => _ContentState();
}

class _ContentState extends State<_Content> {
  final Key _pageViewKey = GlobalKey();
  late PageController _pageController;

  @override
  void initState() {
    _pageController = PageController();
    super.initState();
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final mq = MediaQuery.of(context);
    final double remainingHeight = mq.size.height - _topHeight - (2 * _wishIconHeight);
    double bannerMaxHeight = remainingHeight * 0.9;
    if (bannerMaxHeight > 700) {
      bannerMaxHeight = 700;
    }
    return BlocConsumer<WishSimulatorBloc, WishSimulatorState>(
      listener: (context, state) {
        if (_pageController.hasClients) {
          state.maybeMap(
            loaded: (state) => _pageController.jumpToPage(
              state.selectedBannerIndex,
              // duration: const Duration(milliseconds: 300),
              // curve: Curves.easeInOut,
            ),
            orElse: () {},
          );
        }
      },
      builder: (context, state) => ResponsiveBuilder(
        builder: (context, sizingInformation) => (sizingInformation.isMobile || sizingInformation.isTablet) && mq.orientation == Orientation.landscape
            ? _MobileLandscapeLayout(pageViewKey: _pageViewKey, bannerMaxHeight: bannerMaxHeight, state: state, pageController: _pageController)
            : _Layout(pageViewKey: _pageViewKey, bannerMaxHeight: bannerMaxHeight, state: state, pageController: _pageController),
      ),
    );
  }
}

class _MobileLandscapeLayout extends StatelessWidget {
  final Key pageViewKey;
  final double bannerMaxHeight;
  final WishSimulatorState state;
  final PageController pageController;

  const _MobileLandscapeLayout({
    required this.pageViewKey,
    required this.bannerMaxHeight,
    required this.state,
    required this.pageController,
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
            _FeaturedItems(state: state, useColumn: true),
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
                      pageViewKey: pageViewKey,
                      banners: state.period.banners,
                      controller: pageController,
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

class _Layout extends StatelessWidget {
  final Key pageViewKey;
  final double bannerMaxHeight;
  final WishSimulatorState state;
  final PageController pageController;

  const _Layout({
    required this.pageViewKey,
    required this.bannerMaxHeight,
    required this.state,
    required this.pageController,
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
            child: _FeaturedItems(state: state, useColumn: false),
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
                pageViewKey: pageViewKey,
                banners: state.period.banners,
                controller: pageController,
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

class _FeaturedItems extends StatelessWidget {
  final WishSimulatorState state;
  final bool useColumn;

  bool get showSettingsButton => state.maybeMap(loaded: (_) => true, orElse: () => false);

  const _FeaturedItems({
    required this.state,
    required this.useColumn,
  });

  @override
  Widget build(BuildContext context) {
    const int buttonFlex = 15;
    const int mainContentFlex = 70;
    const double imageHeight = 60;
    const double selectedImageHeight = 70;
    final double imageWidth = useColumn ? 130 : 200;
    final buttonMargin = useColumn ? EdgeInsets.zero : const EdgeInsets.only(bottom: 10);
    if (!useColumn) {
      return Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Flexible(
            flex: buttonFlex,
            child: _BackButton(margin: buttonMargin),
          ),
          Expanded(
            flex: mainContentFlex,
            child: Container(
              height: _topHeight,
              alignment: Alignment.center,
              child: state.map(
                loading: (_) => const SizedBox.expand(),
                loaded: (state) => _FeaturedItemImages(
                  selectedBannerIndex: state.selectedBannerIndex,
                  period: state.period,
                  width: imageWidth,
                  normalHeight: imageHeight,
                  selectedHeight: selectedImageHeight,
                ),
              ),
            ),
          ),
          Flexible(
            flex: buttonFlex,
            child: _SettingsButton(
              show: showSettingsButton,
              margin: buttonMargin,
            ),
          ),
        ],
      );
    }
    return Column(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        Flexible(
          flex: buttonFlex,
          child: _BackButton(margin: buttonMargin),
        ),
        Expanded(
          flex: mainContentFlex,
          child: state.map(
            loading: (_) => const SizedBox.shrink(),
            loaded: (state) => _FeaturedItemImages(
              selectedBannerIndex: state.selectedBannerIndex,
              period: state.period,
              width: imageWidth,
              normalHeight: imageHeight,
              selectedHeight: selectedImageHeight,
              axis: Axis.vertical,
            ),
          ),
        ),
        Flexible(
          flex: buttonFlex,
          child: _SettingsButton(
            show: showSettingsButton,
            margin: buttonMargin,
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
  final Key pageViewKey;
  final List<WishSimulatorBannerItemModel> banners;
  final PageController controller;

  const _CenterPageView({
    required this.pageViewKey,
    required this.banners,
    required this.controller,
  });

  @override
  Widget build(BuildContext context) {
    final s = S.of(context);
    return PageView.builder(
      key: pageViewKey,
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
                onTap: () => WishSimulatorHistoryPage.transparentRoute(context, period.banners[selectedBannerIndex].type),
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
      if (value == null || !context.mounted) {
        return;
      }
      context.read<WishSimulatorBloc>().add(WishSimulatorEvent.periodChanged(version: value.version, from: value.from, until: value.until));
    });
  }
}
