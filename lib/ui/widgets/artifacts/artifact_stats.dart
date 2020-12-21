import 'package:flutter/material.dart';

class ArtifactStats extends StatelessWidget {
  final List<String> bonus;

  const ArtifactStats({
    Key key,
    @required this.bonus,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      children: bonus.map(
        (e) {
          final splitted = split(e, ':', max: 1);
          return Container(
            margin: const EdgeInsets.symmetric(vertical: 5),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  splitted.first,
                  textAlign: TextAlign.center,
                  style: theme.textTheme.subtitle2.copyWith(fontSize: 14),
                ),
                Text(
                  splitted.last,
                  textAlign: TextAlign.center,
                  style: theme.textTheme.bodyText2.copyWith(fontSize: 12),
                ),
              ],
            ),
          );
        },
      ).toList(),
    );
  }

  List<String> split(String string, String separator, {int max = 0}) {
    final result = <String>[];
    var copy = string;

    if (separator.isEmpty) {
      result.add(copy);
      return result;
    }

    while (true) {
      final index = copy.indexOf(separator, 0);
      if (index == -1 || (max > 0 && result.length >= max)) {
        result.add(copy);
        break;
      }

      result.add(copy.substring(0, index));
      copy = copy.substring(index + separator.length);
    }

    return result;
  }
}
