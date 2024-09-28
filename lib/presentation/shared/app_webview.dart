import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:responsive_builder/responsive_builder.dart';
import 'package:shiori/generated/l10n.dart';
import 'package:shiori/presentation/shared/loading.dart';
import 'package:shiori/presentation/shared/nothing_found_column.dart';
import 'package:shiori/presentation/shared/page_message.dart';

class AppWebView extends StatelessWidget {
  final String url;
  final String userAgent;
  final bool hasInternetConnection;
  final bool isLoading;
  final String? script;
  final AppBar? appBar;
  final bool showCloseButton;

  const AppWebView({
    super.key,
    required this.url,
    required this.userAgent,
    required this.hasInternetConnection,
    this.isLoading = false,
    this.script,
    this.appBar,
    this.showCloseButton = false,
  });

  @override
  Widget build(BuildContext context) {
    final isPlatformSupported = [Platform.isAndroid || Platform.isIOS || Platform.isMacOS || Platform.isWindows].any((el) => el);
    if (isPlatformSupported) {
      return _MobileWebView(
        url: url,
        userAgent: userAgent,
        hasInternetConnection: hasInternetConnection,
        appBar: appBar,
        script: script,
        isLoading: isLoading,
        showCloseButton: showCloseButton,
      );
    }

    //TODO: BETA 6 of flutter_inappwebview should add support macos
    final s = S.of(context);
    return Scaffold(
      appBar: appBar,
      body: NothingFoundColumn(msg: s.nothingToShow),
    );
  }
}

class _MobileWebView extends StatefulWidget {
  final String url;
  final String userAgent;
  final bool hasInternetConnection;
  final bool isLoading;
  final String? script;
  final AppBar? appBar;
  final bool showCloseButton;

  const _MobileWebView({
    required this.url,
    required this.userAgent,
    required this.hasInternetConnection,
    this.isLoading = false,
    this.script,
    this.appBar,
    this.showCloseButton = false,
  });

  @override
  _MobileWebViewState createState() => _MobileWebViewState();
}

class _MobileWebViewState extends State<_MobileWebView> {
  bool _loading = true;

  @override
  Widget build(BuildContext context) {
    if (!widget.hasInternetConnection) {
      final s = S.of(context);
      final children = [
        if (widget.showCloseButton) const LoadingCloseButton(),
      ];
      return PageMessage(text: s.noInternetConnection, children: children);
    }
    if (widget.isLoading) {
      return Loading(showCloseButton: widget.showCloseButton);
    }
    final device = getDeviceType(MediaQuery.of(context).size);
    return Stack(
      children: [
        Scaffold(
          appBar: widget.appBar,
          body: InAppWebView(
            initialUrlRequest: URLRequest(url: WebUri.uri(Uri.parse(widget.url))),
            initialSettings: InAppWebViewSettings(
              preferredContentMode: device == DeviceScreenType.mobile ? UserPreferredContentMode.MOBILE : UserPreferredContentMode.RECOMMENDED,
              //This may fail on weird devices (chinese ones ?)...
              userAgent: widget.userAgent,
              transparentBackground: true,
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
        if (_loading) Loading(showCloseButton: widget.appBar != null),
      ],
    );
  }
}
