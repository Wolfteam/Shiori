import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
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

class WishSimulatorPage extends StatefulWidget {
  @override
  State<WishSimulatorPage> createState() => _WishSimulatorPageState();
}

class _WishSimulatorPageState extends State<WishSimulatorPage> {
  final centerPageController = PageController();

  @override
  Widget build(BuildContext context) {
    const double topIconSize = 50;
    const double topHeight = 120;
    const double wishIconHeight = 55;
    final double remainingHeight = MediaQuery.of(context).size.height - topHeight - (2 * wishIconHeight);
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
              builder: (context, state) => Column(
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
                          Flexible(
                            flex: 10,
                            child: Container(
                              margin: const EdgeInsets.only(bottom: 10),
                              child: IconButton(
                                onPressed: () => Navigator.pop(context),
                                icon: const Icon(Icons.chevron_left),
                                iconSize: topIconSize,
                                color: Colors.black,
                                splashRadius: Styles.mediumBigButtonSplashRadius,
                              ),
                            ),
                          ),
                          Expanded(
                            flex: 80,
                            child: Container(
                              height: topHeight,
                              alignment: Alignment.center,
                              child: state.map(
                                loading: (_) => const SizedBox.expand(),
                                loaded: (state) => _CenterTopPageView(
                                  selectedBannerIndex: state.selectedBannerIndex,
                                  period: state.period,
                                ),
                              ),
                            ),
                          ),
                          Flexible(
                            flex: 10,
                            child: state.maybeMap(loaded: (_) => true, orElse: () => false)
                                ? Container(
                                    margin: const EdgeInsets.only(bottom: 10),
                                    child: IconButton(
                                      onPressed: () => _showBannerListSelector(context),
                                      icon: const Icon(Icons.settings),
                                      iconSize: topIconSize,
                                      color: Colors.black,
                                      splashRadius: Styles.mediumBigButtonSplashRadius,
                                    ),
                                  )
                                : const SizedBox.shrink(),
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
                      loaded: (state) => Container(
                        margin: Styles.edgeInsetAll10,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            const Spacer(),
                            WishButton(
                              imagePath: state.wishIconImage,
                              quantity: 1,
                              height: wishIconHeight,
                              onTap: (qty) => _wish(context, state.selectedBannerIndex, qty, state.period),
                            ),
                            WishButton(
                              imagePath: state.wishIconImage,
                              quantity: 10,
                              height: wishIconHeight,
                              onTap: (qty) => _wish(context, state.selectedBannerIndex, qty, state.period),
                            ),
                          ],
                        ),
                      ),
                    ),
                  )
                ],
              ),
            ),
          ),
        ),
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

  Future<void> _wish(BuildContext context, int index, int qty, WishBannerItemsPerPeriodModel period) {
    return Navigator.push(
      context,
      MaterialPageRoute(
        fullscreenDialog: true,
        builder: (_) => WishResultPage(index: index, qty: qty, period: period),
      ),
    );
  }
}

class _CenterTopPageView extends StatelessWidget {
  final int selectedBannerIndex;
  final WishBannerItemsPerPeriodModel period;

  const _CenterTopPageView({
    required this.selectedBannerIndex,
    required this.period,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      physics: const BouncingScrollPhysics(),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: period.banners.mapIndex(
          (e, index) {
            final selected = selectedBannerIndex == index;
            return BannerTopImage(
              index: index,
              imagesPath: e.featuredImages,
              width: 200,
              height: selected ? 70 : 60,
              selected: selected,
              type: e.type,
              onTap: (index) => context.read<WishSimulatorBloc>().add(WishSimulatorEvent.bannerSelected(index: index)),
            );
          },
        ).toList(),
      ),
    );
  }
}

class _CenterPageView extends StatelessWidget {
  final List<WishBannerItemModel> banners;
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
            break;
          case BannerItemType.weapon:
            topTitle = s.weaponEventWish;
            color = Colors.orange;
            break;
          case BannerItemType.standard:
            topTitle = s.standardEventWish;
            color = Colors.deepPurple;
            break;
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
