import 'package:flutter/foundation.dart';

class ProfileAvatarStore {
  static const List<String> emojis = [
    '🙂',
    '😀',
    '😎',
    '🤓',
    '😊',
    '🧑‍💼',
    '👩‍💻',
    '👨‍💻',
    '🧑‍🌾',
    '🧑‍🔧',
    '👩‍🎨',
    '🧑‍🏫',
    '👨‍🍳',
    '🤠',
    '✨',
  ];

  static final ValueNotifier<String> selectedEmoji = ValueNotifier<String>(
    '🙂',
  );

  static void select(String emoji) {
    if (emojis.contains(emoji)) {
      selectedEmoji.value = emoji;
    }
  }
}
