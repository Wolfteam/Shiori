import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shiori/application/bloc.dart';
import 'package:shiori/injection.dart';
import 'package:shiori/presentation/shared/app_webview.dart';
import 'package:shiori/presentation/shared/loading.dart';

const _script = '''
    let wasRemoved = false;
    function removeAdsFromOfficialMap(){
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
    
    function removeAdsFromUnofficialMap() {
      try {
        const ad1 = document.getElementsByClassName('MapLayout_BottomAd');
        if (ad1.length > 0)
          ad1[0].remove();
          
        const ad2 = document.getElementsByClassName('MapLayout_BottomMobiAd');
        if (ad2.length > 0)
          ad2[0].remove();
          
        const divs = document.getElementsByClassName("MapSidebarTabs")[0].childNodes;
        if (divs.length > 2) {
          divs[3].remove();
          divs[2].remove();
        }
        
        const extraButtons = document.getElementsByClassName('TopNav');
        if (extraButtons.length > 0) {
          for (var i = 0; i < extraButtons.length; i++){
             extraButtons[i].remove();
          } 
        }
        
        const hrs = document.getElementsByClassName("mt-4");
        if (hrs.length > 0) {
          const hr = hrs[0];
          const parent = hr.parentElement;
          for (var i = 3; i > 0; i--) {
            const el = parent.children[parent.children.length - i];
            el.innerHTML = "";
            el.style.display = 'none'
          }
        }
      }
      catch(_){
      }
    }
    
    function removeAds() {
      removeAdsFromOfficialMap();
      removeAdsFromUnofficialMap();
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
