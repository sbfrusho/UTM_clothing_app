import 'package:shared_preferences/shared_preferences.dart';

/// Recent search terms, stored on this device only.
class SearchHistoryRepository {
  static const _key = 'recent_searches';
  static const maxItems = 8;

  Future<List<String>> load() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getStringList(_key) ?? const [];
    } catch (_) {
      return const [];
    }
  }

  /// Moves [term] to the front, de-duplicated case-insensitively.
  Future<List<String>> add(String term) async {
    final t = term.trim();
    if (t.isEmpty) return load();
    final next = [
      t,
      ...(await load()).where((e) => e.toLowerCase() != t.toLowerCase()),
    ].take(maxItems).toList();
    await _save(next);
    return next;
  }

  Future<List<String>> remove(String term) async {
    final next = (await load()).where((e) => e != term).toList();
    await _save(next);
    return next;
  }

  Future<void> clear() => _save(const []);

  Future<void> _save(List<String> items) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setStringList(_key, items);
    } catch (_) {
      // History is a convenience; ignore storage failures.
    }
  }
}
