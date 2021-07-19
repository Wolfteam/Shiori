import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:genshindb/generated/l10n.dart';
import 'package:genshindb/presentation/shared/page_message.dart';
import 'package:responsive_builder/responsive_builder.dart';

import 'loading.dart';

class AppWebView extends StatefulWidget {
  final String url;
  final String userAgent;
  final bool hasInternetConnection;
  final bool isLoading;
  final String? script;
  final AppBar? appBar;

  const AppWebView({
    Key? key,
    required this.url,
    required this.userAgent,
    required this.hasInternetConnection,
    this.isLoading = false,
    this.script,
    this.appBar,
  }) : super(key: key);

  @override
  _AppWebViewState createState() => _AppWebViewState();
}

class _AppWebViewState extends State<AppWebView> {
  bool _loading = true;

  @override
  Widget build(BuildContext context) {
    if (!widget.hasInternetConnection) {
      final s = S.of(context);
      return PageMessage(text: s.noInternetConnection);
    }
    if (widget.isLoading) {
      return const Loading();
    }
    final device = getDeviceType(MediaQuery.of(context).size);
    return Stack(
      children: [
        Scaffold(
          appBar: widget.appBar,
          body: InAppWebView(
            initialUrlRequest: URLRequest(url: Uri.parse(widget.url)),
            initialOptions: InAppWebViewGroupOptions(
              android: AndroidInAppWebViewOptions(
                useHybridComposition: true,
              ),
              crossPlatform: InAppWebViewOptions(
                preferredContentMode: device == DeviceScreenType.mobile ? UserPreferredContentMode.MOBILE : UserPreferredContentMode.RECOMMENDED,
                //This may fail on weird devices (chinese ones ?)...
                userAgent: widget.userAgent,
                transparentBackground: true,
              ),
            ),
            onLoadStop: (controller, url) async {
              if (widget.script != null) {
                await controller.evaluateJavascript(source: widget.script!);
              }
              setState(() {
                _loading = false;
              });
            },
          ),
        ),
        if (_loading) const Loading(),
      ],
    );
  }
}
