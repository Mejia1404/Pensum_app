import 'dart:math';

/// Genera un UUID v4 simple sin dependencias externas
String generateUUID() {
  final random = Random();
  const chars = '0123456789abcdef';
  final buffer = StringBuffer();

  for (int i = 0; i < 36; i++) {
    if (i == 8 || i == 13 || i == 18 || i == 23) {
      buffer.write('-');
    } else if (i == 14) {
      buffer.write('4');
    } else if (i == 19) {
      buffer.write(chars[(random.nextInt(16) & 0x3) | 0x8]);
    } else {
      buffer.write(chars[random.nextInt(16)]);
    }
  }

  return buffer.toString();
}
