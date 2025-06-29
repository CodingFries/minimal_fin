/// Window controls and navigation bar that appears as an overlay at the top of the window.
/// 
/// This widget provides a hover-activated control bar that includes:
/// - Window management controls (minimize, maximize/restore, close)
/// - Settings navigation button
/// - Drag-to-move functionality for window positioning
/// - Smooth animations for show/hide behavior
/// 
/// The bar is designed to be unobtrusive, appearing only when the user hovers
/// over the top area of the window, maintaining a clean interface while
/// providing essential window controls for the frameless window design.

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:window_manager/window_manager.dart';

import '../routing/app_routes.dart';

/// A stateful widget that provides window controls and navigation in an overlay bar.
/// 
/// This widget creates a top overlay bar that becomes visible when the user hovers
/// over the top area of the window. It provides essential window management
/// functionality for the frameless window design, including:
/// 
/// - Settings button for navigation to configuration page
/// - Window minimize, maximize/restore, and close controls
/// - Drag-to-move areas for repositioning the window
/// - Smooth fade-in/out animations based on hover state
/// 
/// The bar is positioned absolutely at the top of the window and uses mouse
/// regions to detect hover events for showing/hiding the controls.
class TopButtonsBar extends StatefulWidget {
  /// Optional callback function triggered when returning from settings.
  /// 
  /// This callback is invoked when the user navigates back from the settings
  /// page, allowing parent widgets to refresh their content or state based
  /// on potential configuration changes.
  final VoidCallback? onSettingsChanged;

  /// Creates a top buttons bar with an optional settings change callback.
  /// 
  /// Parameters:
  ///   [onSettingsChanged] - Callback triggered when returning from settings
  const TopButtonsBar({super.key, this.onSettingsChanged});

  @override
  State<TopButtonsBar> createState() => _TopButtonsBarState();
}

/// State class for the TopButtonsBar widget managing hover animations and interactions.
/// 
/// This state class handles the hover detection and animation state for the
/// top buttons bar. It tracks whether the user is hovering over the top area
/// and triggers the appropriate show/hide animations for the control buttons.
class _TopButtonsBarState extends State<TopButtonsBar> {
  /// Tracks whether the user is currently hovering over the top area.
  /// 
  /// This boolean controls the visibility and opacity of the window controls.
  /// When true, the controls fade in and become interactive. When false,
  /// they fade out and become transparent.
  bool isHoveringTop = false;

  /// Builds the top buttons bar with hover-activated window controls.
  /// 
  /// The widget creates a responsive layout with three main sections:
  /// 1. Left drag area (70% width) - for window movement
  /// 2. Center control buttons - settings, minimize, maximize, close
  /// 3. Right drag area (30% width) - for window movement
  /// 
  /// All sections respond to hover events to show/hide the control buttons
  /// with smooth animations. The control buttons are only visible when
  /// hovering over the top area of the window.
  /// 
  /// Returns a positioned widget that overlays the top of the window.
  @override
  Widget build(BuildContext context) {
    return Positioned(
      top: 0,
      left: 0,
      right: 0,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            flex: 7,
            child: MouseRegion(
              onEnter: (_) => setState(() => isHoveringTop = true),
              onExit: (_) => setState(() => isHoveringTop = false),
              child: DragToMoveArea(
                child: IgnorePointer(
                  child: AnimatedContainer(
                    height: 20,
                    duration: const Duration(milliseconds: 200),
                    color: isHoveringTop ? Colors.black26 : Colors.transparent,
                  ),
                ),
              ),
            ),
          ),
          MouseRegion(
            onEnter: (_) => setState(() => isHoveringTop = true),
            onExit: (_) => setState(() => isHoveringTop = false),
            child: AnimatedOpacity(
              opacity: isHoveringTop ? 1.0 : 0.0,
              duration: const Duration(milliseconds: 200),
              child: DragToMoveArea(
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.vertical(
                      bottom: Radius.circular(8),
                    ),
                    color: Colors.black26,
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        onPressed: () async {
                          await context.push(AppRoutes.settings);
                          // Call the callback when returning from settings
                          if (widget.onSettingsChanged != null) {
                            widget.onSettingsChanged!();
                          }
                        },
                        icon: const Icon(Icons.settings),
                        tooltip: 'Settings',
                      ),
                      Container(
                        height: 20,
                        width: 1,
                        color: Colors.white.withAlpha(77),
                        margin: const EdgeInsets.symmetric(horizontal: 4),
                      ),
                      IconButton(
                        onPressed: () {
                          windowManager.minimize();
                        },
                        icon: const Icon(Icons.minimize),
                      ),
                      IconButton(
                        onPressed: () async {
                          if (await windowManager.isMaximized()) {
                            windowManager.unmaximize();
                          } else {
                            windowManager.maximize();
                          }
                        },
                        icon: const Icon(Icons.crop_square),
                      ),
                      IconButton(
                        onPressed: () {
                          windowManager.close();
                        },
                        icon: const Icon(Icons.close),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
          Expanded(
            flex: 3,
            child: MouseRegion(
              onEnter: (_) => setState(() => isHoveringTop = true),
              onExit: (_) => setState(() => isHoveringTop = false),
              child: DragToMoveArea(
                child: IgnorePointer(
                  child: AnimatedContainer(
                    height: 20,
                    duration: const Duration(milliseconds: 200),
                    color: isHoveringTop ? Colors.black26 : Colors.transparent,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
