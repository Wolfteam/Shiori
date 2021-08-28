import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shiori/application/bloc.dart';
import 'package:shiori/generated/l10n.dart';
import 'package:shiori/presentation/shared/app_webview.dart';
import 'package:shiori/presentation/shared/loading.dart';

class WishSimulatorPage extends StatefulWidget {
  @override
  _WishSimulatorPageState createState() => _WishSimulatorPageState();
}

class _WishSimulatorPageState extends State<WishSimulatorPage> {
  final script = '''
    function closeModal(){
      if (document.getElementsByClassName("modal-container").length === 0)
        return;
      let modal = document.getElementsByClassName("modal-container")[0];
      if (!modal)
        return;
      let closeModalBtn = modal.querySelector(".close-button");
      if (!closeModalBtn)
        return;
      
      closeModalBtn.click();
    }
    
    setTimeout(closeModal, 300);
    setTimeout(closeModal, 1200);
    setTimeout(closeModal, 3000);
    setTimeout(closeModal, 6000);
   ''';

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    context.read<UrlPageBloc>().add(const UrlPageEvent.init(loadMap: false, loadWishSimulator: true, loadDailyCheckIn: false));
  }

  @override
  Widget build(BuildContext context) {
    final s = S.of(context);
    return SafeArea(child: BlocBuilder<UrlPageBloc, UrlPageState>(
      builder: (context, state) {
        return state.map(
          loading: (_) => const Loading(),
          loaded: (state) => AppWebView(
            appBar: AppBar(title: Text(s.wishSimulator)),
            url: state.wishSimulatorUrl,
            userAgent: state.userAgent,
            hasInternetConnection: state.hasInternetConnection,
            script: script,
          ),
        );
      },
    ));
  }
}
