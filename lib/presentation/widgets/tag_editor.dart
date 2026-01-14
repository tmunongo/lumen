import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lumen/application/providers.dart';
import 'package:lumen/domain/entities/tag.dart';

class TagEditor extends ConsumerStatefulWidget {
  final int projectId;
  final List<String> initialTags;
  final Function(List<String> tags) onSave;

  const TagEditor({
    required this.projectId,
    required this.initialTags,
    required this.onSave,
    super.key,
  });

  @override
  ConsumerState<TagEditor> createState() => _TagEditorState();
}

class _TagEditorState extends ConsumerState<TagEditor> {
  late Set<String> _selectedTags;
  final _controller = TextEditingController();
  String _filter = '';

  @override
  void initState() {
    super.initState();
    _selectedTags = Set.from(widget.initialTags);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _toggleTag(String tag) {
    setState(() {
      if (_selectedTags.contains(tag)) {
        _selectedTags.remove(tag);
      } else {
        _selectedTags.add(tag);
      }
    });
  }

  void _createNewTag() {
    final newTag = _controller.text.trim().toLowerCase();
    if (newTag.isEmpty) return;

    setState(() {
      _selectedTags.add(newTag);
      _controller.clear();
    });
  }

  void _save() {
    widget.onSave(_selectedTags.toList());
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final tagRepo = ref.watch(tagRepositoryProvider);

    return Dialog(
      child: Container(
        constraints: const BoxConstraints(maxWidth: 600, maxHeight: 700),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Header
            Padding(
              padding: const EdgeInsets.all(24),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Manage Tags',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                ],
              ),
            ),

            const Divider(height: 1),

            // Selected tags section
            if (_selectedTags.isNotEmpty) ...[
              Padding(
                padding: const EdgeInsets.fromLTRB(24, 16, 24, 8),
                child: Row(
                  children: [
                    Text(
                      'Selected (${_selectedTags.length})',
                      style: Theme.of(context).textTheme.titleSmall,
                    ),
                    const Spacer(),
                    TextButton.icon(
                      onPressed: () {
                        setState(() => _selectedTags.clear());
                      },
                      icon: const Icon(Icons.clear_all, size: 16),
                      label: const Text('Clear all'),
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(24, 0, 24, 16),
                child: Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: _selectedTags.map((tag) {
                    return Chip(
                      label: Text(tag),
                      onDeleted: () => _toggleTag(tag),
                      deleteIcon: const Icon(Icons.close, size: 18),
                      backgroundColor: Theme.of(
                        context,
                      ).colorScheme.primaryContainer,
                    );
                  }).toList(),
                ),
              ),
              const Divider(height: 1),
            ],

            // New tag input
            Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _controller,
                      decoration: InputDecoration(
                        hintText: 'Create new tag...',
                        prefixIcon: const Icon(Icons.add),
                        border: const OutlineInputBorder(),
                        suffixIcon: _controller.text.isNotEmpty
                            ? IconButton(
                                icon: const Icon(Icons.clear),
                                onPressed: () {
                                  _controller.clear();
                                  setState(() {});
                                },
                              )
                            : null,
                      ),
                      onSubmitted: (_) => _createNewTag(),
                      onChanged: (value) => setState(() {}),
                    ),
                  ),
                  const SizedBox(width: 8),
                  IconButton.filled(
                    icon: const Icon(Icons.add),
                    onPressed: _controller.text.trim().isEmpty
                        ? null
                        : _createNewTag,
                  ),
                ],
              ),
            ),

            // Search/filter
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
              child: TextField(
                decoration: const InputDecoration(
                  hintText: 'Filter existing tags...',
                  prefixIcon: Icon(Icons.search),
                  border: OutlineInputBorder(),
                ),
                onChanged: (value) {
                  setState(() => _filter = value.toLowerCase());
                },
              ),
            ),

            // Existing tags list
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 0, 24, 8),
              child: Text(
                'Available tags in project',
                style: Theme.of(context).textTheme.titleSmall,
              ),
            ),

            Expanded(
              child: FutureBuilder<List<Tag>>(
                future: tagRepo.findByProject(widget.projectId),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  if (!snapshot.hasData || snapshot.data!.isEmpty) {
                    return Center(
                      child: Padding(
                        padding: const EdgeInsets.all(32),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.label_outline,
                              size: 48,
                              color: Theme.of(context).hintColor,
                            ),
                            const SizedBox(height: 16),
                            Text(
                              'No existing tags yet',
                              style: Theme.of(context).textTheme.bodyLarge
                                  ?.copyWith(
                                    color: Theme.of(context).hintColor,
                                  ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Create your first tag above',
                              style: Theme.of(context).textTheme.bodySmall
                                  ?.copyWith(
                                    color: Theme.of(context).hintColor,
                                  ),
                            ),
                          ],
                        ),
                      ),
                    );
                  }

                  var tags = snapshot.data!;

                  // Apply filter
                  if (_filter.isNotEmpty) {
                    tags = tags
                        .where((tag) => tag.name.contains(_filter))
                        .toList();
                  }

                  if (tags.isEmpty) {
                    return Center(
                      child: Padding(
                        padding: const EdgeInsets.all(32),
                        child: Text(
                          'No tags match "$_filter"',
                          style: Theme.of(context).textTheme.bodyLarge
                              ?.copyWith(color: Theme.of(context).hintColor),
                        ),
                      ),
                    );
                  }

                  return ListView.separated(
                    padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                    itemCount: tags.length,
                    separatorBuilder: (context, index) => const Divider(height: 1),
                    itemBuilder: (context, index) {
                      final tag = tags[index];
                      final isSelected = _selectedTags.contains(tag.name);

                      return ListTile(
                        leading: Icon(
                          isSelected
                              ? Icons.check_box
                              : Icons.check_box_outline_blank,
                          color: isSelected
                              ? Theme.of(context).colorScheme.primary
                              : null,
                        ),
                        title: Text(tag.name),
                        trailing: Chip(
                          label: Text('${tag.usageCount}'),
                          visualDensity: VisualDensity.compact,
                          // tooltip:
                          //     'Used ${tag.usageCount} time${tag.usageCount == 1 ? '' : 's'}',
                        ),
                        onTap: () => _toggleTag(tag.name),
                        selected: isSelected,
                      );
                    },
                  );
                },
              ),
            ),

            const Divider(height: 1),

            // Footer with save button
            Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: () => Navigator.of(context).pop(),
                    child: const Text('Cancel'),
                  ),
                  const SizedBox(width: 8),
                  FilledButton(onPressed: _save, child: const Text('Save')),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
