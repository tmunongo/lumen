import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class KeyboardShortcuts {
  // Helper to create platform-specific shortcuts
  static bool get _isMacOS => Platform.isMacOS;
  
  static SingleActivator newProject = SingleActivator(
    LogicalKeyboardKey.keyN,
    meta: _isMacOS,
    control: !_isMacOS,
  );

  static SingleActivator newNote = SingleActivator(
    LogicalKeyboardKey.keyN,
    meta: _isMacOS,
    control: !_isMacOS,
    shift: true,
  );

  static SingleActivator search = SingleActivator(
    LogicalKeyboardKey.keyF,
    meta: _isMacOS,
    control: !_isMacOS,
  );

  static SingleActivator closeWindow = SingleActivator(
    LogicalKeyboardKey.keyW,
    meta: _isMacOS,
    control: !_isMacOS,
  );

  static SingleActivator openRelationships = SingleActivator(
    LogicalKeyboardKey.keyR,
    meta: _isMacOS,
    control: !_isMacOS,
  );

  static SingleActivator focusUrlInput = SingleActivator(
    LogicalKeyboardKey.keyL,
    meta: _isMacOS,
    control: !_isMacOS,
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
