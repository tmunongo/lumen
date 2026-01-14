import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class KeyboardShortcuts {
  static const newProject = SingleActivator(
    LogicalKeyboardKey.keyN,
    meta: true, // Command on macOS
    control: true, // Ctrl on Windows/Linux
  );

  static const newNote = SingleActivator(
    LogicalKeyboardKey.keyN,
    meta: true,
    control: true,
    shift: true,
  );

  static const search = SingleActivator(
    LogicalKeyboardKey.keyF,
    meta: true,
    control: true,
  );

  static const closeWindow = SingleActivator(
    LogicalKeyboardKey.keyW,
    meta: true,
    control: true,
  );

  static const openRelationships = SingleActivator(
    LogicalKeyboardKey.keyR,
    meta: true,
    control: true,
  );

  static const focusUrlInput = SingleActivator(
    LogicalKeyboardKey.keyL,
    meta: true,
    control: true,
  );
}

class ShortcutScope extends StatelessWidget {
  final Map<ShortcutActivator, VoidCallback> shortcuts;
  final Widget child;

  const ShortcutScope({
    required this.shortcuts,
    required this.child,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Shortcuts(
      shortcuts: {
        for (final entry in shortcuts.entries)
          entry.key: VoidCallbackIntent(entry.value),
      },
      child: Actions(
        actions: {
          VoidCallbackIntent: CallbackAction<VoidCallbackIntent>(
            onInvoke: (intent) => intent.callback(),
          ),
        },
        child: Focus(autofocus: true, child: child),
      ),
    );
  }
}

class VoidCallbackIntent extends Intent {
  final VoidCallback callback;
  const VoidCallbackIntent(this.callback);
}
