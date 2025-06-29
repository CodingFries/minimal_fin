import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:window_manager/window_manager.dart';

import '../routing/app_routes.dart';

class TopButtonsBar extends StatefulWidget {
  final VoidCallback? onSettingsChanged;

  const TopButtonsBar({super.key, this.onSettingsChanged});

  @override
  State<TopButtonsBar> createState() => _TopButtonsBarState();
}

class _TopButtonsBarState extends State<TopButtonsBar> {
  bool isHoveringTop = false;

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
