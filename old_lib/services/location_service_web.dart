import 'dart:async';
import 'dart:js_interop';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter_web_plugins/flutter_web_plugins.dart';
import 'package:web/web.dart' as web;

/// Web plugin for location services using browser's geolocation API
class LocationServiceWeb {
  static void registerWith(Registrar registrar) {
    final channel = MethodChannel(
      'youragent/location',
      const StandardMethodCodec(),
      registrar,
    );

    final instance = LocationServiceWeb();
    channel.setMethodCallHandler(instance.handleMethodCall);
    registrar.registerMessageHandler();
  }

  Future<dynamic> handleMethodCall(MethodCall call) async {
    if (call.method == 'getCurrentLocation') {
      return _getCurrentLocation();
    }
    throw PlatformException(
      code: 'Unimplemented',
      details: 'Method ${call.method} is not implemented',
    );
  }

  Future<Map<String, double>> _getCurrentLocation() async {
    if (!kIsWeb) {
      throw PlatformException(
        code: 'NotSupported',
        message: 'This method is only supported on web',
      );
    }

    final geolocation = web.window.navigator.geolocation;

    final completer = Completer<Map<String, double>>();

    final options = web.PositionOptions(
      enableHighAccuracy: true,
      timeout: 10000,
      maximumAge: 0,
    );

    geolocation.getCurrentPosition(
      ((web.GeolocationPosition position) {
        final coords = position.coords;
        completer.complete({
          'latitude': coords.latitude,
          'longitude': coords.longitude,
        });
      }).toJS,
      ((web.GeolocationPositionError error) {
        String message = 'Failed to get location';
        switch (error.code) {
          case 1: // PERMISSION_DENIED
            message =
                'Location permission denied. Please allow location access in your browser settings.';
            break;
          case 2: // POSITION_UNAVAILABLE
            message = 'Location information is unavailable.';
            break;
          case 3: // TIMEOUT
            message = 'Location request timed out.';
            break;
        }
        completer.completeError(
          PlatformException(code: 'LocationError', message: message),
        );
      }).toJS,
      options,
    );

    return completer.future;
  }
}
