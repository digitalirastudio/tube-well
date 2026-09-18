import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tube_well/core/profile_avatar.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    await ProfileAvatarStore.load();
  });

  test('selected emoji is saved and restored across app restarts', () async {
    final prefs = await SharedPreferences.getInstance();

    ProfileAvatarStore.select('👩🏽');

    expect(ProfileAvatarStore.selectedEmoji.value, '👩🏽');
    expect(prefs.getString('selected_profile_emoji'), '👩🏽');

    await prefs.setString('selected_profile_emoji', '👨🏻‍💼');
    await ProfileAvatarStore.load();

    expect(ProfileAvatarStore.selectedEmoji.value, '👨🏻‍💼');
  });
}
