import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ProfileAvatarStore {
  static const String _storageKey = 'selected_profile_emoji';

  static const List<String> emojis = [
    '👨🏻',
    '👩🏻',
    '👨🏽',
    '👩🏽',
    '🧑🏻',
    '🧑🏽',
    '👨🏻‍💼',
    '👩🏻‍💼',
    '👨🏻‍🔧',
    '👩🏻‍🔧',
    '👨🏻‍🌾',
    '👩🏻‍🌾',
    '👨🏻‍🏫',
    '👩🏻‍🏫',
    '🤠',
  ];

  static final ValueNotifier<String> selectedEmoji = ValueNotifier<String>(
    '👨🏻',
  );

  static Future<void> load() async {
    final prefs = await SharedPreferences.getInstance();
    final saved = prefs.getString(_storageKey);

    if (saved != null && emojis.contains(saved)) {
      selectedEmoji.value = saved;
      return;
    }

    selectedEmoji.value = emojis.first;
  }

  static Future<void> select(String emoji) async {
    if (!emojis.contains(emoji)) {
      return;
    }

    selectedEmoji.value = emoji;

    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_storageKey, emoji);
  }
}
