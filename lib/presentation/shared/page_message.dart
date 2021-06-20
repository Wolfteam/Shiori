import 'package:flutter/material.dart';

class PageMessage extends StatelessWidget {
  final String text;
  final bool useScaffold;
  final List<Widget> children;

  const PageMessage({
    Key? key,
    required this.text,
    this.useScaffold = true,
    this.children = const [],
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final body = Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        Container(
          margin: const EdgeInsets.only(top: 5),
          child: Text(text, textAlign: TextAlign.center),
        ),
      ],
    );
    if (!useScaffold) return body;
    return Scaffold(body: body);
  }
}
