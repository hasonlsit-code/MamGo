import 'package:mamgo/domain/entities/user_preference_entity.dart';
import 'package:mamgo/domain/interface_repositories/ipreference_repository.dart';

class LoadUserPreferenceService {
  final IPreferenceRepository repository;

  LoadUserPreferenceService(this.repository);

  Future<UserPreference?> execute(String email) {
    return repository.load(email);
  }
}

class SaveUserPreferenceService {
  final IPreferenceRepository repository;

  SaveUserPreferenceService(this.repository);

  Future<SavePreferenceResult> execute(
    UserPreference preference,
    String email,
  ) async {
    final nameClean = preference.name.trim();
    if (nameClean.isEmpty) {
      return const SavePreferenceResult.error('Tên không được để trống!');
    }
    if (nameClean.length < 2) {
      return const SavePreferenceResult.error('Tên phải có ít nhất 2 ký tự!');
    }

    final timeRegExp = RegExp(r'^(0[0-9]|1[0-9]|2[0-3]):[0-5][0-9]$');
    if (!timeRegExp.hasMatch(preference.breakfastTime)) {
      return const SavePreferenceResult.error(
        'Giờ nhắc nhở bữa sáng không đúng định dạng HH:mm!',
      );
    }
    if (!timeRegExp.hasMatch(preference.lunchTime)) {
      return const SavePreferenceResult.error(
        'Giờ nhắc nhở bữa trưa không đúng định dạng HH:mm!',
      );
    }
    if (!timeRegExp.hasMatch(preference.dinnerTime)) {
      return const SavePreferenceResult.error(
        'Giờ nhắc nhở bữa tối không đúng định dạng HH:mm!',
      );
    }

    // Tạo một đối tượng mới với tên đã được làm sạch để đảm bảo dữ liệu
    // lưu trữ được nhất quán và không có khoảng trắng thừa.
    final preferenceToSave = UserPreference(
      name: nameClean,
      tastePreferences: preference.tastePreferences,
      dietaryRestrictions: preference.dietaryRestrictions,
      favoriteCuisines: preference.favoriteCuisines,
      breakfastReminder: preference.breakfastReminder,
      lunchReminder: preference.lunchReminder,
      dinnerReminder: preference.dinnerReminder,
      breakfastTime: preference.breakfastTime,
      lunchTime: preference.lunchTime,
      dinnerTime: preference.dinnerTime,
    );
    await repository.save(preferenceToSave, email);
    return const SavePreferenceResult.success();
  }
}

class SavePreferenceResult {
  final String? errorMessage;
  final bool isSuccess;

  const SavePreferenceResult.success() : errorMessage = null, isSuccess = true;

  const SavePreferenceResult.error(this.errorMessage) : isSuccess = false;
}
