import 'package:flutter/material.dart';

import '../../../generated/l10n.dart';

class Loading extends StatelessWidget {
  final bool useScaffold;
  const Loading({this.useScaffold = true});

  @override
  Widget build(BuildContext context) {
    final s = S.of(context);
    final body = Column(
      mainAxisAlignment: MainAxisAlignment.center,
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
