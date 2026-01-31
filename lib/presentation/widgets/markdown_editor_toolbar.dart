import 'package:flutter/material.dart';

/// Toolbar for the markdown editor with formatting buttons.
///
/// Provides quick access to common markdown formatting like
/// bold, italic, headers, lists, code, and links.
class MarkdownEditorToolbar extends StatelessWidget {
  final TextEditingController controller;
  final FocusNode focusNode;
  final VoidCallback? onSave;
  final bool isDirty;

  const MarkdownEditorToolbar({
    required this.controller,
    required this.focusNode,
    this.onSave,
    this.isDirty = false,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: isDark ? Colors.grey[900] : Colors.grey[100],
        border: Border(
          top: BorderSide(
            color: isDark ? Colors.grey[800]! : Colors.grey[300]!,
          ),
        ),
      ),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: [
            // Text formatting
            _ToolbarButton(
              icon: Icons.format_bold,
              tooltip: 'Bold (Ctrl+B)',
              onPressed: () => _wrapSelection('**', '**'),
            ),
            _ToolbarButton(
              icon: Icons.format_italic,
              tooltip: 'Italic (Ctrl+I)',
              onPressed: () => _wrapSelection('_', '_'),
            ),
            _ToolbarButton(
              icon: Icons.strikethrough_s,
              tooltip: 'Strikethrough',
              onPressed: () => _wrapSelection('~~', '~~'),
            ),

            const _ToolbarDivider(),

            // Headers
            _ToolbarButton(
              icon: Icons.title,
              tooltip: 'Heading 1',
              onPressed: () => _prefixLine('# '),
            ),
            _ToolbarButton(
              icon: Icons.text_fields,
              tooltip: 'Heading 2',
              onPressed: () => _prefixLine('## '),
            ),
            _ToolbarButton(
              icon: Icons.format_size,
              tooltip: 'Heading 3',
              onPressed: () => _prefixLine('### '),
            ),

            const _ToolbarDivider(),

            // Lists
            _ToolbarButton(
              icon: Icons.format_list_bulleted,
              tooltip: 'Bullet List',
              onPressed: () => _prefixLine('- '),
            ),
            _ToolbarButton(
              icon: Icons.format_list_numbered,
              tooltip: 'Numbered List',
              onPressed: () => _prefixLine('1. '),
            ),
            _ToolbarButton(
              icon: Icons.check_box_outlined,
              tooltip: 'Task List',
              onPressed: () => _prefixLine('- [ ] '),
            ),

            const _ToolbarDivider(),

            // Code
            _ToolbarButton(
              icon: Icons.code,
              tooltip: 'Inline Code',
              onPressed: () => _wrapSelection('`', '`'),
            ),
            _ToolbarButton(
              icon: Icons.integration_instructions,
              tooltip: 'Code Block',
              onPressed: () => _insertCodeBlock(),
            ),

            const _ToolbarDivider(),

            // Other
            _ToolbarButton(
              icon: Icons.format_quote,
              tooltip: 'Blockquote',
              onPressed: () => _prefixLine('> '),
            ),
            _ToolbarButton(
              icon: Icons.link,
              tooltip: 'Link',
              onPressed: () => _insertLink(context),
            ),
            _ToolbarButton(
              icon: Icons.image,
              tooltip: 'Image',
              onPressed: () => _insertImage(context),
            ),
            _ToolbarButton(
              icon: Icons.horizontal_rule,
              tooltip: 'Horizontal Rule',
              onPressed: () => _insertText('\n\n---\n\n'),
            ),

            const SizedBox(width: 32),

            // Word count
            ValueListenableBuilder(
              valueListenable: controller,
              builder: (context, _, _) {
                final wordCount = _countWords(controller.text);
                return Text(
                  '$wordCount words',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurface.withValues(alpha: .5),
                  ),
                );
              },
            ),

            const SizedBox(width: 16),

            // Save button
            if (onSave != null)
              TextButton.icon(
                onPressed: isDirty ? onSave : null,
                icon: Icon(
                  Icons.save,
                  size: 18,
                  color: isDirty ? theme.colorScheme.primary : null,
                ),
                label: Text(isDirty ? 'Save' : 'Saved'),
              ),
          ],
        ),
      ),
    );
  }

  /// Wrap selected text with prefix and suffix
  void _wrapSelection(String prefix, String suffix) {
    final selection = controller.selection;
    final text = controller.text;

    if (!selection.isValid) {
      // No selection, just insert at cursor
      final newText = '$prefix$suffix';
      final position = selection.baseOffset;
      controller.text =
          text.substring(0, position) + newText + text.substring(position);
      controller.selection = TextSelection.collapsed(
        offset: position + prefix.length,
      );
    } else {
      // Wrap selection
      final selectedText = selection.textInside(text);
      final newText = '$prefix$selectedText$suffix';
      controller.text =
          text.substring(0, selection.start) +
          newText +
          text.substring(selection.end);
      controller.selection = TextSelection(
        baseOffset: selection.start + prefix.length,
        extentOffset: selection.start + prefix.length + selectedText.length,
      );
    }

    focusNode.requestFocus();
  }

  /// Prefix the current line with text
  void _prefixLine(String prefix) {
    final text = controller.text;
    final selection = controller.selection;

    // Find the start of the current line
    var lineStart = selection.baseOffset;
    while (lineStart > 0 && text[lineStart - 1] != '\n') {
      lineStart--;
    }

    controller.text =
        text.substring(0, lineStart) + prefix + text.substring(lineStart);
    controller.selection = TextSelection.collapsed(
      offset: selection.baseOffset + prefix.length,
    );

    focusNode.requestFocus();
  }

  /// Insert text at cursor position
  void _insertText(String insertText) {
    final selection = controller.selection;
    final text = controller.text;
    final position = selection.isValid ? selection.baseOffset : text.length;

    controller.text =
        text.substring(0, position) + insertText + text.substring(position);
    controller.selection = TextSelection.collapsed(
      offset: position + insertText.length,
    );

    focusNode.requestFocus();
  }

  /// Insert a code block
  void _insertCodeBlock() {
    final selection = controller.selection;

    if (!selection.isValid || selection.isCollapsed) {
      _insertText('\n```\n\n```\n');
      // Position cursor inside the code block
      controller.selection = TextSelection.collapsed(
        offset: selection.baseOffset + 5,
      );
    } else {
      _wrapSelection('\n```\n', '\n```\n');
    }
  }

  /// Insert a link with dialog
  Future<void> _insertLink(BuildContext context) async {
    final result = await showDialog<Map<String, String>>(
      context: context,
      builder: (context) => _LinkDialog(),
    );

    if (result != null) {
      final linkText = result['text'] ?? 'Link';
      final linkUrl = result['url'] ?? '';
      _insertText('[$linkText]($linkUrl)');
    }
  }

  /// Insert an image with dialog
  Future<void> _insertImage(BuildContext context) async {
    final result = await showDialog<Map<String, String>>(
      context: context,
      builder: (context) => _ImageDialog(),
    );

    if (result != null) {
      final altText = result['alt'] ?? 'Image';
      final imageUrl = result['url'] ?? '';
      _insertText('![$altText]($imageUrl)');
    }
  }

  int _countWords(String text) {
    if (text.trim().isEmpty) return 0;
    return text.trim().split(RegExp(r'\s+')).length;
  }
}

class _ToolbarButton extends StatelessWidget {
  final IconData icon;
  final String tooltip;
  final VoidCallback onPressed;

  const _ToolbarButton({
    required this.icon,
    required this.tooltip,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return IconButton(
      icon: Icon(icon, size: 20),
      tooltip: tooltip,
      onPressed: onPressed,
      splashRadius: 18,
      padding: const EdgeInsets.all(8),
      constraints: const BoxConstraints(minWidth: 36, minHeight: 36),
    );
  }
}

class _ToolbarDivider extends StatelessWidget {
  const _ToolbarDivider();

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 24,
      width: 1,
      margin: const EdgeInsets.symmetric(horizontal: 4),
      color: Theme.of(context).dividerColor,
    );
  }
}

class _LinkDialog extends StatefulWidget {
  @override
  State<_LinkDialog> createState() => _LinkDialogState();
}

class _LinkDialogState extends State<_LinkDialog> {
  final _textController = TextEditingController();
  final _urlController = TextEditingController();

  @override
  void dispose() {
    _textController.dispose();
    _urlController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Insert Link'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextField(
            controller: _textController,
            decoration: const InputDecoration(
              labelText: 'Link Text',
              hintText: 'Display text',
            ),
            autofocus: true,
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _urlController,
            decoration: const InputDecoration(
              labelText: 'URL',
              hintText: 'https://example.com',
            ),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        FilledButton(
          onPressed: () {
            Navigator.pop(context, {
              'text': _textController.text.isNotEmpty
                  ? _textController.text
                  : 'Link',
              'url': _urlController.text,
            });
          },
          child: const Text('Insert'),
        ),
      ],
    );
  }
}

class _ImageDialog extends StatefulWidget {
  @override
  State<_ImageDialog> createState() => _ImageDialogState();
}

class _ImageDialogState extends State<_ImageDialog> {
  final _altController = TextEditingController();
  final _urlController = TextEditingController();

  @override
  void dispose() {
    _altController.dispose();
    _urlController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Insert Image'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextField(
            controller: _altController,
            decoration: const InputDecoration(
              labelText: 'Alt Text',
              hintText: 'Image description',
            ),
            autofocus: true,
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _urlController,
            decoration: const InputDecoration(
              labelText: 'Image URL',
              hintText: 'https://example.com/image.png',
            ),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        FilledButton(
          onPressed: () {
            Navigator.pop(context, {
              'alt': _altController.text.isNotEmpty
                  ? _altController.text
                  : 'Image',
              'url': _urlController.text,
            });
          },
          child: const Text('Insert'),
        ),
      ],
    );
  }
}
