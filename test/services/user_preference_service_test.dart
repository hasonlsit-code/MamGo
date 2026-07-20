import 'package:flutter_test/flutter_test.dart';
import 'package:mamgo/domain/entities/user_preference_entity.dart';
import 'package:mamgo/domain/interface_repositories/ipreference_repository.dart';
import 'package:mamgo/domain/service/user_preference_service.dart';

class MockPreferenceRepository implements IPreferenceRepository {
  UserPreference? savedPreference;
  String? savedEmail;

  @override
  Future<void> save(UserPreference pref, String email) async {
    savedPreference = pref;
    savedEmail = email;
  }

  @override
  Future<UserPreference?> load(String email) async {
    return null;
  }

  @override
  Future<bool> isOnboardingDone(String email) async {
    return true;
  }
}

void main() {
  late MockPreferenceRepository mockRepo;
  late SaveUserPreferenceService service;
  const testEmail = 'test@example.com';

  setUp(() {
    mockRepo = MockPreferenceRepository();
    service = SaveUserPreferenceService(mockRepo);
  });

  UserPreference createTestPref({
    String name = 'Valid Name',
    String breakfastTime = '07:00',
    String lunchTime = '12:00',
    String dinnerTime = '18:00',
  }) {
    return UserPreference(
      name: name,
      tastePreferences: const ['Chua', 'cay'],
      dietaryRestrictions: const ['Không'],
      favoriteCuisines: const ['Việt Nam'],
      breakfastReminder: true,
      lunchReminder: true,
      dinnerReminder: true,
      breakfastTime: breakfastTime,
      lunchTime: lunchTime,
      dinnerTime: dinnerTime,
    );
  }

  group('Validation Tên', () {
    test('Trả về lỗi khi tên để trống hoặc chỉ chứa khoảng trắng', () async {
      final pref = createTestPref(name: '   ');
      final result = await service.execute(pref, testEmail);

      expect(result.isSuccess, false);
      expect(result.errorMessage, 'Tên không được để trống!');
    });

    test('Trả về lỗi khi tên dưới 2 ký tự', () async {
      final pref = createTestPref(name: 'A');
      final result = await service.execute(pref, testEmail);

      expect(result.isSuccess, false);
      expect(result.errorMessage, 'Tên phải có ít nhất 2 ký tự!');
    });
  });

  group('Validation Thời gian', () {
    test(
      'Trả về lỗi khi giờ bữa sáng sai định dạng (lớn hơn 23 giờ)',
      () async {
        final pref = createTestPref(breakfastTime: '24:00');
        final result = await service.execute(pref, testEmail);

        expect(result.isSuccess, false);
        expect(
          result.errorMessage,
          'Giờ nhắc nhở bữa sáng không đúng định dạng HH:mm!',
        );
      },
    );

    test(
      'Trả về lỗi khi giờ bữa sáng sai định dạng (thiếu số 0 ở đầu)',
      () async {
        final pref = createTestPref(breakfastTime: '7:00');
        final result = await service.execute(pref, testEmail);

        expect(result.isSuccess, false);
        expect(
          result.errorMessage,
          'Giờ nhắc nhở bữa sáng không đúng định dạng HH:mm!',
        );
      },
    );

    test(
      'Trả về lỗi khi giờ bữa trưa sai định dạng phút (lớn hơn 59)',
      () async {
        final pref = createTestPref(lunchTime: '12:60');
        final result = await service.execute(pref, testEmail);

        expect(result.isSuccess, false);
        expect(
          result.errorMessage,
          'Giờ nhắc nhở bữa trưa không đúng định dạng HH:mm!',
        );
      },
    );

    test('Trả về lỗi khi giờ bữa tối sai định dạng kí tự (:)', () async {
      final pref = createTestPref(dinnerTime: '18h30');
      final result = await service.execute(pref, testEmail);

      expect(result.isSuccess, false);
      expect(
        result.errorMessage,
        'Giờ nhắc nhở bữa tối không đúng định dạng HH:mm!',
      );
    });
  });
}
