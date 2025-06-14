import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shiori/application/bloc.dart';
import 'package:shiori/presentation/shared/dialogs/check_for_resource_updates_dialog.dart';
import 'package:shiori/presentation/shared/styles.dart';

class RequiresDownloadedResourcesWidget extends StatelessWidget {
  final Widget child;
  final double loadingWidth;

  const RequiresDownloadedResourcesWidget({super.key, required this.child, this.loadingWidth = Styles.homeCardWidth});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<SettingsBloc, SettingsState>(
      builder: (context, state) => switch (state) {
        SettingsStateLoading() => SizedBox.square(
          dimension: loadingWidth,
          child: const Center(child: CircularProgressIndicator()),
        ),
        final SettingsStateLoaded state when state.resourceVersion <= 0 => GestureDetector(
          onTap: () => showDialog(context: context, builder: (context) => const CheckForResourceUpdatesDialog()),
          child: AbsorbPointer(child: Opacity(opacity: 0.5, child: child)),
        ),
        SettingsStateLoaded() => child,
      },
    );
  }
}
