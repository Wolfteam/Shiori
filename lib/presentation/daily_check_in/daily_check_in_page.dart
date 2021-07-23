import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:genshindb/application/bloc.dart';
import 'package:genshindb/generated/l10n.dart';
import 'package:genshindb/presentation/shared/app_webview.dart';
import 'package:genshindb/presentation/shared/info_dialog.dart';
import 'package:genshindb/presentation/shared/loading.dart';

class DailyCheckInPage extends StatefulWidget {
  @override
  _DailyCheckInPageState createState() => _DailyCheckInPageState();
}

class _DailyCheckInPageState extends State<DailyCheckInPage> {
  final script = '''
    function removeButtons() {
      const backButton = document.querySelectorAll('div[class*="back"]');
      const shareButton = document.querySelectorAll('div[class*="share"]');
  
      if (backButton && shareButton) {
          backButton[0].remove();
          shareButton[0].remove();
      }
    }
    
    setTimeout(removeButtons, 300);
    setTimeout(removeButtons, 1200);
    setTimeout(removeButtons, 3000);
    setTimeout(removeButtons, 6000);
   ''';

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    context.read<UrlPageBloc>().add(const UrlPageEvent.init(loadMap: false, loadWishSimulator: false, loadDailyCheckIn: true));
  }

  @override
  Widget build(BuildContext context) {
    final s = S.of(context);
    return SafeArea(
      child: BlocBuilder<UrlPageBloc, UrlPageState>(
        builder: (context, state) {
          return state.map(
            loading: (_) => const Loading(),
            loaded: (state) => AppWebView(
              appBar: AppBar(
                title: Text(s.dailyCheckIn),
                actions: [
                  IconButton(
                    icon: const Icon(Icons.info),
                    onPressed: () => _showInfoDialog(context),
                  ),
                ],
              ),
              url: state.dailyCheckInUrl,
              userAgent: state.userAgent,
              hasInternetConnection: state.hasInternetConnection,
              script: script,
            ),
          );
        },
      ),
    );
  }

  Future<void> _showInfoDialog(BuildContext context) async {
    final s = S.of(context);
    final explanations = [
      s.loginIssuesMsgA,
      s.loginIssuesMsgB,
    ];
    await showDialog(context: context, builder: (context) => InfoDialog(explanations: explanations));
  }
}
