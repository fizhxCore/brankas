import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import '../models/vault_entry.dart';
import '../models/vault_category.dart';
import '../services/vault_storage.dart';
import '../theme/app_theme.dart';

class EntryEditorScreen extends StatefulWidget {
  final VaultEntry? existing;
  const EntryEditorScreen({super.key, this.existing});

  @override
  State<EntryEditorScreen> createState() => _EntryEditorScreenState();
}

class _EntryEditorScreenState extends State<EntryEditorScreen> {
  final _storage = VaultStorage();
  late VaultCategory _category;
  late TextEditingController _titleController;
  late TextEditingController _contentController;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    _category = widget.existing?.category ?? VaultCategory.note;
    _titleController = TextEditingController(text: widget.existing?.title ?? '');
    _contentController = TextEditingController(text: widget.existing?.content ?? '');
  }

  Future<void> _save() async {
    if (_contentController.text.trim().isEmpty) return;
    setState(() => _saving = true);

    final entries = await _storage.loadEntries();
    final title = _titleController.text.trim().isEmpty
        ? _contentController.text.trim().split('\n').first
        : _titleController.text.trim();

    if (widget.existing != null) {
      final idx = entries.indexWhere((e) => e.id == widget.existing!.id);
      if (idx != -1) {
        entries[idx] = VaultEntry(
          id: widget.existing!.id,
          category: _category,
          title: title,
          content: _contentController.text.trim(),
          createdAt: widget.existing!.createdAt,
        );
      }
    } else {
      entries.add(VaultEntry(
        id: const Uuid().v4(),
        category: _category,
        title: title,
        content: _contentController.text.trim(),
        createdAt: DateTime.now().millisecondsSinceEpoch,
      ));
    }

    await _storage.saveEntries(entries);
    if (!mounted) return;
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.bg,
      appBar: AppBar(
        backgroundColor: AppTheme.bg,
        elevation: 0,
        title: Text(widget.existing != null ? 'Edit Item' : 'Item Baru'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: ListView(
          children: [
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                for (final c in VaultCategory.values)
                  ChoiceChip(
                    label: Text(
                      '${c.emoji} ${c.label}',
                      style: TextStyle(fontSize: 12, color: _category == c ? Colors.black : AppTheme.muted),
                    ),
                    selected: _category == c,
                    onSelected: (_) => setState(() => _category = c),
                    selectedColor: AppTheme.accent,
                    backgroundColor: AppTheme.panel,
                    side: const BorderSide(color: AppTheme.border),
                  ),
              ],
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _titleController,
              style: const TextStyle(color: Colors.white),
              decoration: AppTheme.inputDecoration('Judul (opsional)'),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _contentController,
              maxLines: _category == VaultCategory.link ? 1 : 8,
              style: TextStyle(
                color: Colors.white,
                fontFamily: _category == VaultCategory.code ? 'monospace' : null,
              ),
              decoration: AppTheme.inputDecoration(
                _category == VaultCategory.link ? 'https://...' : 'Isi',
              ),
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _saving ? null : _save,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.accent,
                  foregroundColor: Colors.black,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                ),
                child: Text(_saving ? 'Menyimpan...' : 'Simpan'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
