import 'dart:ui';

import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';

const Duration _bottomSheetEnterDuration = Duration(milliseconds: 250);
const Duration _bottomSheetExitDuration = Duration(milliseconds: 200);
const Curve _modalBottomSheetCurve = decelerateEasing;
const double _minFlingVelocity = 700.0;
const double _closeProgressThreshold = 0.5;

//TODO: ALLOW DRAGGING THIS
typedef WidgetBuilder = Widget Function(BuildContext context);

Future<T?> showCustomModalBottomSheet<T>({
  required BuildContext context,
  required WidgetBuilder builder,
  Color? backgroundColor,
  double? elevation,
  ShapeBorder? shape,
  Clip? clipBehavior,
  Color? barrierColor,
  bool isScrollControlled = false,
  bool useRootNavigator = false,
  bool isDismissible = true,
  bool enableDrag = true,
  RouteSettings? routeSettings,
  AnimationController? transitionAnimationController,
}) {
  assert(context != null);
  assert(builder != null);
  assert(isScrollControlled != null);
  assert(useRootNavigator != null);
  assert(isDismissible != null);
  assert(enableDrag != null);
  assert(debugCheckHasMediaQuery(context));
  assert(debugCheckHasMaterialLocalizations(context));

  final NavigatorState navigator = Navigator.of(context, rootNavigator: useRootNavigator);
  return navigator.push(_ModalBottomSheetRoute<T>(
    builder: builder,
    capturedThemes: InheritedTheme.capture(from: context, to: navigator.context),
    isScrollControlled: isScrollControlled,
    barrierLabel: MaterialLocalizations.of(context).modalBarrierDismissLabel,
    backgroundColor: backgroundColor,
    elevation: elevation,
    shape: shape,
    clipBehavior: clipBehavior,
    isDismissible: isDismissible,
    modalBarrierColor: barrierColor,
    enableDrag: enableDrag,
    settings: routeSettings,
    transitionAnimationController: transitionAnimationController,
  ));
}

class _ModalBottomSheetRoute<T> extends PopupRoute<T> {
  _ModalBottomSheetRoute({
    this.builder,
    required this.capturedThemes,
    this.barrierLabel,
    this.backgroundColor,
    this.elevation,
    this.shape,
    this.clipBehavior,
    this.modalBarrierColor,
    this.isDismissible = true,
    this.enableDrag = true,
    required this.isScrollControlled,
    RouteSettings? settings,
    this.transitionAnimationController,
  })  : assert(isScrollControlled != null),
        assert(isDismissible != null),
        assert(enableDrag != null),
        super(settings: settings);

  final WidgetBuilder? builder;
  final CapturedThemes capturedThemes;
  final bool isScrollControlled;
  final Color? backgroundColor;
  final double? elevation;
  final ShapeBorder? shape;
  final Clip? clipBehavior;
  final Color? modalBarrierColor;
  final bool isDismissible;
  final bool enableDrag;
  final AnimationController? transitionAnimationController;

  @override
  Duration get transitionDuration => _bottomSheetEnterDuration;

  @override
  Duration get reverseTransitionDuration => _bottomSheetExitDuration;

  @override
  bool get barrierDismissible => isDismissible;

  @override
  final String? barrierLabel;

  @override
  Color get barrierColor => modalBarrierColor ?? Colors.black54;

  AnimationController? _animationController;

  @override
  AnimationController createAnimationController() {
    assert(_animationController == null);
    _animationController = transitionAnimationController ?? BottomSheet.createAnimationController(navigator!.overlay!);
    return _animationController!;
  }

  @override
  Widget buildPage(BuildContext context, Animation<double> animation, Animation<double> secondaryAnimation) {
    // By definition, the bottom sheet is aligned to the bottom of the page
    // and isn't exposed to the top padding of the MediaQuery.
    final BottomSheetThemeData sheetTheme = Theme.of(context).bottomSheetTheme;
    return _ModalBottomSheet<T>(
      route: this,
      backgroundColor: backgroundColor ?? sheetTheme.modalBackgroundColor ?? sheetTheme.backgroundColor,
      elevation: elevation ?? sheetTheme.modalElevation ?? sheetTheme.elevation,
      shape: shape,
      clipBehavior: clipBehavior,
      isScrollControlled: isScrollControlled,
      enableDrag: enableDrag,
    );
    // return capturedThemes.wrap(bottomSheet);
  }
}

class _ModalBottomSheet<T> extends StatefulWidget {
  const _ModalBottomSheet({
    Key? key,
    this.route,
    this.backgroundColor,
    this.elevation,
    this.shape,
    this.clipBehavior,
    this.isScrollControlled = false,
    this.enableDrag = true,
  })  : assert(isScrollControlled != null),
        assert(enableDrag != null),
        super(key: key);

  final _ModalBottomSheetRoute<T>? route;
  final bool isScrollControlled;
  final Color? backgroundColor;
  final double? elevation;
  final ShapeBorder? shape;
  final Clip? clipBehavior;
  final bool enableDrag;

  @override
  _ModalBottomSheetState<T> createState() => _ModalBottomSheetState<T>();
}

class _ModalBottomSheetState<T> extends State<_ModalBottomSheet<T>> {
  ParametricCurve<double> animationCurve = _modalBottomSheetCurve;
  final GlobalKey<DrawerControllerState> _endDrawerKey = GlobalKey<DrawerControllerState>();

  String _getRouteLabel(MaterialLocalizations localizations) {
    switch (Theme.of(context).platform) {
      case TargetPlatform.iOS:
      case TargetPlatform.macOS:
        return '';
      case TargetPlatform.android:
      case TargetPlatform.fuchsia:
      case TargetPlatform.linux:
      case TargetPlatform.windows:
        return localizations.dialogLabel;
    }
  }

  void handleDragStart(DragStartDetails details) {
    // Allow the bottom sheet to track the user's finger accurately.
    animationCurve = Curves.linear;
  }

  void handleDragEnd(DragEndDetails details, {bool? isClosing}) {
    // Allow the bottom sheet to animate smoothly from its current position.
    animationCurve = _BottomSheetSuspendedCurve(
      widget.route!.animation!.value,
      curve: _modalBottomSheetCurve,
    );
  }

  @override
  Widget build(BuildContext context) {
    assert(debugCheckHasMediaQuery(context));
    assert(debugCheckHasMaterialLocalizations(context));
    final MediaQueryData mediaQuery = MediaQuery.of(context);
    final MaterialLocalizations localizations = MaterialLocalizations.of(context);
    final String routeLabel = _getRouteLabel(localizations);
    return AnimatedBuilder(
      animation: widget.route!.animation!,
      builder: (BuildContext context, Widget? child) {
        // Disable the initial animation when accessible navigation is on so
        // that the semantics are added to the tree at the correct time.
        final double animationValue = animationCurve.transform(
          mediaQuery.accessibleNavigation ? 1.0 : widget.route!.animation!.value,
        );
        return Semantics(
          scopesRoute: true,
          namesRoute: true,
          label: routeLabel,
          explicitChildNodes: true,
          child: ClipRect(
            child: CustomSingleChildLayout(
              delegate: _ModalBottomSheetLayout(animationValue, widget.isScrollControlled, context),
              child: child,
            ),
          ),
        );
      },
      child: GestureDetector(
        onHorizontalDragStart: handleDragStart,
        onHorizontalDragEnd: handleDragEnd,
        child: SafeArea(
          child: Material(
            child: Container(
              margin: const EdgeInsets.only(top: 10, left: 16, right: 16),
              child: widget.route!.builder!(context),
            ),
          ),
        ),
      ),
      // child: DrawerController(
      //   key: _endDrawerKey,
      //   alignment: DrawerAlignment.end,
      //   child: Container(
      //     color: Colors.green,
      //     child: Text('It works!'),
      //   ),
      //   isDrawerOpen: true,
      //   // drawerCallback: _endDrawerOpenedCallback,
      //   // dragStartBehavior: widget.drawerDragStartBehavior,
      //   // scrimColor: widget.drawerScrimColor,
      //   // edgeDragWidth: widget.drawerEdgeDragWidth,
      //   // enableOpenDragGesture: widget.endDrawerEnableOpenDragGesture,
      //   // isDrawerOpen: _endDrawerOpened.value,
      // ),
    );
    // child: BottomSheet(
    //   animationController: widget.route!._animationController,
    //   onClosing: () {
    //     if (widget.route!.isCurrent) {
    //       Navigator.pop(context);
    //     }
    //   },
    //   builder: widget.route!.builder!,
    //   backgroundColor: widget.backgroundColor,
    //   elevation: widget.elevation,
    //   shape: widget.shape,
    //   clipBehavior: widget.clipBehavior,
    //   enableDrag: widget.enableDrag,
    //   onDragStart: handleDragStart,
    //   onDragEnd: handleDragEnd,
    // ),
  }
}

class _ModalBottomSheetLayout extends SingleChildLayoutDelegate {
  _ModalBottomSheetLayout(this.progress, this.isScrollControlled, this.context);

  final double progress;
  final bool isScrollControlled;
  final BuildContext context;

  @override
  BoxConstraints getConstraintsForChild(BoxConstraints constraints) {
    final extended = MediaQuery.of(context).orientation != Orientation.portrait;
    final height = MediaQuery.of(context).size.height;
    final width = MediaQuery.of(context).size.width;
    return BoxConstraints(
      minWidth: extended ? width * 0.45 : width * 0.6,
      maxWidth: extended ? width * 0.45 : width * 0.6,
      minHeight: height,
      maxHeight: height,
    );
  }

  @override
  Offset getPositionForChild(Size size, Size childSize) {
    return Offset(size.width - childSize.width * progress, 0);
  }

  @override
  bool shouldRelayout(_ModalBottomSheetLayout oldDelegate) {
    return progress != oldDelegate.progress;
  }
}

class _BottomSheetSuspendedCurve extends ParametricCurve<double> {
  /// Creates a suspended curve.
  const _BottomSheetSuspendedCurve(
    this.startingPoint, {
    this.curve = Curves.easeOutCubic,
  })  : assert(startingPoint != null),
        assert(curve != null);

  /// The progress value at which [curve] should begin.
  ///
  /// This defaults to [Curves.easeOutCubic].
  final double startingPoint;

  /// The curve to use when [startingPoint] is reached.
  final Curve curve;

  @override
  double transform(double t) {
    assert(t >= 0.0 && t <= 1.0);
    assert(startingPoint >= 0.0 && startingPoint <= 1.0);

    if (t < startingPoint) {
      return t;
    }

    if (t == 1.0) {
      return t;
    }

    final double curveProgress = (t - startingPoint) / (1 - startingPoint);
    final double transformed = curve.transform(curveProgress);
    return lerpDouble(startingPoint, 1, transformed)!;
  }

  @override
  String toString() {
    return '${describeIdentity(this)}($startingPoint, $curve)';
  }
}
