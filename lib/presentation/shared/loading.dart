import 'package:flutter/material.dart';
import 'package:shiori/generated/l10n.dart';
import 'package:shiori/presentation/shared/styles.dart';

class Loading extends StatelessWidget {
  final bool useScaffold;
  final MainAxisSize mainAxisSize;
  final bool showCloseButton;

  const Loading({
    this.useScaffold = true,
    this.mainAxisSize = MainAxisSize.max,
    this.showCloseButton = false,
  });

  @override
  Widget build(BuildContext context) {
    final s = S.of(context);
    final body = Column(
      mainAxisAlignment: MainAxisAlignment.center,
      mainAxisSize: mainAxisSize,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        const Center(
          child: CircularProgressIndicator(),
        ),
        Container(
          margin: const EdgeInsets.only(top: 5),
          child: Text(s.loading, textAlign: TextAlign.center),
        ),
        if (showCloseButton)
          IconButton.filled(
            onPressed: () => Navigator.pop(context),
            icon: Icon(Icons.close, color: Theme.of(context).colorScheme.primary),
            splashRadius: Styles.mediumButtonSplashRadius,
          ),
      ],
    );
    if (!useScaffold) return body;
    return Scaffold(body: body);
  }
}
