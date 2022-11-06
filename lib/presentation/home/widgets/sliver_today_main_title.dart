import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shiori/application/bloc.dart';
import 'package:shiori/generated/l10n.dart';
import 'package:shiori/presentation/home/widgets/change_current_day_dialog.dart';
import 'package:shiori/presentation/shared/loading.dart';
import 'package:shiori/presentation/shared/styles.dart';

class SliverTodayMainTitle extends StatelessWidget {
  const SliverTodayMainTitle({super.key});

  @override
  Widget build(BuildContext context) {
    final s = S.of(context);
    final theme = Theme.of(context);
    return SliverPadding(
      padding: const EdgeInsets.only(top: 10),
      sliver: SliverToBoxAdapter(
        child: BlocBuilder<HomeBloc, HomeState>(
          builder: (ctx, state) => state.map(
            loading: (_) => const Loading(useScaffold: false),
            loaded: (state) => Container(
              margin: Styles.edgeInsetHorizontal16,
              child: RichText(
                text: TextSpan(
                  text: s.todayAscensionMaterials,
                  style: theme.textTheme.headline6!.copyWith(fontWeight: FontWeight.bold),
                  children: <TextSpan>[
                    TextSpan(
                      text: ' [ ${state.dayName} ]',
                      style: theme.textTheme.caption,
                      recognizer: TapGestureRecognizer()..onTap = () => _openDayWeekDialog(state.day, context),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _openDayWeekDialog(int currentSelectedDay, BuildContext context) async {
    await showDialog<int>(
      context: context,
      builder: (_) => ChangeCurrentDayDialog(currentSelectedDay: currentSelectedDay),
    ).then((selectedDay) {
      if (selectedDay == null) {
        return;
      }

      if (selectedDay < 0) {
        context.read<HomeBloc>().add(const HomeEvent.init());
      } else {
        context.read<HomeBloc>().add(HomeEvent.dayChanged(newDay: selectedDay));
      }
    });
  }
}
