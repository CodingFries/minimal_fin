/// Common page layout wrapper providing consistent UI structure and window controls.
/// 
/// This widget serves as a wrapper for all main application pages, providing:
/// - Consistent layout structure with drag-to-resize functionality
/// - Overlay window controls (minimize, maximize, close, settings)
/// - Callback mechanism for handling settings changes
/// 
/// The wrapper uses a Stack layout to overlay the window controls on top of
/// the page content, ensuring they're always accessible regardless of the
/// underlying page content.

import 'package:flutter/material.dart';
import 'package:minimal_jellyfin/view/widgets/top_buttons_bar.dart';
import 'package:window_manager/window_manager.dart';

/// A wrapper widget that provides consistent layout and window controls for all pages.
/// 
/// This widget wraps page content with a standardized layout that includes:
/// - Drag-to-resize functionality for the entire window area
/// - Overlay window controls that appear on hover
/// - Settings change callback propagation
/// 
/// The wrapper is designed to be used by both the settings page and web view page
/// to ensure consistent user experience and window management across the application.
class PageWrapper extends StatelessWidget {
  /// Creates a page wrapper with the specified child widget and optional callback.
  /// 
  /// Parameters:
  ///   [child] - The main content widget to be wrapped
  ///   [onSettingsChanged] - Optional callback triggered when settings are modified
  const PageWrapper({super.key, required this.child, this.onSettingsChanged});

  /// The main content widget that will be displayed within the wrapper.
  /// 
  /// This widget forms the primary content of the page and is displayed
  /// underneath the overlay window controls.
  final Widget child;

  /// Optional callback function triggered when settings are changed.
  /// 
  /// This callback is passed through to the TopButtonsBar and is typically
  /// used to refresh page content when the user returns from the settings page.
  /// For example, the web view page uses this to reload with a new server URL.
  final VoidCallback? onSettingsChanged;

  /// Builds the page wrapper with drag-to-resize functionality and overlay controls.
  /// 
  /// The widget structure:
  /// - DragToResizeArea: Enables window resizing from any part of the window
  /// - Container: Provides minimal padding for visual consistency
  /// - Stack: Layers the child content with overlay controls
  /// - TopButtonsBar: Provides window controls and settings access
  /// 
  /// Returns a widget tree that wraps the child content with window management features.
  @override
  Widget build(BuildContext context) {
    return DragToResizeArea(
      child: Container(
        padding: const EdgeInsets.all(0.1),
        child: Stack(
          children: [
            // Main page content
            child,
            // Overlay window controls and settings button
            TopButtonsBar(
              onSettingsChanged: onSettingsChanged,
            ),
          ],
        ),
      ),
    );
  }
}
