import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:shiori/application/bloc.dart';
import 'package:shiori/domain/enums/enums.dart';
import 'package:shiori/domain/extensions/iterable_extensions.dart';
import 'package:shiori/generated/l10n.dart';
import 'package:shiori/injection.dart';
import 'package:shiori/presentation/character/character_page.dart';
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

    final now = DateTime.now();
    final formatter = DateFormat('MMM');
    final List<String> months = List.generate(DateTime.monthsPerYear, (int index) {
      final date = DateTime(now.year, index + 1);
      return formatter.format(date);
    });

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
                          // crossAxisAlignment: WrapCrossAlignment.center,
                          // alignment: WrapAlignment.center,
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
                        child: HorizontalBarChart(items: state.filteredElements),
                      ),
                      Text(s.birthdays, style: theme.textTheme.headline5),
                      ChartCard(
                        width: 300,
                        height: 400,
                        title: s.mostAndLeastRepeated,
                        child: VerticalBarChart(items: state.birthdays, months: months),
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
