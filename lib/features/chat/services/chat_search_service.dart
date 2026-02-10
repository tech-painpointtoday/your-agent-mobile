import 'package:shared_preferences/shared_preferences.dart';

class ChatSearchService {
  static const String _recentSearchesKey = 'chat_recent_searches';
  static const int _maxRecentSearches = 5;

  Future<List<String>> getRecentSearches() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getStringList(_recentSearchesKey) ?? [];
  }

  Future<void> saveSearch(String query) async {
    if (query.trim().isEmpty) return;

    final prefs = await SharedPreferences.getInstance();
    final currentSearches = prefs.getStringList(_recentSearchesKey) ?? [];

    // Remove duplicates and add the new query to the beginning
    final updatedSearches = [
      query.trim(),
      ...currentSearches.where((s) => s != query.trim()),
    ];

    // Keep only the last N searches
    final limitedSearches = updatedSearches.take(_maxRecentSearches).toList();

    await prefs.setStringList(_recentSearchesKey, limitedSearches);
  }

  Future<void> clearRecentSearches() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_recentSearchesKey);
  }
}
