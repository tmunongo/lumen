import 'package:flutter/material.dart';
import 'package:lumen/domain/entities/artifact.dart';

class QuoteEditor extends StatefulWidget {
  final Artifact? existingQuote;
  final Function(
    String title,
    String content,
    String attribution,
    String? sourceUrl,
  )
  onSave;

  const QuoteEditor({this.existingQuote, required this.onSave, super.key});

  @override
  State<QuoteEditor> createState() => _QuoteEditorState();
}

class _QuoteEditorState extends State<QuoteEditor> {
  late final TextEditingController _titleController;
  late final TextEditingController _contentController;
  late final TextEditingController _attributionController;
  late final TextEditingController _sourceController;
  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(
      text: widget.existingQuote?.title ?? '',
    );
    _contentController = TextEditingController(
      text: widget.existingQuote?.content ?? '',
    );
    _attributionController = TextEditingController(
      text: widget.existingQuote?.attribution ?? '',
    );
    _sourceController = TextEditingController(
      text: widget.existingQuote?.sourceUrl ?? '',
    );
  }

  @override
  void dispose() {
    _titleController.dispose();
    _contentController.dispose();
    _attributionController.dispose();
    _sourceController.dispose();
    super.dispose();
  }

  void _save() {
    if (_formKey.currentState!.validate()) {
      widget.onSave(
        _titleController.text.trim(),
        _contentController.text.trim(),
        _attributionController.text.trim(),
        _sourceController.text.trim().isEmpty
            ? null
            : _sourceController.text.trim(),
      );
      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog.fullscreen(
      child: Scaffold(
        appBar: AppBar(
          title: Text(
            widget.existingQuote == null ? 'New Quote' : 'Edit Quote',
          ),
          actions: [TextButton(onPressed: _save, child: const Text('Save'))],
        ),
        body: Form(
          key: _formKey,
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                TextFormField(
                  controller: _titleController,
                  decoration: const InputDecoration(
                    labelText: 'Title',
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Title is required';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _contentController,
                  decoration: const InputDecoration(
                    labelText: 'Quote Text',
                    hintText: 'The quoted text...',
                    border: OutlineInputBorder(),
                    alignLabelWithHint: true,
                  ),
                  maxLines: 5,
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Quote text is required';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _attributionController,
                  decoration: const InputDecoration(
                    labelText: 'Attribution',
                    hintText: 'Author or source',
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Attribution is required';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _sourceController,
                  decoration: const InputDecoration(
                    labelText: 'Source URL (optional)',
                    hintText: 'https://...',
                    border: OutlineInputBorder(),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
