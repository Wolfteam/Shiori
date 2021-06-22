import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:genshindb/application/bloc.dart';
import 'package:genshindb/presentation/shared/app_webview.dart';
import 'package:genshindb/presentation/shared/loading.dart';

class MapPage extends StatefulWidget {
  @override
  _MapPageState createState() => _MapPageState();
}

class _MapPageState extends State<MapPage> {
  final String script = '''
    let wasRemoved = false;
    function removeAds(){
      //console.log("Removing ads..");
      let topNav = document.getElementById("topnav");
      if (topNav) {
        topNav.remove();
      }

      let elements = document.getElementsByClassName("nav-link");
      let total = elements.length;
      for (let index = 0; index < total; index++) {
          const element = elements[index];
          if (index === 2 && !wasRemoved) {
              element.remove();
              wasRemoved = true;
          }
      }

      total = document.getElementsByClassName("fixed-bottom").length;
      for (let index = 0; index < total; index++) {
          if (document.getElementsByClassName("fixed-bottom").length > 0)
            document.getElementsByClassName("fixed-bottom")[0].remove();
      }
    }
    setTimeout(removeAds, 500);
    setTimeout(removeAds, 1000);
    setTimeout(removeAds, 2000);
    setTimeout(removeAds, 3500);
    ''';

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    context.read<UrlPageBloc>().add(const UrlPageEvent.init(loadMap: true, loadWishSimulator: false, loadDailyCheckIn: false));
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<UrlPageBloc, UrlPageState>(
      builder: (context, state) {
        return state.map(
          loading: (_) => const Loading(),
          loaded: (state) => AppWebView(
            url: state.mapUrl,
            userAgent: state.userAgent,
            hasInternetConnection: state.hasInternetConnection,
            script: script,
          ),
        );
      },
    );
  }
}
