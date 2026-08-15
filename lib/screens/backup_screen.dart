import 'dart:io';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
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
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['json'],
    );
    if (result == null || result.files.single.path == null) return;

    if (!mounted) return;
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppTheme.panel,
        title: const Text('Timpa data sekarang?', style: TextStyle(color: Colors.white)),
        content: const Text(
          'Data yang ada saat ini akan digantikan dengan isi file backup ini.',
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
      final raw = await File(result.files.single.path!).readAsString();
      await _storage.restoreFromJson(raw);
      if (mounted) setState(() => _message = 'Data berhasil dipulihkan');
    } catch (_) {
      if (mounted) setState(() => _message = 'File backup tidak valid');
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
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
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
            const SizedBox(height: 12),
            OutlinedButton.icon(
              onPressed: _busy ? null : _restore,
              icon: const Icon(Icons.download_outlined),
              label: const Text('Restore dari file backup'),
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
