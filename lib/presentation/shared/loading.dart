import 'package:flutter/material.dart';
import 'package:shiori/generated/l10n.dart';

class Loading extends StatelessWidget {
  final bool useScaffold;
  final MainAxisSize mainAxisSize;

  const Loading({
    this.useScaffold = true,
    this.mainAxisSize = MainAxisSize.max,
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
      ],
    );
    if (!useScaffold) return body;
    return Scaffold(body: body);
  }
}
