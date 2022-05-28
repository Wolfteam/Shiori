import 'dart:math';

import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:responsive_builder/responsive_builder.dart';
import 'package:shiori/application/bloc.dart';
import 'package:shiori/domain/enums/enums.dart';
import 'package:shiori/domain/extensions/iterable_extensions.dart';
import 'package:shiori/domain/utils/date_utils.dart' as date_utils;
import 'package:shiori/generated/l10n.dart';
import 'package:shiori/injection.dart';
import 'package:shiori/presentation/banner_history/widgets/version_details_dialog.dart';
import 'package:shiori/presentation/character/character_page.dart';
import 'package:shiori/presentation/charts/widgets/chart_card.dart';
import 'package:shiori/presentation/charts/widgets/chart_legend.dart';
import 'package:shiori/presentation/charts/widgets/horizontal_bar_chart.dart';
import 'package:shiori/presentation/charts/widgets/pie_chart.dart';
import 'package:shiori/presentation/charts/widgets/vertical_bar_chart.dart';
import 'package:shiori/presentation/shared/dialogs/birthdays_per_month_dialog.dart';
import 'package:shiori/presentation/shared/dialogs/characters_per_region_dialog.dart';
import 'package:shiori/presentation/shared/dialogs/characters_per_region_gender_dialog.dart';
import 'package:shiori/presentation/shared/dialogs/items_ascension_stats_dialog.dart';
import 'package:shiori/presentation/shared/extensions/element_type_extensions.dart';
import 'package:shiori/presentation/shared/extensions/i18n_extensions.dart';
import 'package:shiori/presentation/shared/loading.dart';
import 'package:shiori/presentation/shared/nothing_found_column.dart';
import 'package:shiori/presentation/shared/styles.dart';
import 'package:shiori/presentation/weapon/weapon_page.dart';

const double _topCardWidth = 350;
const double _topCardHeight = 300;
const double _topCardBoxHeight = _topCardHeight + 20;
const double _defaultChartHeight = 400;

const _topCharacterTypes = [
  ChartType.topFiveStarCharacterMostReruns,
  ChartType.topFiveStarCharacterLeastReruns,
  ChartType.topFourStarCharacterMostReruns,
  ChartType.topFourStarCharacterLeastReruns,
];

const _topWeaponTypes = [
  ChartType.topFiveStarWeaponMostReruns,
  ChartType.topFiveStarWeaponLeastReruns,
  ChartType.topFourStarWeaponMostReruns,
  ChartType.topFourStarWeaponLeastReruns,
];

const _topCharacterColors = [Colors.red, Colors.orange, Colors.yellow, Colors.green, Colors.blue];
const _topWeaponColors = [Colors.red, Colors.orange, Colors.yellow, Colors.green, Colors.blue];

final _tooltipColor = Colors.black.withOpacity(0.7);

final _monthNames = date_utils.DateUtils.getAllMonthsName();

class ChartsPage extends StatelessWidget {
  const ChartsPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final s = S.of(context);
    final maxNumberOfColumns = getValueForScreenType<int>(context: context, mobile: 5, tablet: 10, desktop: 10);
    final isPortrait = MediaQuery.of(context).orientation == Orientation.portrait;
    return MultiBlocProvider(
      providers: [
        BlocProvider<ChartTopsBloc>(
          create: (context) => Injection.chartTopsBloc..add(const ChartTopsEvent.init()),
        ),
        BlocProvider<ChartElementsBloc>(
          create: (context) => Injection.chartElementsBloc..add(ChartElementsEvent.init(maxNumberOfColumns: maxNumberOfColumns)),
        ),
        BlocProvider<ChartBirthdaysBloc>(
          create: (context) => Injection.chartBirthdaysBloc..add(const ChartBirthdaysEvent.init()),
        ),
        BlocProvider<ChartAscensionStatsBloc>(
          create: (context) => Injection.chartAscensionStatsBloc
            ..add(
              ChartAscensionStatsEvent.init(
                type: ItemType.character,
                maxNumberOfColumns: maxNumberOfColumns,
              ),
            ),
        ),
        BlocProvider<ChartRegionsBloc>(
          create: (context) => Injection.chartRegionsBloc..add(const ChartRegionsEvent.init()),
        ),
        BlocProvider<ChartGendersBloc>(
          create: (context) => Injection.chartGendersBloc..add(const ChartGendersEvent.init()),
        ),
      ],
      child: Scaffold(
        appBar: AppBar(
          title: Text(s.charts),
        ),
        body: SingleChildScrollView(
          child: Padding(
            padding: Styles.edgeInsetAll5,
            child: ResponsiveBuilder(
              builder: (context, sizingInformation) => !isPortrait &&
                      (sizingInformation.deviceScreenType == DeviceScreenType.desktop ||
                          sizingInformation.deviceScreenType == DeviceScreenType.tablet)
                  ? const _LandscapeLayout()
                  : const _PortraitLayout(),
            ),
          ),
        ),
      ),
    );
  }
}

class _PortraitLayout extends StatelessWidget {
  const _PortraitLayout({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final maxNumberOfColumns = getValueForScreenType<int>(context: context, mobile: 5, tablet: 10, desktop: 10);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const _TopCharacters(),
        const _TopWeapons(),
        const SizedBox(height: 10),
        const _Elements(),
        const _Birthdays(),
        _AscensionStats(maxNumberOfColumns: maxNumberOfColumns),
        const _Regions(),
        const _Genders(),
      ],
    );
  }
}

class _LandscapeLayout extends StatelessWidget {
  const _LandscapeLayout({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final maxNumberOfColumns = getValueForScreenType<int>(context: context, mobile: 5, tablet: 10, desktop: 10);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const _TopCharacters(),
        const _TopWeapons(),
        const SizedBox(height: 10),
        const _Elements(),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            const Expanded(flex: 49, child: _Birthdays()),
            const Spacer(flex: 2),
            Expanded(flex: 49, child: _AscensionStats(maxNumberOfColumns: maxNumberOfColumns)),
          ],
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: const [
            Expanded(flex: 49, child: _Regions()),
            Spacer(flex: 2),
            Expanded(flex: 49, child: _Genders()),
          ],
        ),
      ],
    );
  }
}

class _ChartPagination extends StatelessWidget {
  final bool canGoToFirstPage;
  final bool canGoToPreviousPage;
  final bool canGoToNextPage;
  final bool canGoToLastPage;

  final Function onFirstPagePressed;
  final Function onPreviousPagePressed;
  final Function onNextPagePressed;
  final Function onLastPagePressed;

  const _ChartPagination({
    Key? key,
    required this.canGoToFirstPage,
    required this.canGoToPreviousPage,
    required this.canGoToNextPage,
    required this.canGoToLastPage,
    required this.onFirstPagePressed,
    required this.onPreviousPagePressed,
    required this.onNextPagePressed,
    required this.onLastPagePressed,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final s = S.of(context);
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      mainAxisSize: MainAxisSize.min,
      children: [
        IconButton(
          splashRadius: Styles.smallButtonSplashRadius,
          tooltip: s.firstPage,
          icon: const Icon(Icons.first_page),
          onPressed: !canGoToFirstPage ? null : () => onFirstPagePressed.call(),
        ),
        IconButton(
          splashRadius: Styles.smallButtonSplashRadius,
          tooltip: s.previousPage,
          icon: const Icon(Icons.chevron_left),
          onPressed: !canGoToPreviousPage ? null : () => onPreviousPagePressed.call(),
        ),
        IconButton(
          splashRadius: Styles.smallButtonSplashRadius,
          tooltip: s.nextPage,
          icon: const Icon(Icons.chevron_right),
          onPressed: !canGoToNextPage ? null : () => onNextPagePressed.call(),
        ),
        IconButton(
          splashRadius: Styles.smallButtonSplashRadius,
          tooltip: s.lastPage,
          icon: const Icon(Icons.last_page),
          onPressed: !canGoToLastPage ? null : () => onLastPagePressed.call(),
        ),
      ],
    );
  }
}

class _Chart extends StatelessWidget {
  final String title;
  final Widget chart;

  const _Chart({
    Key? key,
    required this.title,
    required this.chart,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(title, style: theme.textTheme.headline5),
        chart,
      ],
    );
  }
}

class _TopCharacters extends StatelessWidget {
  const _TopCharacters({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final s = S.of(context);
    return _Chart(
      title: s.topCharacters,
      chart: SizedBox(
        height: _topCardBoxHeight,
        child: BlocBuilder<ChartTopsBloc, ChartTopsState>(
          builder: (context, state) => state.maybeMap(
            loaded: (state) => ListView.builder(
              physics: const BouncingScrollPhysics(),
              scrollDirection: Axis.horizontal,
              itemCount: _topCharacterTypes.length,
              itemBuilder: (ctx, index) {
                final type = _topCharacterTypes[index];
                final items = state.tops.where((el) => el.type == type).toList();
                if (items.isEmpty) {
                  return NothingFoundColumn(msg: s.nothingToShow);
                }
                return ChartCard(
                  height: _topCardHeight,
                  width: _topCardWidth,
                  title: s.translateChartType(type),
                  child: Row(
                    children: [
                      Flexible(flex: 70, fit: FlexFit.tight, child: TopPieChart(items: items, colors: _topCharacterColors)),
                      Flexible(
                        flex: 30,
                        fit: FlexFit.tight,
                        child: ChartLegend(
                          indicators: items
                              .mapIndex(
                                (e, i) => ChartLegendIndicator(
                                  text: e.name,
                                  color: _topCharacterColors[i],
                                  tap: () => CharacterPage.route(e.key, context),
                                ),
                              )
                              .toList(),
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
            orElse: () => const Loading(useScaffold: false),
          ),
        ),
      ),
    );
  }
}

class _TopWeapons extends StatelessWidget {
  const _TopWeapons({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final s = S.of(context);
    return _Chart(
      title: s.topWeapons,
      chart: SizedBox(
        height: _topCardBoxHeight,
        child: BlocBuilder<ChartTopsBloc, ChartTopsState>(
          builder: (context, state) => state.maybeMap(
            loaded: (state) => ListView.builder(
              physics: const BouncingScrollPhysics(),
              scrollDirection: Axis.horizontal,
              itemCount: _topWeaponTypes.length,
              itemBuilder: (ctx, index) {
                final type = _topWeaponTypes[index];
                final items = state.tops.where((el) => el.type == type).toList();
                if (items.isEmpty) {
                  return NothingFoundColumn(msg: s.nothingToShow);
                }
                return ChartCard(
                  height: _topCardHeight,
                  width: _topCardWidth,
                  title: s.translateChartType(type),
                  child: Row(
                    children: [
                      Flexible(flex: 70, fit: FlexFit.tight, child: TopPieChart(items: items, colors: _topWeaponColors)),
                      Flexible(
                        flex: 30,
                        fit: FlexFit.tight,
                        child: ChartLegend(
                          indicators: items
                              .mapIndex(
                                (e, i) => ChartLegendIndicator(
                                  text: e.name,
                                  color: _topWeaponColors[i],
                                  tap: () => WeaponPage.route(e.key, context),
                                ),
                              )
                              .toList(),
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
            orElse: () => const Loading(useScaffold: false),
          ),
        ),
      ),
    );
  }
}

class _Elements extends StatelessWidget {
  const _Elements({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final s = S.of(context);
    final mq = MediaQuery.of(context);
    return _Chart(
      title: s.elements,
      chart: BlocBuilder<ChartElementsBloc, ChartElementsState>(
        builder: (context, state) => state.maybeMap(
          loaded: (state) => ChartCard(
            width: mq.size.width,
            height: _defaultChartHeight,
            title: s.mostAndLeastReleased,
            bottom: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Wrap(
                  crossAxisAlignment: WrapCrossAlignment.center,
                  alignment: WrapAlignment.center,
                  children: ElementType.values
                      .map(
                        (e) => ChartLegendIndicator(
                          width: min(mq.size.width / state.elements.length, 100),
                          color: e.getElementColor(true),
                          text: s.translateElementType(e),
                          lineThrough: state.selectedElementTypes.contains(e),
                          tap: () => context.read<ChartElementsBloc>().add(ChartElementsEvent.elementSelected(type: e)),
                        ),
                      )
                      .toList(),
                ),
                _ChartPagination(
                  canGoToFirstPage: state.canGoToFirstPage,
                  canGoToLastPage: state.canGoToLastPage,
                  canGoToNextPage: state.canGoToNextPage,
                  canGoToPreviousPage: state.canGoToPreviousPage,
                  onFirstPagePressed: () => context.read<ChartElementsBloc>().add(const ChartElementsEvent.goToFirstPage()),
                  onLastPagePressed: () => context.read<ChartElementsBloc>().add(const ChartElementsEvent.goToLastPage()),
                  onNextPagePressed: () => context.read<ChartElementsBloc>().add(const ChartElementsEvent.goToNextPage()),
                  onPreviousPagePressed: () => context.read<ChartElementsBloc>().add(const ChartElementsEvent.goToPreviousPage()),
                ),
              ],
            ),
            child: state.filteredElements.isEmpty
                ? NothingFoundColumn(msg: s.nothingToShow)
                : HorizontalBarChart(
                    minX: state.firstVersion,
                    items: state.filteredElements.mapIndex((e, i) => HorizontalBarDataModel(i, e.type.getElementColor(true), e.points)).toList(),
                    canValueBeRendered: (value) => context.read<ChartElementsBloc>().isValidVersion(value),
                    getBottomText: (value) => value.toStringAsFixed(1),
                    getLeftText: (value) => value.toInt().toString(),
                    toolTipBgColor: _tooltipColor,
                    getTooltipItems: (touchedSpots) => touchedSpots.map(
                      (touchedSpot) {
                        final quantity = touchedSpot.y;
                        final element = state.filteredElements[touchedSpot.barIndex];
                        final textStyle = TextStyle(
                          color: touchedSpot.bar.gradient?.colors.first ?? touchedSpot.bar.color ?? theme.colorScheme.primary,
                          fontWeight: FontWeight.bold,
                          fontSize: 15,
                        );
                        final text = '${s.translateElementType(element.type)} (${quantity.toInt()})';
                        return LineTooltipItem(text, textStyle);
                      },
                    ).toList()
                      ..sort((x, y) => x.text.compareTo(y.text)),
                    onPointTap: (value) => showDialog(
                      context: context,
                      builder: (_) => VersionDetailsDialog(
                        version: value,
                        showWeapons: false,
                      ),
                    ),
                  ),
          ),
          orElse: () => const Loading(useScaffold: false),
        ),
      ),
    );
  }
}

class _Birthdays extends StatelessWidget {
  const _Birthdays({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final s = S.of(context);
    final mq = MediaQuery.of(context);
    return _Chart(
      title: s.birthdays,
      chart: ChartCard(
        width: mq.size.width,
        height: _defaultChartHeight,
        title: s.mostAndLeastRepeated,
        titleMargin: const EdgeInsets.only(bottom: 20),
        child: BlocBuilder<ChartBirthdaysBloc, ChartBirthdaysState>(
          builder: (context, state) => state.maybeMap(
            loaded: (state) {
              if (state.birthdays.isEmpty) {
                return NothingFoundColumn(msg: s.nothingToShow);
              }
              final maxYValueForBirthdays = state.birthdays.map((e) => e.items.length).reduce(max).toDouble();
              return VerticalBarChart(
                items: state.birthdays
                    .mapIndex((e, i) => VerticalBarDataModel(i, theme.colorScheme.primary, e.month, e.items.length.toDouble()))
                    .toList(),
                maxY: maxYValueForBirthdays,
                interval: (maxYValueForBirthdays ~/ 5).toDouble(),
                tooltipColor: _tooltipColor,
                getBottomText: (value) => _monthNames[value.toInt() - 1],
                getLeftText: (value) => value.toInt().toString(),
                rotateBottomText: true,
                onBarChartTap: (index, _) => showDialog(
                  context: context,
                  builder: (_) => BirthdaysPerMonthDialog(month: index + 1),
                ),
              );
            },
            orElse: () => const Loading(useScaffold: false),
          ),
        ),
      ),
    );
  }
}

class _AscensionStats extends StatelessWidget {
  final int maxNumberOfColumns;

  const _AscensionStats({
    Key? key,
    required this.maxNumberOfColumns,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final s = S.of(context);
    final mq = MediaQuery.of(context);
    return _Chart(
      title: s.ascensionStats,
      chart: BlocBuilder<ChartAscensionStatsBloc, ChartAscensionStatsState>(
        builder: (context, state) => state.maybeMap(
          loaded: (state) => ChartCard(
            width: mq.size.width,
            height: _defaultChartHeight,
            title: s.mostAndLeastRepeated,
            titleMargin: const EdgeInsets.only(bottom: 20),
            bottom: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Center(
                  child: ToggleButtons(
                    onPressed: (index) => context.read<ChartAscensionStatsBloc>().add(
                          ChartAscensionStatsEvent.init(
                            type: index == 0 ? ItemType.character : ItemType.weapon,
                            maxNumberOfColumns: maxNumberOfColumns,
                          ),
                        ),
                    borderRadius: BorderRadius.circular(10),
                    constraints: const BoxConstraints(minHeight: 25, maxHeight: 25),
                    isSelected: [
                      state.itemType == ItemType.character,
                      state.itemType == ItemType.weapon,
                    ],
                    children: [
                      Container(
                        margin: Styles.edgeInsetHorizontal16,
                        child: Text(s.characters),
                      ),
                      Container(
                        margin: Styles.edgeInsetHorizontal16,
                        child: Text(s.weapons),
                      ),
                    ],
                  ),
                ),
                _ChartPagination(
                  canGoToFirstPage: state.canGoToFirstPage,
                  canGoToLastPage: state.canGoToLastPage,
                  canGoToNextPage: state.canGoToNextPage,
                  canGoToPreviousPage: state.canGoToPreviousPage,
                  onFirstPagePressed: () => context.read<ChartAscensionStatsBloc>().add(const ChartAscensionStatsEvent.goToFirstPage()),
                  onLastPagePressed: () => context.read<ChartAscensionStatsBloc>().add(const ChartAscensionStatsEvent.goToLastPage()),
                  onNextPagePressed: () => context.read<ChartAscensionStatsBloc>().add(const ChartAscensionStatsEvent.goToNextPage()),
                  onPreviousPagePressed: () => context.read<ChartAscensionStatsBloc>().add(const ChartAscensionStatsEvent.goToPreviousPage()),
                ),
              ],
            ),
            child: state.ascensionStats.isEmpty
                ? NothingFoundColumn(msg: s.nothingToShow)
                : VerticalBarChart(
                    items: state.ascensionStats
                        .mapIndex((e, i) => VerticalBarDataModel(i, theme.colorScheme.primary, e.type.index, e.quantity.toDouble()))
                        .toList(),
                    maxY: state.maxCount.toDouble(),
                    interval: (state.maxCount * 0.2).roundToDouble(),
                    tooltipColor: _tooltipColor,
                    getBottomText: (value) => s.translateStatTypeWithoutValue(StatType.values[value.toInt()]),
                    getLeftText: (value) => value.toInt().toString(),
                    rotateBottomText: true,
                    onBarChartTap: (index, _) => showDialog(
                      context: context,
                      builder: (_) => ItemsAscensionStatsDialog(itemType: state.itemType, statType: state.ascensionStats[index].type),
                    ),
                  ),
          ),
          orElse: () => const Loading(useScaffold: false),
        ),
      ),
    );
  }
}

class _Regions extends StatelessWidget {
  const _Regions({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final s = S.of(context);
    final mq = MediaQuery.of(context);
    return _Chart(
      title: s.regions,
      chart: ChartCard(
        width: mq.size.width,
        height: _defaultChartHeight,
        title: s.mostAndLeastRepeated,
        titleMargin: const EdgeInsets.only(bottom: 20),
        child: BlocBuilder<ChartRegionsBloc, ChartRegionsState>(
          builder: (context, state) => state.maybeMap(
            loaded: (state) => state.items.isEmpty
                ? NothingFoundColumn(msg: s.nothingToShow)
                : VerticalBarChart(
                    items: state.items
                        .mapIndex((e, i) => VerticalBarDataModel(i, theme.colorScheme.primary, e.regionType.index, e.quantity.toDouble()))
                        .toList(),
                    maxY: state.maxCount.toDouble(),
                    interval: (state.maxCount * 0.2).roundToDouble(),
                    tooltipColor: _tooltipColor,
                    getBottomText: (value) => s.translateRegionType(state.items[value.toInt()].regionType),
                    getLeftText: (value) => value.toInt().toString(),
                    rotateBottomText: true,
                    onBarChartTap: (index, _) => showDialog(
                      context: context,
                      builder: (_) => CharactersPerRegionDialog(regionType: state.items[index].regionType),
                    ),
                  ),
            orElse: () => const Loading(useScaffold: false),
          ),
        ),
      ),
    );
  }
}

class _Genders extends StatelessWidget {
  const _Genders({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final s = S.of(context);
    final mq = MediaQuery.of(context);
    return _Chart(
      title: s.genders,
      chart: ChartCard(
        width: mq.size.width,
        height: _defaultChartHeight,
        title: s.perRegions,
        titleMargin: const EdgeInsets.only(bottom: 20),
        child: BlocBuilder<ChartGendersBloc, ChartGendersState>(
          builder: (context, state) => state.maybeMap(
            loaded: (state) => state.genders.isEmpty
                ? NothingFoundColumn(msg: s.nothingToShow)
                : VerticalBarChart(
                    items: state.genders.mapIndex((e, i) => VerticalBarDataModel(i, theme.colorScheme.primary, e.regionType.index, 0)).toList(),
                    maxY: state.maxCount.toDouble(),
                    interval: (state.maxCount * 0.2).roundToDouble(),
                    tooltipColor: _tooltipColor,
                    getBottomText: (value) => s.translateRegionType(state.genders[value.toInt()].regionType),
                    getLeftText: (value) => value.toInt().toString(),
                    rotateBottomText: true,
                    onBarChartTap: (indexA, indexB) => showDialog(
                      context: context,
                      builder: (_) => CharactersPerRegionGenderDialog(
                        regionType: state.genders[indexA].regionType,
                        onlyFemales: indexB.isOdd,
                      ),
                    ),
                    getBarChartRodData: (x) {
                      final item = state.genders[x];
                      return [
                        BarChartRodData(
                          toY: item.maleCount.toDouble(),
                          color: Colors.blue,
                          borderRadius: BorderRadius.zero,
                          width: 10,
                        ),
                        BarChartRodData(
                          toY: item.femaleCount.toDouble(),
                          color: Colors.red,
                          borderRadius: BorderRadius.zero,
                          width: 10,
                        ),
                      ];
                    },
                  ),
            orElse: () => const Loading(useScaffold: false),
          ),
        ),
      ),
    );
  }
}
