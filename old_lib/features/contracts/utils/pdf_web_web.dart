import 'dart:async';
import 'dart:typed_data';
import 'dart:html' as html;

Future<void> openPdfInNewTab(
  Uint8List bytes, {
  required String fileName,
  bool autoPrint = false,
}) async {
  final blob = html.Blob([bytes], 'application/pdf');
  final url = html.Url.createObjectUrlFromBlob(blob);
  final win = autoPrint ? html.window.open(url, '_blank') : null;
  if (!autoPrint) {
    final a = html.AnchorElement(href: url)
      ..target = '_blank'
      ..rel = 'noopener'
      ..download = fileName;
    a.click();
  }

  if (autoPrint) {
    // Give the browser time to load the PDF viewer.
    Timer(const Duration(milliseconds: 700), () {
      try {
        final w = win as dynamic;
        w.focus();
        w.print();
      } catch (_) {}
    });
  }

  // Best effort cleanup.
  Timer(const Duration(minutes: 2), () {
    try {
      html.Url.revokeObjectUrl(url);
    } catch (_) {}
  });
}

