import 'package:flutter/material.dart';
import 'package:minimal_jellyfin/view/widgets/top_buttons_bar.dart';
import 'package:window_manager/window_manager.dart';

class PageWrapper extends StatelessWidget {
  const PageWrapper({super.key, required this.child, this.onSettingsChanged});

  final Widget child;

  final VoidCallback? onSettingsChanged;

  @override
  Widget build(BuildContext context) {
    return DragToResizeArea(
      child: Container(
        padding: const EdgeInsets.all(0.1),
        child: Stack(
          children: [
            child,
            TopButtonsBar(
              onSettingsChanged: onSettingsChanged, // Pass a callback if needed
            ),
          ],
        ),
      ),
    );
  }
}
