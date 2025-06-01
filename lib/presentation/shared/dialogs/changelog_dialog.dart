import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_markdown_plus/flutter_markdown_plus.dart';
import 'package:shiori/application/changelog/changelog_bloc.dart';
import 'package:shiori/generated/l10n.dart';
import 'package:shiori/injection.dart';
import 'package:shiori/presentation/shared/extensions/media_query_extensions.dart';
import 'package:shiori/presentation/shared/loading.dart';

class ChangelogDialog extends StatelessWidget {
  const ChangelogDialog({super.key});

  @override
  Widget build(BuildContext context) {
    final mq = MediaQuery.of(context);
    final s = S.of(context);
    return BlocProvider<ChangelogBloc>(
      create: (ctx) => Injection.changelogBloc..add(const ChangelogEvent.init()),
      child: AlertDialog(
        content: SizedBox(
          width: mq.getWidthForDialogs(),
          child: SingleChildScrollView(
            child: BlocBuilder<ChangelogBloc, ChangelogState>(
              builder: (ctx, state) => switch (state) {
                ChangelogStateLoading() => const Loading(useScaffold: false, mainAxisSize: MainAxisSize.min),
                ChangelogStateLoaded() => MarkdownBody(data: state.changelog),
              },
            ),
          ),
        ),
        actions: [FilledButton(onPressed: () => Navigator.of(context).pop(), child: Text(s.ok))],
      ),
    );
  }
}
