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
import 'package:shiori/presentation/charts/widgets/birthdays_per_month_dialog.dart';
import 'package:shiori/presentation/charts/widgets/chart_card.dart';
import 'package:shiori/presentation/charts/widgets/chart_legend.dart';
import 'package:shiori/presentation/charts/widgets/horizontal_bar_chart.dart';
import 'package:shiori/presentation/charts/widgets/pie_chart.dart';
import 'package:shiori/presentation/charts/widgets/vertical_bar_chart.dart';
import 'package:shiori/presentation/shared/extensions/element_type_extensions.dart';
import 'package:shiori/presentation/shared/extensions/i18n_extensions.dart';
import 'package:shiori/presentation/shared/loading.dart';
import 'package:shiori/presentation/shared/styles.dart';
import 'package:shiori/presentation/weapon/weapon_page.dart';

const double _topCardWidth = 350;
const double _topCardHeight = 300;
const double _topCardBoxHeight = _topCardHeight + 20;

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

class ChartsPage extends StatelessWidget {
  const ChartsPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final mq = MediaQuery.of(context);
    final s = S.of(context);
    final tooltipColor = Colors.black.withOpacity(0.7);
    final monthNames = date_utils.DateUtils.getAllMonthsName();
    final maxNumberOfColumns = getValueForScreenType<int>(context: context, mobile: 5, tablet: 10, desktop: 10);

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
      ],
      child: Scaffold(
        appBar: AppBar(
          title: Text(s.charts),
        ),
        body: SingleChildScrollView(
          child: Padding(
            padding: Styles.edgeInsetAll5,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(s.topCharacters, style: theme.textTheme.headline5),
                SizedBox(
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
                          return ChartCard(
                            height: _topCardHeight,
                            width: _topCardWidth,
                            title: s.translateChartType(type),
                            //TODO: THIS TEXT
                            bottom: Text(
                              'Number of times a character was released',
                              style: theme.textTheme.caption,
                              textAlign: TextAlign.center,
                            ),
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
                Text(s.topWeapons, style: theme.textTheme.headline5),
                SizedBox(
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
                          return ChartCard(
                            height: _topCardHeight,
                            width: _topCardWidth,
                            title: s.translateChartType(type),
                            bottom: Text(
                              'Number of times a character was released',
                              style: theme.textTheme.caption,
                              textAlign: TextAlign.center,
                            ),
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
                const SizedBox(height: 10),
                Text(s.elements, style: theme.textTheme.headline5),
                BlocBuilder<ChartElementsBloc, ChartElementsState>(
                  builder: (context, state) => state.maybeMap(
                    loaded: (state) => ChartCard(
                      width: mq.size.width,
                      height: 400,
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
                                    color: e.getElementColorFromContext(context),
                                    text: s.translateElementType(e),
                                    lineThrough: state.selectedElementTypes.contains(e),
                                    tap: () => context.read<ChartElementsBloc>().add(ChartElementsEvent.elementSelected(type: e)),
                                  ),
                                )
                                .toList(),
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              IconButton(
                                splashRadius: Styles.smallButtonSplashRadius,
                                tooltip: s.firstPage,
                                icon: const Icon(Icons.first_page),
                                onPressed: !state.canGoToFirstPage
                                    ? null
                                    : () => context.read<ChartElementsBloc>().add(const ChartElementsEvent.goToFirstPage()),
                              ),
                              IconButton(
                                splashRadius: Styles.smallButtonSplashRadius,
                                tooltip: s.previousPage,
                                icon: const Icon(Icons.chevron_left),
                                onPressed: !state.canGoToPreviousPage
                                    ? null
                                    : () => context.read<ChartElementsBloc>().add(const ChartElementsEvent.goToPreviousPage()),
                              ),
                              IconButton(
                                splashRadius: Styles.smallButtonSplashRadius,
                                tooltip: s.nextPage,
                                icon: const Icon(Icons.chevron_right),
                                onPressed: !state.canGoToNextPage
                                    ? null
                                    : () => context.read<ChartElementsBloc>().add(const ChartElementsEvent.goToNextPage()),
                              ),
                              IconButton(
                                splashRadius: Styles.smallButtonSplashRadius,
                                tooltip: s.lastPage,
                                icon: const Icon(Icons.last_page),
                                onPressed: !state.canGoToLastPage
                                    ? null
                                    : () => context.read<ChartElementsBloc>().add(const ChartElementsEvent.goToLastPage()),
                              ),
                            ],
                          ),
                        ],
                      ),
                      child: HorizontalBarChart(
                        minX: state.firstVersion,
                        items: state.filteredElements.mapIndex((e, i) => HorizontalBarDataModel(i, e.type.getElementColor(true), e.points)).toList(),
                        canValueBeRendered: (value) => context.read<ChartElementsBloc>().isValidVersion(value),
                        getBottomText: (value) => value.toStringAsFixed(1),
                        getLeftText: (value) => value.toInt().toString(),
                        toolTipBgColor: tooltipColor,
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
                Text(s.birthdays, style: theme.textTheme.headline5),
                ChartCard(
                  width: 300,
                  height: 400,
                  title: s.mostAndLeastRepeated,
                  child: BlocBuilder<ChartBirthdaysBloc, ChartBirthdaysState>(
                    builder: (context, state) => state.maybeMap(
                      initial: (state) {
                        final maxYValueForBirthdays = state.birthdays.map((e) => e.items.length).reduce(max).toDouble() + 1;
                        return VerticalBarChart(
                          items: state.birthdays
                              .mapIndex((e, i) => VerticalBarDataModel(i, theme.colorScheme.primary, e.month, e.items.length.toDouble()))
                              .toList(),
                          maxY: maxYValueForBirthdays,
                          interval: (maxYValueForBirthdays ~/ 5).toDouble(),
                          tooltipColor: tooltipColor,
                          getBottomText: (value) => monthNames[value.toInt() - 1],
                          getLeftText: (value) => value.toInt().toString(),
                          onBarChartTap: (index) => showDialog(
                            context: context,
                            builder: (_) => BirthdaysPerMonthDialog(month: index + 1),
                          ),
                        );
                      },
                      orElse: () => const Loading(useScaffold: false),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
