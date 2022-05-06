import 'dart:math';

import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
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

    return BlocProvider<ChartsBloc>(
      create: (context) => Injection.chartsBloc..add(const ChartsEvent.init()),
      child: Scaffold(
        appBar: AppBar(
          title: Text(s.charts),
        ),
        body: SingleChildScrollView(
          child: Padding(
            padding: Styles.edgeInsetAll5,
            child: BlocBuilder<ChartsBloc, ChartsState>(
              builder: (context, state) => state.map(
                loading: (_) => const Loading(useScaffold: false),
                initial: (state) {
                  final maxYValueForBirthdays = state.birthdays.map((e) => e.items.length).reduce(max).toDouble() + 1;
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Text(s.topCharacters, style: theme.textTheme.headline5),
                      SizedBox(
                        height: _topCardBoxHeight,
                        //TODO: SPACE BETWEEN ITEMS
                        child: ListView.builder(
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
                      ),
                      Text(s.topWeapons, style: theme.textTheme.headline5),
                      SizedBox(
                        height: _topCardBoxHeight,
                        child: ListView.builder(
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
                      ),
                      const SizedBox(height: 10),
                      Text(s.elements, style: theme.textTheme.headline5),
                      //TODO: VERSIONS WILL GROW OVER TIME AND THIS CHART MAY LOOK UGLY
                      ChartCard(
                        width: mq.size.width,
                        height: 400,
                        title: s.mostAndLeastReleased,
                        bottom: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: state.elements
                              .map(
                                (e) => ChartLegendIndicator(
                                  color: e.type.getElementColorFromContext(context),
                                  text: s.translateElementType(e.type),
                                  expandText: false,
                                  lineThrough: state.selectedElementTypes.contains(e.type),
                                  tap: () => context.read<ChartsBloc>().add(ChartsEvent.elementSelected(type: e.type)),
                                ),
                              )
                              .toList(),
                        ),
                        child: HorizontalBarChart(
                          items: state.filteredElements
                              .mapIndex(
                                (e, i) => HorizontalBarDataModel(i, e.type.getElementColor(true), e.points),
                              )
                              .toList(),
                          canValueBeRendered: ChartsBloc.isValidVersion,
                          getBottomText: (value) => (value + ChartsBloc.versionStartsOn).toStringAsFixed(1),
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
                              version: value + ChartsBloc.versionStartsOn,
                              showWeapons: false,
                            ),
                          ),
                        ),
                      ),
                      Text(s.birthdays, style: theme.textTheme.headline5),
                      ChartCard(
                        width: 300,
                        height: 400,
                        title: s.mostAndLeastRepeated,
                        child: VerticalBarChart(
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
                        ),
                      ),
                    ],
                  );
                },
              ),
            ),
          ),
        ),
      ),
    );
  }
}
