import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../models/vault_entry.dart';
import '../models/vault_category.dart';
import '../theme/app_theme.dart';
import 'entry_editor_screen.dart';

class EntryDetailScreen extends StatefulWidget {
  final VaultEntry entry;
  const EntryDetailScreen({super.key, required this.entry});

  @override
  State<EntryDetailScreen> createState() => _EntryDetailScreenState();
}

class _EntryDetailScreenState extends State<EntryDetailScreen> {
  bool _revealed = false;

  @override
  Widget build(BuildContext context) {
    final e = widget.entry;
    final isSecret = e.category == VaultCategory.secret;
    final showRaw = !isSecret || _revealed;

    return Scaffold(
      backgroundColor: AppTheme.bg,
      appBar: AppBar(
        backgroundColor: AppTheme.bg,
        elevation: 0,
        title: Text('${e.category.emoji} ${e.category.label}'),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit_outlined),
            onPressed: () async {
              await Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => EntryEditorScreen(existing: e)),
              );
              if (mounted) Navigator.pop(context);
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(e.title, style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w600)),
            const SizedBox(height: 12),
            Expanded(
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: AppTheme.panel,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppTheme.border),
                ),
                child: SingleChildScrollView(
                  child: Text(
                    showRaw ? e.content : '•' * 20,
                    style: TextStyle(
                      color: Colors.white,
                      fontFamily: e.category == VaultCategory.code ? 'monospace' : null,
                      fontSize: 13,
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                if (isSecret)
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () => setState(() => _revealed = !_revealed),
                      icon: Icon(_revealed ? Icons.visibility_off : Icons.visibility, size: 18),
                      label: Text(_revealed ? 'Sembunyikan' : 'Tampilkan'),
                    ),
                  ),
                if (isSecret) const SizedBox(width: 8),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () async {
                      await Clipboard.setData(ClipboardData(text: e.content));
                      if (!mounted) return;
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Disalin ke clipboard')),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.accent,
                      foregroundColor: Colors.black,
                    ),
                    icon: const Icon(Icons.copy, size: 18),
                    label: const Text('Salin'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
