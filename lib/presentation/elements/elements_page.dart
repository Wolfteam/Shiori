import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shiori/application/bloc.dart';
import 'package:shiori/generated/l10n.dart';
import 'package:shiori/injection.dart';
import 'package:shiori/presentation/elements/widgets/sliver_element_debuffs.dart';
import 'package:shiori/presentation/elements/widgets/sliver_element_reactions.dart';
import 'package:shiori/presentation/elements/widgets/sliver_element_resonances.dart';
import 'package:shiori/presentation/shared/loading.dart';

class ElementsPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final s = S.of(context);
    return Scaffold(
      appBar: AppBar(title: Text(s.elements)),
      body: SafeArea(
        child: BlocProvider<ElementsBloc>(
          create: (ctx) => Injection.elementsBloc..add(const ElementsEvent.init()),
          child: BlocBuilder<ElementsBloc, ElementsState>(
            builder: (context, state) => state.map(
              loading: (_) => const Loading(useScaffold: false),
              loaded: (state) => CustomScrollView(
                slivers: [
                  SliverElementDebuffs(debuffs: state.debuffs),
                  SliverElementReactions(reactions: state.reactions),
                  SliverElementResonances(resonances: state.resonances),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
