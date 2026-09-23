import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

final themeControllerProvider =
    StateNotifierProvider<ThemeController, ThemeMode>((ref) {
      return ThemeController()..load();
    });

class ThemeController extends StateNotifier<ThemeMode> {
  ThemeController() : super(ThemeMode.system);

  static const _key = 'theme_mode';

  Future<void> load() async {
    final value = (await SharedPreferences.getInstance()).getString(_key);
    state = switch (value) {
      'light' => ThemeMode.light,
      'dark' => ThemeMode.dark,
      _ => ThemeMode.system,
    };
  }

  Future<void> setMode(ThemeMode mode) async {
    state = mode;
    await (await SharedPreferences.getInstance()).setString(_key, mode.name);
  }
}
