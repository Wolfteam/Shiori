import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shiori/application/bloc.dart';
import 'package:shiori/generated/l10n.dart';
import 'package:shiori/injection.dart';
import 'package:shiori/presentation/custom_build/custom_build_page.dart';
import 'package:shiori/presentation/custom_builds/widgets/custom_build_card.dart';
import 'package:shiori/presentation/shared/app_fab.dart';
import 'package:shiori/presentation/shared/mixins/app_fab_mixin.dart';
import 'package:shiori/presentation/shared/nothing_found_column.dart';
import 'package:shiori/presentation/shared/styles.dart';

class CustomBuildsPage extends StatelessWidget {
  const CustomBuildsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider<CustomBuildsBloc>(
      create: (context) => Injection.customBuildsBloc..add(const CustomBuildsEvent.load()),
      child: const _Page(),
    );
  }
}

class _Page extends StatefulWidget {
  const _Page();

  @override
  _PageState createState() => _PageState();
}

class _PageState extends State<_Page> with SingleTickerProviderStateMixin, AppFabMixin {
  @override
  bool get isInitiallyVisible => true;

  @override
  bool get hideOnTop => false;

  @override
  Widget build(BuildContext context) {
    final s = S.of(context);
    return Scaffold(
      appBar: AppBar(
        title: Text(s.customBuilds),
      ),
      floatingActionButton: AppFab(
        onPressed: () => _goToDetailsPage(),
        icon: const Icon(Icons.add),
        hideFabAnimController: hideFabAnimController,
        scrollController: scrollController,
        mini: false,
      ),
      body: BlocBuilder<CustomBuildsBloc, CustomBuildsState>(
        builder: (context, state) => SafeArea(
          child: state.builds.isEmpty
              ? NothingFoundColumn(msg: s.startByCreatingBuild)
              : GridView.builder(
                  itemCount: state.builds.length,
                  padding: Styles.edgeInsetAll5,
                  gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                    maxCrossAxisExtent: CustomBuildCard.itemWidth,
                    crossAxisSpacing: 10,
                    mainAxisSpacing: 10,
                    mainAxisExtent: CustomBuildCard.itemHeight,
                    childAspectRatio: CustomBuildCard.itemWidth / CustomBuildCard.itemHeight,
                  ),
                  itemBuilder: (context, index) => CustomBuildCard(item: state.builds[index]),
                ),
        ),
      ),
    );
  }

  Future<void> _goToDetailsPage() async {
    final route = MaterialPageRoute(
      builder: (ctx) => BlocProvider.value(
        value: context.read<CustomBuildsBloc>(),
        child: const CustomBuildPage(),
      ),
    );
    await Navigator.push(context, route);
  }
}
