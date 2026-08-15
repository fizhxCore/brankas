import 'dart:convert';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import '../models/vault_entry.dart';

class VaultStorage {
  static const _fileName = 'brankas_data.json';

  Future<File> _getFile() async {
    final dir = await getApplicationDocumentsDirectory();
    return File('${dir.path}/$_fileName');
  }

  Future<List<VaultEntry>> loadEntries() async {
    try {
      final file = await _getFile();
      if (!await file.exists()) return [];
      final raw = await file.readAsString();
      if (raw.trim().isEmpty) return [];
      final List<dynamic> list = jsonDecode(raw);
      final entries = list.map((e) => VaultEntry.fromJson(e as Map<String, dynamic>)).toList();
      entries.sort((a, b) => b.createdAt.compareTo(a.createdAt));
      return entries;
    } catch (_) {
      return [];
    }
  }

  Future<void> saveEntries(List<VaultEntry> entries) async {
    final file = await _getFile();
    final raw = jsonEncode(entries.map((e) => e.toJson()).toList());
    await file.writeAsString(raw);
  }

  Future<String> rawJsonForBackup() async {
    final file = await _getFile();
    if (!await file.exists()) return '[]';
    return file.readAsString();
  }

  Future<void> restoreFromJson(String raw) async {
    final List<dynamic> list = jsonDecode(raw); // throws if invalid, caller handles
    final file = await _getFile();
    await file.writeAsString(jsonEncode(list));
  }
}
