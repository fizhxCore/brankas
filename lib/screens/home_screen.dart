import 'package:flutter/material.dart';
import '../models/vault_entry.dart';
import '../models/vault_category.dart';
import '../services/vault_storage.dart';
import '../services/auth_service.dart';
import '../services/export_service.dart';
import '../theme/app_theme.dart';
import 'login_screen.dart';
import 'entry_editor_screen.dart';
import 'entry_detail_screen.dart';
import 'backup_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final _storage = VaultStorage();
  final _auth = AuthService();
  final _export = ExportService();
  List<VaultEntry> _entries = [];
  String _query = '';
  VaultCategory? _filter;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    final entries = await _storage.loadEntries();
    if (!mounted) return;
    setState(() {
      _entries = entries;
      _loading = false;
    });
  }

  List<VaultEntry> get _filtered {
    return _entries.where((e) {
      final matchesCategory = _filter == null || e.category == _filter;
      final q = _query.toLowerCase();
      final matchesQuery =
          q.isEmpty || e.title.toLowerCase().contains(q) || e.content.toLowerCase().contains(q);
      return matchesCategory && matchesQuery;
    }).toList();
  }

  Future<void> _delete(VaultEntry entry) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppTheme.panel,
        title: const Text('Hapus item?', style: TextStyle(color: Colors.white)),
        content: Text('"${entry.title}" akan dihapus permanen.', style: const TextStyle(color: AppTheme.muted)),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Batal')),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Hapus', style: TextStyle(color: AppTheme.danger)),
          ),
        ],
      ),
    );
    if (confirm != true) return;
    _entries.removeWhere((e) => e.id == entry.id);
    await _storage.saveEntries(_entries);
    _load();
  }

  Future<void> _logout() async {
    await _auth.logout();
    if (!mounted) return;
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (_) => const LoginScreen()),
      (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.bg,
      appBar: AppBar(
        backgroundColor: AppTheme.bg,
        elevation: 0,
        title: const Text('BRANKAS', style: TextStyle(fontWeight: FontWeight.w700, letterSpacing: 2, fontSize: 18)),
        actions: [
          PopupMenuButton<String>(
            color: AppTheme.panel,
            icon: const Icon(Icons.more_vert),
            onSelected: (value) async {
              if (value == 'export') {
                await _export.exportToTxt(_filtered);
              } else if (value == 'backup') {
                await Navigator.push(context, MaterialPageRoute(builder: (_) => const BackupScreen()));
                _load();
              } else if (value == 'logout') {
                _logout();
              }
            },
            itemBuilder: (ctx) => const [
              PopupMenuItem(value: 'export', child: Text('Export ke TXT')),
              PopupMenuItem(value: 'backup', child: Text('Backup & Restore')),
              PopupMenuItem(value: 'logout', child: Text('Keluar')),
            ],
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
            child: TextField(
              onChanged: (v) => setState(() => _query = v),
              style: const TextStyle(color: Colors.white),
              decoration: AppTheme.inputDecoration('Cari...').copyWith(
                prefixIcon: const Icon(Icons.search, color: AppTheme.muted),
              ),
            ),
          ),
          SizedBox(
            height: 40,
            child: ListView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              children: [
                _buildFilterChip(null, 'Semua'),
                for (final c in VaultCategory.values) _buildFilterChip(c, '${c.emoji} ${c.label}'),
              ],
            ),
          ),
          const SizedBox(height: 8),
          Expanded(
            child: _loading
                ? const Center(child: CircularProgressIndicator(color: AppTheme.accent))
                : _filtered.isEmpty
                    ? Center(
                        child: Text(
                          _entries.isEmpty ? 'Brankas masih kosong' : 'Tidak ada yang cocok',
                          style: const TextStyle(color: AppTheme.muted),
                        ),
                      )
                    : ListView.builder(
                        padding: const EdgeInsets.fromLTRB(16, 0, 16, 80),
                        itemCount: _filtered.length,
                        itemBuilder: (ctx, i) {
                          final e = _filtered[i];
                          return _EntryCard(
                            entry: e,
                            onTap: () async {
                              await Navigator.push(
                                context,
                                MaterialPageRoute(builder: (_) => EntryDetailScreen(entry: e)),
                              );
                              _load();
                            },
                            onDelete: () => _delete(e),
                          );
                        },
                      ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: AppTheme.accent,
        foregroundColor: Colors.black,
        onPressed: () async {
          await Navigator.push(context, MaterialPageRoute(builder: (_) => const EntryEditorScreen()));
          _load();
        },
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildFilterChip(VaultCategory? category, String label) {
    final selected = _filter == category;
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: ChoiceChip(
        label: Text(label, style: TextStyle(fontSize: 12, color: selected ? Colors.black : AppTheme.muted)),
        selected: selected,
        onSelected: (_) => setState(() => _filter = category),
        selectedColor: AppTheme.accent,
        backgroundColor: AppTheme.panel,
        side: const BorderSide(color: AppTheme.border),
      ),
    );
  }
}

class _EntryCard extends StatefulWidget {
  final VaultEntry entry;
  final VoidCallback onTap;
  final VoidCallback onDelete;

  const _EntryCard({required this.entry, required this.onTap, required this.onDelete});

  @override
  State<_EntryCard> createState() => _EntryCardState();
}

class _EntryCardState extends State<_EntryCard> {
  bool _revealed = false;

  @override
  Widget build(BuildContext context) {
    final e = widget.entry;
    final isSecret = e.category == VaultCategory.secret;
    final preview = isSecret && !_revealed
        ? '•' * 12
        : (e.content.length > 60 ? '${e.content.substring(0, 60)}...' : e.content);

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: AppTheme.panel,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppTheme.border),
      ),
      child: ListTile(
        onTap: widget.onTap,
        leading: Text(e.category.emoji, style: const TextStyle(fontSize: 20)),
        title: Text(
          e.title,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(color: Colors.white, fontSize: 14),
        ),
        subtitle: Text(
          preview,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(color: AppTheme.muted, fontSize: 12, fontFamily: 'monospace'),
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (isSecret)
              IconButton(
                icon: Icon(_revealed ? Icons.visibility_off : Icons.visibility, size: 18, color: AppTheme.muted),
                onPressed: () => setState(() => _revealed = !_revealed),
              ),
            IconButton(
              icon: const Icon(Icons.delete_outline, size: 18, color: AppTheme.muted),
              onPressed: widget.onDelete,
            ),
          ],
        ),
      ),
    );
  }
}
