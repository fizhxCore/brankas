import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import '../models/vault_entry.dart';
import '../models/vault_category.dart';

class ExportService {
  Future<void> exportToTxt(List<VaultEntry> entries) async {
    final buffer = StringBuffer();
    buffer.writeln('BRANKAS - Export');
    buffer.writeln('Tanggal export: ${DateTime.now()}');
    buffer.writeln('Total entry: ${entries.length}');
    buffer.writeln('=' * 40);
    for (final e in entries) {
      buffer.writeln();
      buffer.writeln('${e.category.emoji} ${e.category.label} - ${e.title}');
      buffer.writeln('-' * 30);
      buffer.writeln(e.content);
    }

    final dir = await getTemporaryDirectory();
    final file = File('${dir.path}/brankas_export_${DateTime.now().millisecondsSinceEpoch}.txt');
    await file.writeAsString(buffer.toString());

    await Share.shareXFiles([XFile(file.path)], text: 'Export Brankas');
  }

  Future<void> backupJson(String rawJson) async {
    final dir = await getTemporaryDirectory();
    final file = File('${dir.path}/brankas_backup_${DateTime.now().millisecondsSinceEpoch}.json');
    await file.writeAsString(rawJson);
    await Share.shareXFiles([XFile(file.path)], text: 'Backup Brankas');
  }
}
