import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

/// Persists property search queries with 7-day TTL.
/// Each entry is stored as { "text": string, "ts": milliseconds since epoch }.
class PropertySearchRecentService {
  PropertySearchRecentService._();

  static final PropertySearchRecentService _instance = PropertySearchRecentService._();
  factory PropertySearchRecentService() => _instance;

  static const String _key = 'property_recent_searches';
  static const int _maxEntries = 20;
  static const int _ttlDays = 7;

  static int get _ttlMs => _ttlDays * 24 * 60 * 60 * 1000;

  /// Returns recent search strings, newest first, excluding entries older than 7 days.
  Future<List<String>> getRecentSearches() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_key);
    if (raw == null || raw.isEmpty) return [];

    List<dynamic> list;
    try {
      list = jsonDecode(raw) as List<dynamic>;
    } catch (_) {
      return [];
    }

    final now = DateTime.now().millisecondsSinceEpoch;
    final valid = <Map<String, dynamic>>[];
    for (final e in list) {
      if (e is! Map<String, dynamic>) continue;
      final ts = e['ts'] as int?;
      if (ts == null) continue;
      if (now - ts > _ttlMs) continue;
      valid.add(e);
    }
    // Sort newest first
    valid.sort((a, b) => ((b['ts'] as int?) ?? 0).compareTo((a['ts'] as int?) ?? 0));
    return valid.map((e) => (e['text'] as String?) ?? '').where((s) => s.isNotEmpty).toList();
  }

  /// Appends a search query (or moves it to front if already present) and prunes old entries.
  Future<void> addRecentSearch(String query) async {
    final trimmed = query.trim();
    if (trimmed.isEmpty) return;

    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_key);
    List<Map<String, dynamic>> list = [];
    if (raw != null && raw.isNotEmpty) {
      try {
        final decoded = jsonDecode(raw) as List<dynamic>;
        for (final e in decoded) {
          if (e is Map<String, dynamic>) list.add(Map<String, dynamic>.from(e));
        }
      } catch (_) {}
    }

    final now = DateTime.now().millisecondsSinceEpoch;
    list.removeWhere((e) => (e['text'] as String?)?.trim() == trimmed);
    list.insert(0, {'text': trimmed, 'ts': now});

    // Prune by TTL and max count
    list = list.where((e) {
      final ts = e['ts'] as int? ?? 0;
      return now - ts <= _ttlMs;
    }).take(_maxEntries).toList();

    await prefs.setString(_key, jsonEncode(list));
  }

  Future<void> clearRecentSearches() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_key);
  }
}
