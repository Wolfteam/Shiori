import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shiori/application/bloc.dart';
import 'package:shiori/injection.dart';
import 'package:shiori/presentation/shared/app_webview.dart';
import 'package:shiori/presentation/shared/loading.dart';

const _script = '''
    let wasRemoved = false;
    function removeAds(){
      console.log("Removing ads..");
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
    
    function removeAds2() {
      const ad1 = document.getElementsByClassName('MapLayout_BottomAd');
      if (ad1.length > 0)
        ad1[0].remove();
        
      const ad2 = document.getElementsByClassName('MapLayout_BottomMobiAd');
      if (ad2.length > 0)
        ad2[0].remove();
        
      const appbars = document.getElementsByClassName('MuiAppBar-root');
      if (appbars.length > 0)
        appbars[0].remove();
        
      const buttons = document.getElementsByClassName('MuiTab-root');
      if (buttons.length > 0) {
        buttons[2].remove();
        buttons[1].remove();
      }
      
      const extraButtons = document.getElementsByClassName('TopNav');
      if (extraButtons.length > 0) {
        extraButtons[0].remove();
        extraButtons[1].remove();
      }
    }
    
    setTimeout(removeAds, 500);
    setTimeout(removeAds, 1000);
    setTimeout(removeAds, 2000);
    setTimeout(removeAds, 3500);
    
    setTimeout(removeAds2, 500);
    setTimeout(removeAds2, 1000);
    setTimeout(removeAds2, 2000);
    setTimeout(removeAds2, 3500);
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
