import 'dart:async';
import 'package:app_links/app_links.dart';
import 'package:youragent/core/di/dependency_injection.dart';

enum DeepLinkStatus { success, failure, none }

class DeepLinkService {
  final _appLinks = AppLinks();
  StreamSubscription<Uri>? _linkSubscription;

  final _statusController = StreamController<DeepLinkStatus>.broadcast();
  Stream<DeepLinkStatus> get statusStream => _statusController.stream;

  void init() {
    // Check initial link if app was opened by one
    _appLinks.getInitialLink().then((uri) {
      if (uri != null) _handleUri(uri);
    });

    // Listen for incoming links while app is running
    _linkSubscription = _appLinks.uriLinkStream.listen(
      (uri) => _handleUri(uri),
      onError: (err) {
        DependencyInjection.talker?.error('DeepLinkService Error: $err');
      },
    );
  }

  void _handleUri(Uri uri) {
    DependencyInjection.talker?.log('Incoming Deep Link: $uri');

    // Check if it's our callback: youragent://callback?status=success
    if (uri.scheme == 'youragent' && uri.host == 'callback') {
      final status = uri.queryParameters['status'];
      if (status == 'success') {
        _statusController.add(DeepLinkStatus.success);
      } else if (status == 'failure') {
        _statusController.add(DeepLinkStatus.failure);
      }
    }
  }

  void dispose() {
    _linkSubscription?.cancel();
    _statusController.close();
  }
}
