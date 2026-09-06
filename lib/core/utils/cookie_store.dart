import 'cookie_store_stub.dart'
    if (dart.library.js_interop) 'cookie_store_web.dart' as impl;

void writeCookie(String name, String value, {int maxAgeDays = 400}) {
  impl.writeCookie(name, value, maxAgeDays: maxAgeDays);
}

String? readCookie(String name) => impl.readCookie(name);

void deleteCookie(String name) => impl.deleteCookie(name);
