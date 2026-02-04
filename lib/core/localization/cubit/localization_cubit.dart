import 'dart:ui';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class LocalizationCubit extends Cubit<Locale> {
  final FlutterSecureStorage _storage;
  static const _storageKey = 'language_code';

  LocalizationCubit({required FlutterSecureStorage storage})
    : _storage = storage,
      super(const Locale('th'));

  Future<void> loadSavedLocale() async {
    try {
      final savedCode = await _storage.read(key: _storageKey);
      if (savedCode != null) {
        emit(Locale(savedCode));
      } else {
        // Use system locale if available, default to Thai if not supported or english/thai
        final systemLocale = PlatformDispatcher.instance.locale;
        if (systemLocale.languageCode == 'en') {
          emit(const Locale('en'));
        } else {
          emit(const Locale('th'));
        }
      }
    } catch (_) {
      // Fallback to default
      emit(const Locale('th'));
    }
  }

  Future<void> changeLocale(Locale locale) async {
    await _storage.write(key: _storageKey, value: locale.languageCode);
    emit(locale);
  }
}
