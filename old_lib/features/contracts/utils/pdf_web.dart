import 'dart:typed_data';

import 'pdf_web_stub.dart'
    if (dart.library.html) 'pdf_web_web.dart' as impl;

Future<void> openPdfInNewTab(
  Uint8List bytes, {
  required String fileName,
  bool autoPrint = false,
}) {
  return impl.openPdfInNewTab(
    bytes,
    fileName: fileName,
    autoPrint: autoPrint,
  );
}

