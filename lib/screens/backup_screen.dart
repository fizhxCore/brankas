import 'package:flutter/material.dart';
import '../services/vault_storage.dart';
import '../services/export_service.dart';
import '../theme/app_theme.dart';

class BackupScreen extends StatefulWidget {
  const BackupScreen({super.key});

  @override
  State<BackupScreen> createState() => _BackupScreenState();
}

class _BackupScreenState extends State<BackupScreen> {
  final _storage = VaultStorage();
  final _export = ExportService();
  final _restoreController = TextEditingController();
  bool _busy = false;
  String? _message;

  Future<void> _backup() async {
    setState(() {
      _busy = true;
      _message = null;
    });
    final raw = await _storage.rawJsonForBackup();
    await _export.backupJson(raw);
    if (mounted) setState(() => _busy = false);
  }

  Future<void> _restore() async {
    final text = _restoreController.text.trim();
    if (text.isEmpty) return;

    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppTheme.panel,
        title: const Text('Timpa data sekarang?', style: TextStyle(color: Colors.white)),
        content: const Text(
          'Data yang ada saat ini akan digantikan dengan isi backup yang ditempel.',
          style: TextStyle(color: AppTheme.muted),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Batal')),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Timpa', style: TextStyle(color: AppTheme.danger)),
          ),
        ],
      ),
    );
    if (confirm != true) return;

    setState(() {
      _busy = true;
      _message = null;
    });
    try {
      await _storage.restoreFromJson(text);
      if (mounted) {
        setState(() => _message = 'Data berhasil dipulihkan');
        _restoreController.clear();
      }
    } catch (_) {
      if (mounted) setState(() => _message = 'Teks backup tidak valid');
    }
    if (mounted) setState(() => _busy = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.bg,
      appBar: AppBar(backgroundColor: AppTheme.bg, elevation: 0, title: const Text('Backup & Restore')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: ListView(
          children: [
            if (_message != null) ...[
              Text(_message!, style: const TextStyle(color: AppTheme.accent)),
              const SizedBox(height: 12),
            ],
            const Text(
              'Backup menyimpan seluruh data brankas sebagai file JSON yang bisa disimpan di Drive, dikirim ke diri sendiri, dsb.',
              style: TextStyle(color: AppTheme.muted, fontSize: 12),
            ),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: _busy ? null : _backup,
              icon: const Icon(Icons.upload_outlined),
              label: const Text('Backup data (export JSON)'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.accent,
                foregroundColor: Colors.black,
                padding: const EdgeInsets.symmetric(vertical: 14),
              ),
            ),
            const SizedBox(height: 24),
            const Text(
              'Untuk restore: buka file backup .json (misal lewat app Files), salin semua isinya, lalu tempel di bawah ini.',
              style: TextStyle(color: AppTheme.muted, fontSize: 12),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _restoreController,
              maxLines: 6,
              style: const TextStyle(color: Colors.white, fontFamily: 'monospace', fontSize: 12),
              decoration: AppTheme.inputDecoration('Tempel isi JSON backup di sini'),
            ),
            const SizedBox(height: 12),
            OutlinedButton.icon(
              onPressed: _busy ? null : _restore,
              icon: const Icon(Icons.download_outlined),
              label: const Text('Restore dari teks'),
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 14),
                side: const BorderSide(color: AppTheme.border),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
