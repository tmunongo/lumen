import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_markdown_plus/flutter_markdown_plus.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lumen/application/providers.dart';
import 'package:lumen/domain/entities/markdown_document.dart';
import 'package:lumen/presentation/theme/reader_theme.dart';
import 'package:lumen/presentation/widgets/markdown_editor_toolbar.dart';
import 'package:url_launcher/url_launcher.dart';

class MarkdownEditorScreen extends ConsumerStatefulWidget {
  final MarkdownDocument document;
  final bool isNewDocument;
  final VoidCallback? onBack;

  const MarkdownEditorScreen({
    required this.document,
    this.isNewDocument = false,
    this.onBack,
    super.key,
  });

  @override
  ConsumerState<MarkdownEditorScreen> createState() =>
      _MarkdownEditorScreenState();
}

class _MarkdownEditorScreenState extends ConsumerState<MarkdownEditorScreen> {
  late TextEditingController _contentController;
  late TextEditingController _titleController;
  late FocusNode _editorFocusNode;
  late MarkdownDocument _document;

  bool _showPreview = true;
  bool _isDirty = false;
  bool _isSaving = false;
  Timer? _autoSaveTimer;
  Timer? _previewDebounceTimer;

  String _previewContent = ''; // Cached preview content

  static const _autoSaveDelay = Duration(seconds: 3);
  static const _previewDebounceDelay = Duration(milliseconds: 300);

  @override
  void initState() {
    super.initState();
    _document = widget.document;
    _contentController = TextEditingController(text: _document.content);
    _titleController = TextEditingController(text: _document.title);
    _editorFocusNode = FocusNode();
    _previewContent = _document.content;

    _contentController.addListener(_onContentChanged);
    _titleController.addListener(_onTitleChanged);
  }

  @override
  void dispose() {
    _autoSaveTimer?.cancel();
    _previewDebounceTimer?.cancel();
    _contentController.removeListener(_onContentChanged);
    _titleController.removeListener(_onTitleChanged);
    _contentController.dispose();
    _titleController.dispose();
    _editorFocusNode.dispose();
    super.dispose();
  }

  void _onContentChanged() {
    if (_contentController.text != _document.content) {
      setState(() {
        _isDirty = true;
      });
      _scheduleAutoSave();
      _schedulePreviewUpdate();
    }
  }

  void _onTitleChanged() {
    if (_titleController.text != _document.title) {
      setState(() {
        _isDirty = true;
      });
      _scheduleAutoSave();
    }
  }

  void _scheduleAutoSave() {
    _autoSaveTimer?.cancel();
    _autoSaveTimer = Timer(_autoSaveDelay, _save);
  }

  void _schedulePreviewUpdate() {
    _previewDebounceTimer?.cancel();
    _previewDebounceTimer = Timer(_previewDebounceDelay, () {
      if (mounted) {
        setState(() {
          _previewContent = _contentController.text;
        });
      }
    });
  }

  Future<void> _save() async {
    if (!_isDirty || _isSaving) return;

    setState(() {
      _isSaving = true;
    });

    try {
      final service = ref.read(markdownServiceProvider);

      _document = _document.copyWith(
        title: _titleController.text.trim(),
        content: _contentController.text,
      );

      _document = await service.saveDocument(_document);
      ref.invalidate(projectMarkdownDocumentsProvider(_document.projectId));

      if (mounted) {
        setState(() {
          _isDirty = false;
          _isSaving = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isSaving = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to save: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final isWideScreen = MediaQuery.of(context).size.width > 800;

    return Theme(
      data: isDark
          ? ReaderTheme.darkReaderTheme()
          : ReaderTheme.lightReaderTheme(),
      child: PopScope(
        canPop: !_isDirty,
        onPopInvokedWithResult: (didPop, result) async {
          if (!didPop && _isDirty) {
            await _save();
            if (mounted) {
              Navigator.of(context).pop();
            }
          }
        },
        child: CallbackShortcuts(
          bindings: {
            const SingleActivator(LogicalKeyboardKey.keyB, control: true): () =>
                _insertFormatting('**', '**'),
            const SingleActivator(LogicalKeyboardKey.keyI, control: true): () =>
                _insertFormatting('_', '_'),
            const SingleActivator(LogicalKeyboardKey.keyS, control: true):
                _save,
          },
          child: Focus(
            autofocus: false,
            child: Scaffold(
              appBar: _buildAppBar(isDark),
              body: Column(
                children: [
                  Expanded(
                    child: isWideScreen
                        ? _buildSplitView(isDark)
                        : _showPreview
                        ? _buildPreviewOnly(isDark)
                        : _buildEditorOnly(isDark),
                  ),
                  MarkdownEditorToolbar(
                    controller: _contentController,
                    focusNode: _editorFocusNode,
                    onSave: _save,
                    isDirty: _isDirty,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  PreferredSizeWidget _buildAppBar(bool isDark) {
    return AppBar(
      leading: IconButton(
        icon: const Icon(Icons.arrow_back),
        onPressed: () async {
          if (_isDirty) {
            await _save();
          }
          if (mounted) {
            if (widget.onBack != null) {
              widget.onBack!();
            } else {
              Navigator.of(context).pop();
            }
          }
        },
      ),
      title: SizedBox(
        width: 300,
        child: TextField(
          controller: _titleController,
          decoration: InputDecoration(
            border: InputBorder.none,
            hintText: 'Untitled Document',
            hintStyle: TextStyle(
              color: isDark
                  ? ReaderTheme.darkTextSecondary
                  : ReaderTheme.lightTextSecondary,
            ),
          ),
          style: Theme.of(context).textTheme.titleLarge,
        ),
      ),
      actions: [
        if (_isDirty)
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 8),
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: Colors.orange.withOpacity(0.2),
              borderRadius: BorderRadius.circular(4),
            ),
            child: Text(
              _isSaving ? 'Saving...' : 'Unsaved',
              style: TextStyle(color: Colors.orange[700], fontSize: 12),
            ),
          ),
        if (MediaQuery.of(context).size.width <= 800)
          IconButton(
            icon: Icon(_showPreview ? Icons.edit : Icons.visibility),
            tooltip: _showPreview ? 'Edit' : 'Preview',
            onPressed: () {
              setState(() {
                _showPreview = !_showPreview;
                if (_showPreview) {
                  _previewContent = _contentController.text;
                }
              });
            },
          ),
        PopupMenuButton(
          itemBuilder: (context) => [
            const PopupMenuItem(
              value: 'save',
              child: ListTile(
                leading: Icon(Icons.save),
                title: Text('Save'),
                contentPadding: EdgeInsets.zero,
              ),
            ),
            const PopupMenuItem(
              value: 'export',
              child: ListTile(
                leading: Icon(Icons.file_download),
                title: Text('Export'),
                contentPadding: EdgeInsets.zero,
              ),
            ),
          ],
          onSelected: (value) {
            switch (value) {
              case 'save':
                _save();
                break;
              case 'export':
                // TODO: Implement export
                break;
            }
          },
        ),
      ],
    );
  }

  Widget _buildSplitView(bool isDark) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Expanded(child: _buildEditor(isDark)),
        Container(
          width: 1,
          color: isDark ? ReaderTheme.darkBorder : ReaderTheme.lightBorder,
        ),
        Expanded(child: _buildPreview(isDark)),
      ],
    );
  }

  Widget _buildEditorOnly(bool isDark) {
    return _buildEditor(isDark);
  }

  Widget _buildPreviewOnly(bool isDark) {
    return _buildPreview(isDark);
  }

  Widget _buildEditor(bool isDark) {
    return Container(
      color: isDark ? ReaderTheme.darkBackground : ReaderTheme.lightBackground,
      child: TextField(
        controller: _contentController,
        focusNode: _editorFocusNode,
        maxLines: null,
        expands: true,
        decoration: InputDecoration(
          border: InputBorder.none,
          contentPadding: const EdgeInsets.all(24),
          hintText: 'Start writing...',
          hintStyle: TextStyle(
            color: isDark
                ? ReaderTheme.darkTextSecondary
                : ReaderTheme.lightTextSecondary,
          ),
        ),
        style: TextStyle(
          fontFamily: 'monospace',
          fontSize: 14,
          height: 1.6,
          color: isDark ? ReaderTheme.darkText : ReaderTheme.lightText,
        ),
        textAlignVertical: TextAlignVertical.top,
      ),
    );
  }

  Widget _buildPreview(bool isDark) {
    return Container(
      color: isDark ? ReaderTheme.darkBackground : ReaderTheme.lightBackground,
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: MarkdownBody(
          data: _previewContent,
          selectable: true,
          styleSheet: MarkdownStyleSheet(
            h1: Theme.of(context).textTheme.displayLarge,
            h2: Theme.of(context).textTheme.displayMedium,
            h3: Theme.of(context).textTheme.displaySmall,
            p: Theme.of(context).textTheme.bodyLarge?.copyWith(height: 1.8),
            code: TextStyle(
              fontFamily: 'monospace',
              backgroundColor: isDark ? Colors.grey[850] : Colors.grey[200],
              fontSize: 13,
            ),
            codeblockDecoration: BoxDecoration(
              color: isDark ? Colors.grey[850] : Colors.grey[200],
              borderRadius: BorderRadius.circular(8),
            ),
            blockquoteDecoration: BoxDecoration(
              border: Border(
                left: BorderSide(
                  color: isDark
                      ? ReaderTheme.darkAccent
                      : ReaderTheme.lightAccent,
                  width: 4,
                ),
              ),
            ),
            blockquotePadding: const EdgeInsets.only(left: 16),
            listBullet: Theme.of(context).textTheme.bodyLarge,
          ),
          onTapLink: (text, href, title) {
            if (href != null) {
              launchUrl(Uri.parse(href));
            }
          },
        ),
      ),
    );
  }

  void _insertFormatting(String prefix, String suffix) {
    final selection = _contentController.selection;
    final text = _contentController.text;

    if (!selection.isValid) return;

    if (selection.isCollapsed) {
      final newText = '$prefix$suffix';
      _contentController.text =
          text.substring(0, selection.baseOffset) +
          newText +
          text.substring(selection.baseOffset);
      _contentController.selection = TextSelection.collapsed(
        offset: selection.baseOffset + prefix.length,
      );
    } else {
      final selectedText = selection.textInside(text);
      final newText = '$prefix$selectedText$suffix';
      _contentController.text =
          text.substring(0, selection.start) +
          newText +
          text.substring(selection.end);
      _contentController.selection = TextSelection(
        baseOffset: selection.start + prefix.length,
        extentOffset: selection.start + prefix.length + selectedText.length,
      );
    }
  }
}
