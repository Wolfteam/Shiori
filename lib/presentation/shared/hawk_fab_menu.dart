import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';

/// Wrapper that builds a FAB menu on top of [body] in a [Stack]
class HawkFabMenu extends StatefulWidget {
  final Widget body;
  final List<HawkFabMenuItem> items;
  final double blur;
  final AnimatedIconData? icon;
  final Color? fabColor;
  final Color? iconColor;
  final ScrollController? scrollController;
  final bool hideOnScroll;

  HawkFabMenu({
    required this.body,
    required this.items,
    this.blur = 5.0,
    this.icon,
    this.fabColor,
    this.iconColor,
    this.scrollController,
    this.hideOnScroll = false,
  }) : assert(items.isNotEmpty);

  @override
  _HawkFabMenuState createState() => _HawkFabMenuState();
}

class _HawkFabMenuState extends State<HawkFabMenu> with TickerProviderStateMixin {
  /// To check if the menu is open
  bool _isOpen = false;

  /// The [Duration] for every animation
  final Duration _duration = const Duration(milliseconds: 500);

  /// Flag to track if FAB is visible
  bool _isFabVisible = true;

  /// Animation controller for FAB visibility
  late AnimationController _fabAnimationController;

  /// Animation controller that animates the menu item
  late AnimationController _iconAnimationCtrl;

  /// Animation that animates the menu item
  late Animation<double> _iconAnimationTween;

  /// Animation for showing/hiding the FAB
  late Animation<double> _fabAnimation;

  @override
  void initState() {
    super.initState();
    _iconAnimationCtrl = AnimationController(
      vsync: this,
      duration: _duration,
    );
    _iconAnimationTween = Tween(
      begin: 0.0,
      end: 1.0,
    ).animate(_iconAnimationCtrl);

    // Setup FAB visibility animation
    _fabAnimationController = AnimationController(
      vsync: this,
      duration: kThemeAnimationDuration,
      value: 1.0, // Start as visible
    );
    _fabAnimation = CurvedAnimation(
      parent: _fabAnimationController,
      curve: Curves.easeInOut,
    );

    // Add scroll listener if hideOnScroll is enabled
    if (widget.hideOnScroll && widget.scrollController != null) {
      widget.scrollController!.addListener(_handleScroll);
    }
  }

  /// Closes the menu if open and vice versa
  void _toggleMenu() {
    setState(() {
      _isOpen = !_isOpen;
    });
    if (_isOpen) {
      _iconAnimationCtrl.forward();
    } else {
      _iconAnimationCtrl.reverse();
    }
  }

  /// If the menu is open and the device's back button is pressed then menu gets closed instead of going back.
  Future<bool> _preventPopIfOpen() async {
    if (_isOpen) {
      _toggleMenu();
      return false;
    }
    return true;
  }

  /// Handle scroll events to show/hide FAB
  void _handleScroll() {
    if (!widget.hideOnScroll || widget.scrollController == null) {
      return;
    }

    final ScrollController controller = widget.scrollController!;

    // Don't do anything if we can't get scroll positions
    if (!controller.hasClients) {
      return;
    }

    // Check scroll direction by the delta of position
    if (controller.position.userScrollDirection == ScrollDirection.reverse) {
      // Scrolling down - hide the FAB
      if (_isFabVisible) {
        _isFabVisible = false;
        _fabAnimationController.reverse();
        // Close menu if it's open
        if (_isOpen) _toggleMenu();
      }
    } else if (controller.position.userScrollDirection == ScrollDirection.forward) {
      // Scrolling up - show the FAB
      if (!_isFabVisible) {
        _isFabVisible = true;
        _fabAnimationController.forward();
      }
    }
  }

  @override
  void dispose() {
    _iconAnimationCtrl.dispose();
    _fabAnimationController.dispose();
    if (widget.hideOnScroll && widget.scrollController != null) {
      widget.scrollController!.removeListener(_handleScroll);
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) async {
        if (didPop) {
          return;
        }
        await _preventPopIfOpen().then(
          (backNavigationAllowed) {
            if (mounted && backNavigationAllowed && context.mounted) {
              Navigator.of(context).pop();
            }
          },
        );
      },
      child: Stack(
        children: <Widget>[
          widget.body,
          if (_isOpen) _buildBlurWidget(),
          if (_isOpen) _buildMenuItemList(),
          _buildMenuButton(context),
        ],
      ),
    );
  }

  /// Returns animated list of menu items
  Widget _buildMenuItemList() {
    return Positioned(
      bottom: 80,
      right: 15,
      child: ScaleTransition(
        scale: AnimationController(
          vsync: this,
          value: 0.7,
          duration: kThemeAnimationDuration,
        )..forward(),
        child: SizeTransition(
          axis: Axis.horizontal,
          sizeFactor: AnimationController(
            vsync: this,
            value: 0.5,
            duration: kThemeAnimationDuration,
          )..forward(),
          child: FadeTransition(
            opacity: AnimationController(
              vsync: this,
              value: 0.0,
              duration: kThemeAnimationDuration,
            )..forward(),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: widget.items
                  .map<Widget>(
                    (item) => _MenuItemWidget(
                      item: item,
                      toggleMenu: _toggleMenu,
                    ),
                  )
                  .toList(),
            ),
          ),
        ),
      ),
    );
  }

  /// Builds the blur effect when the menu is opened
  Widget _buildBlurWidget() {
    return InkWell(
      onTap: _toggleMenu,
      hoverColor: Colors.transparent,
      child: BackdropFilter(
        filter: ui.ImageFilter.blur(
          sigmaX: widget.blur,
          sigmaY: widget.blur,
        ),
        child: Container(
          color: Colors.black12,
        ),
      ),
    );
  }

  /// Builds the main floating action button of the menu to the bottom right
  /// On clicking of which the menu toggles
  Widget _buildMenuButton(BuildContext context) {
    return Positioned(
      bottom: 10,
      right: 10,
      child: ScaleTransition(
        scale: _fabAnimation,
        child: FloatingActionButton(
          backgroundColor: widget.fabColor,
          onPressed: _toggleMenu,
          child: AnimatedIcon(
            icon: widget.icon ?? AnimatedIcons.menu_close,
            progress: _iconAnimationTween,
            color: widget.iconColor,
          ),
        ),
      ),
    );
  }
}

/// Builds widget for a single menu item
class _MenuItemWidget extends StatelessWidget {
  /// Contains details for a single menu item
  final HawkFabMenuItem item;

  /// A callback that toggles the menu
  final VoidCallback toggleMenu;

  const _MenuItemWidget({
    required this.item,
    required this.toggleMenu,
  });

  /// Closes the menu and calls the function for a particular menu item
  void onTap() {
    toggleMenu();
    item.ontap();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return InkWell(
      onTap: onTap,
      child: Row(
        children: <Widget>[
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: 10,
              vertical: 5,
            ),
            decoration: BoxDecoration(
              color: item.labelBackgroundColor ?? theme.colorScheme.primaryContainer,
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(10),
                bottomLeft: Radius.circular(10),
              ),
            ),
            child: Text(
              item.label,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(color: item.labelColor ?? theme.iconTheme.color),
            ),
          ),
          FloatingActionButton.small(
            onPressed: onTap,
            backgroundColor: item.color,
            materialTapTargetSize: MaterialTapTargetSize.padded,
            child: item.icon,
          ),
        ],
      ),
    );
  }
}

/// Model for single menu item
class HawkFabMenuItem {
  /// Text label for for the menu item
  String label;

  /// Corresponding icon for the menu item
  Icon icon;

  /// Action that is to be performed on tapping the menu item
  VoidCallback ontap;

  /// Background color for icon
  Color? color;

  /// Text color for label
  Color? labelColor;

  /// Background color for label
  Color? labelBackgroundColor;

  HawkFabMenuItem({
    required this.label,
    required this.ontap,
    required this.icon,
    this.color,
    this.labelBackgroundColor,
    this.labelColor,
  });
}
