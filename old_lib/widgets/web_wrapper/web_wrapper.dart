// This file exports web-only functionality on web, and stubs on other platforms
export 'web_wrapper_stub.dart' if (dart.library.js_interop) 'web_wrapper_web.dart';
