import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shiori/application/bloc.dart';
import 'package:shiori/injection.dart';
import 'package:shiori/presentation/custom_build/custom_build_page.dart';
import 'package:shiori/presentation/custom_builds/widgets/custom_build_card.dart';
import 'package:shiori/presentation/shared/app_fab.dart';
import 'package:shiori/presentation/shared/mixins/app_fab_mixin.dart';
import 'package:shiori/presentation/shared/nothing_found_column.dart';
import 'package:waterfall_flow/waterfall_flow.dart';

class CustomBuildsPage extends StatefulWidget {
  const CustomBuildsPage({Key? key}) : super(key: key);

  @override
  State<CustomBuildsPage> createState() => _CustomBuildsPageState();
}

class _CustomBuildsPageState extends State<CustomBuildsPage> with SingleTickerProviderStateMixin, AppFabMixin {
  @override
  bool get isInitiallyVisible => true;

  @override
  bool get hideOnTop => false;

  @override
  Widget build(BuildContext context) {
    final mq = MediaQuery.of(context);
    final crossAxisCount = mq.size.width > 1600
        ? 4
        : mq.size.width > 1200
            ? 3
            : mq.size.width > 620
                ? 2
                : 1;
    return BlocProvider<CustomBuildsBloc>(
      create: (context) => Injection.customBuildsBloc..add(const CustomBuildsEvent.load()),
      child: Scaffold(
        appBar: AppBar(
          title: Text('Custom Builds'),
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
                  ? NothingFoundColumn(msg: 'Start by creating a new build')
                  : WaterfallFlow.builder(
                      itemCount: state.builds.length,
                      gridDelegate: SliverWaterfallFlowDelegateWithFixedCrossAxisCount(
                        crossAxisCount: crossAxisCount,
                      ),
                      itemBuilder: (context, index) => CustomBuildCard(item: state.builds[index]),
                    )
              // : ListView.builder(
              //     itemCount: state.builds.length,
              //     itemBuilder: (context, index) => CustomBuild(item: state.builds[index]),
              //   ),
              ),
        ),
      ),
    );
  }

  Future<void> _goToDetailsPage() async {
    // await showModalBottomSheet(
    //   context: context,
    //   shape: Styles.modalBottomSheetShape,
    //   isDismissible: true,
    //   isScrollControlled: true,
    //   builder: (ctx) => CommonBottomSheet(
    //     titleIcon: Icons.edit,
    //     title: 'Algo aca',
    //     showOkButton: false,
    //     showCancelButton: false,
    //     child: CustomBuildPage(),
    //   ),
    // );
    final route = MaterialPageRoute(builder: (ctx) => CustomBuildPage());
    await Navigator.push(context, route);
  }
}
