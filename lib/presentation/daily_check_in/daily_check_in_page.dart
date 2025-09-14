import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shiori/application/bloc.dart';
import 'package:shiori/generated/l10n.dart';
import 'package:shiori/injection.dart';
import 'package:shiori/presentation/shared/app_webview.dart';
import 'package:shiori/presentation/shared/dialogs/info_dialog.dart';
import 'package:shiori/presentation/shared/loading.dart';
import 'package:shiori/presentation/shared/styles.dart';
import 'package:url_launcher/url_launcher.dart';

const _script = '''
    function removeButtons() {
      if (document.querySelectorAll('div[class*="back"]').length > 0 && document.querySelectorAll('div[class*="share"]').length > 0) {
          document.querySelectorAll('div[class*="back"]')[0].remove();
          document.querySelectorAll('div[class*="share"]')[0].remove();
      }
      
      if (document.querySelectorAll("div[class*='left'").length > 0) {
        document.querySelectorAll("div[class*='left'")[0].replaceChildren("");
      }
      
      if (document.getElementsByClassName("bbs-qr").length > 0){
        document.getElementsByClassName("bbs-qr")[0].remove();
      }
      
      if (document.getElementsByClassName("mhy-hoyolab-app-header").length > 0){
        document.getElementsByClassName("mhy-hoyolab-app-header")[0].remove();
      }
    }
    
    setTimeout(removeButtons, 300);
    setTimeout(removeButtons, 1200);
    setTimeout(removeButtons, 3000);
    setTimeout(removeButtons, 6000);
   ''';

class DailyCheckInPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final s = S.of(context);
    return SafeArea(
      child: BlocProvider(
        create: (ctx) => Injection.urlPageBloc..add(const UrlPageEvent.init(loadMap: false, loadDailyCheckIn: true)),
        child: BlocBuilder<UrlPageBloc, UrlPageState>(
          builder: (context, state) => switch (state) {
            UrlPageStateLoading() => const Loading(showCloseButton: true),
            UrlPageStateLoaded() => AppWebView(
              appBar: AppBar(
                title: Text(s.dailyCheckIn),
                actions: [
                  IconButton(
                    icon: const Icon(Icons.info),
                    splashRadius: Styles.mediumButtonSplashRadius,
                    onPressed: () => _showInfoDialog(context),
                  ),
                  IconButton(
                    icon: const Icon(Icons.open_in_new),
                    splashRadius: Styles.mediumButtonSplashRadius,
                    onPressed: () => _launchUrl(state.dailyCheckInUrl),
                  ),
                ],
              ),
              url: state.dailyCheckInUrl,
              userAgent: state.userAgent,
              hasInternetConnection: state.hasInternetConnection,
              script: _script,
              showCloseButton: true,
            ),
          },
        ),
      ),
    );
  }

  Future<void> _launchUrl(String url) async {
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    }
  }

  Future<void> _showInfoDialog(BuildContext context) async {
    final s = S.of(context);
    final explanations = [
      s.loginIssuesMsgA,
      s.loginIssuesMsgB,
    ];
    await showDialog(
      context: context,
      builder: (context) => InfoDialog(explanations: explanations),
    );
  }
}
