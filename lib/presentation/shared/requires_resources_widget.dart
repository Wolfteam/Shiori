import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shiori/application/bloc.dart';
import 'package:shiori/presentation/shared/dialogs/check_for_resource_updates_dialog.dart';

class RequiresDownloadedResourcesWidget extends StatelessWidget {
  final Widget child;

  const RequiresDownloadedResourcesWidget({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<SettingsBloc, SettingsState>(
      builder: (context, state) => switch (state) {
        SettingsStateLoading() => const CircularProgressIndicator(),
        final SettingsStateLoaded state when state.resourceVersion <= 0 => GestureDetector(
          onTap: () => showDialog(context: context, builder: (context) => const CheckForResourceUpdatesDialog()),
          child: AbsorbPointer(
            child: Opacity(
              opacity: 0.5,
              child: child,
            ),
          ),
        ),
        SettingsStateLoaded() => child,
      },
    );
  }
}
