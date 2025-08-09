import 'package:finow/features/storage_viewer/local_storage_service.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

enum FontSizeOption {
  small('Small', 0.9),
  medium('Medium', 1.0),
  large('Large', 1.1);

  const FontSizeOption(this.label, this.scale);
  final String label;
  final double scale;
}

final fontSizeNotifierProvider = NotifierProvider<FontSizeNotifier, FontSizeOption>(FontSizeNotifier.new);

class FontSizeNotifier extends Notifier<FontSizeOption> {
  static const _fontSizeKey = 'fontSize';

  @override
  FontSizeOption build() {
    final localStorage = ref.watch(localStorageServiceProvider);
    // Hive에서 저장된 폰트 크기 값을 읽어옵니다. 기본값은 medium입니다.
    final fontSizeName = localStorage.read<String>(_fontSizeKey) ?? FontSizeOption.medium.name;
    // String을 FontSizeOption enum으로 변환하여 반환합니다. 유효하지 않은 값이면 medium으로 폴백합니다.
    return FontSizeOption.values.firstWhere((e) => e.name == fontSizeName, orElse: () => FontSizeOption.medium);
  }

  void setFontSize(FontSizeOption size) {
    final localStorage = ref.read(localStorageServiceProvider);
    // 새로운 폰트 크기를 Hive에 저장합니다.
    localStorage.write(_fontSizeKey, size.name);
    state = size;
  }
}