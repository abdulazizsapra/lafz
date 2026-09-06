import 'package:web/web.dart' as web;

void writeCookie(String name, String value, {int maxAgeDays = 400}) {
  final encoded = Uri.encodeComponent(value);
  final maxAge = maxAgeDays * 24 * 60 * 60;
  web.document.cookie =
      '$name=$encoded; Max-Age=$maxAge; Path=/; SameSite=Lax';
}

String? readCookie(String name) {
  final raw = web.document.cookie;
  if (raw.isEmpty) return null;
  for (final part in raw.split(';')) {
    final trimmed = part.trim();
    final eq = trimmed.indexOf('=');
    if (eq <= 0) continue;
    if (trimmed.substring(0, eq) == name) {
      return Uri.decodeComponent(trimmed.substring(eq + 1));
    }
  }
  return null;
}

void deleteCookie(String name) {
  web.document.cookie = '$name=; Max-Age=0; Path=/; SameSite=Lax';
}
