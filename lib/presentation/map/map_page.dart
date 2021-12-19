import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shiori/application/bloc.dart';
import 'package:shiori/injection.dart';
import 'package:shiori/presentation/shared/app_webview.dart';
import 'package:shiori/presentation/shared/loading.dart';

const _script = '''
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
      
      total = document.getElementsByClassName("sidebar-footer").length;
      for (let index = 0; index < total; index++) {
          if (document.getElementsByClassName("sidebar-footer").length > 0)
            document.getElementsByClassName("sidebar-footer")[0].remove();
      }
      
      if (document.getElementsByClassName("bbs-qr").length > 0){
        document.getElementsByClassName("bbs-qr")[0].remove();
      }
      
      if (document.getElementsByClassName("mhy-hoyolab-app-header").length > 0){
        document.getElementsByClassName("mhy-hoyolab-app-header")[0].remove();
      }
    }
    setTimeout(removeAds, 500);
    setTimeout(removeAds, 1000);
    setTimeout(removeAds, 2000);
    setTimeout(removeAds, 3500);
    ''';

class MapPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return BlocProvider<UrlPageBloc>(
      create: (ctx) => Injection.urlPageBloc..add(const UrlPageEvent.init(loadMap: true, loadWishSimulator: false, loadDailyCheckIn: false)),
      child: BlocBuilder<UrlPageBloc, UrlPageState>(
        builder: (context, state) => state.map(
          loading: (_) => const Loading(),
          loaded: (state) => AppWebView(
            url: state.mapUrl,
            userAgent: state.userAgent,
            hasInternetConnection: state.hasInternetConnection,
            script: _script,
          ),
        ),
      ),
    );
  }
}
