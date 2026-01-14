import 'dart:io';

import 'package:desktop_drop/desktop_drop.dart';
import 'package:flutter/material.dart';

class DragDropArea extends StatefulWidget {
  final Widget child;
  final Function(List<File> files)? onFilesDropped;
  final Function(List<String> urls)? onUrlsDropped;

  const DragDropArea({
    required this.child,
    this.onFilesDropped,
    this.onUrlsDropped,
    super.key,
  });

  @override
  State<DragDropArea> createState() => _DragDropAreaState();
}

class _DragDropAreaState extends State<DragDropArea> {
  bool _isDragging = false;

  @override
  Widget build(BuildContext context) {
    return DropTarget(
      onDragEntered: (details) {
        setState(() => _isDragging = true);
      },
      onDragExited: (details) {
        setState(() => _isDragging = false);
      },
      onDragDone: (details) async {
        setState(() => _isDragging = false);

        // Handle file drops
        if (details.files.isNotEmpty && widget.onFilesDropped != null) {
          final files = details.files.map((xfile) => File(xfile.path)).toList();
          widget.onFilesDropped!(files);
        }

        // TODO: Handle URL drops (from browser, etc.)
        // final urls = details.urls;
        // if (urls.isNotEmpty && widget.onUrlsDropped != null) {
        //   widget.onUrlsDropped!(urls);
        // }
      },
      child: Stack(
        children: [
          widget.child,
          if (_isDragging)
            Positioned.fill(
              child: Container(
                decoration: BoxDecoration(
                  color: Theme.of(
                    context,
                  ).colorScheme.primary.withValues(alpha: 0.1),
                  border: Border.all(
                    color: Theme.of(context).colorScheme.primary,
                    width: 2,
                  ),
                ),
                child: Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.file_download,
                        size: 64,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'Drop here to add',
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          color: Theme.of(context).colorScheme.primary,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
