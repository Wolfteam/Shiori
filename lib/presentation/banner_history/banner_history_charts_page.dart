import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shiori/application/bloc.dart';
import 'package:shiori/injection.dart';

class BannerHistoryChartsPage extends StatelessWidget {
  const BannerHistoryChartsPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => Injection.bannerHistoryChartsBloc..add(const BannerHistoryChartsEvent.init()),
      child: Scaffold(
        body: Container(
          child: Text('Algo aca'),
        ),
      ),
    );
  }
}
