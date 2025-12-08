import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:watashi/src/modules/settings/data/settings_repo.dart';
import 'package:watashi/src/shared/errors/app_exceptions.dart';

enum ConnectionMode {
  proxy(1),
  vpn(2);

  final int value;

  const ConnectionMode(this.value);

  factory ConnectionMode.fromValue(int value) => switch (value) {
        1 => proxy,
        2 => vpn,
        _ => throw ConnectionModeException(value)
      };

  ConnectionMode get getToggle => switch (this) { proxy => vpn, vpn => proxy };
}

/// Connection mode provider that reads initial value from settings
final connectionModeProvider = StateProvider<ConnectionMode>((ref) {
  // Read initial value from settings
  final settings = ref.read(settingsRepoProvider).settings;
  return settings.connectionMode;
});
