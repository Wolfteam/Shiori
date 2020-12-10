import 'package:flutter/material.dart';

class Loading extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          const Center(
            child: CircularProgressIndicator(),
          ),
          Container(
            margin: const EdgeInsets.only(top: 5),
            child: Text('Loading...', textAlign: TextAlign.center),
          ),
        ],
      ),
    );
  }
}
