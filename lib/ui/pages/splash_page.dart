import 'package:flutter/material.dart';

import '../../common/assets.dart';

class SplashPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Container(
            margin: const EdgeInsets.all(10),
            child: Image.asset(
              Assets.getCharacterFullPath('Paimon.png'),
              fit: BoxFit.fill,
            ),
          ),
          const CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
          ),
        ],
      ),
    );
  }
}
