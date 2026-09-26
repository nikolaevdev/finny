import 'app_settings.dart';

abstract interface class AppSettingsRepository {
  AppSettings load();

  Future<void> save(AppSettings settings);
}
