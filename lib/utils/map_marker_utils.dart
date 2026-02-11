import 'dart:ui' as ui;
import 'package:flutter/foundation.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:youragent/core/theme/app_colors.dart';

class MapMarkerUtils {
  static final Map<String, BitmapDescriptor> _cachedIcons = {};

  static Future<BitmapDescriptor> createCustomMarkerIcon({
    String assetPath = 'assets/icons/map-marker-filled.svg',
    double width = 36,
    double height = 36,
    ui.Color color = AppColors.supportRedDark,
  }) async {
    final String cacheKey = '${assetPath}_${width}_${height}_${color.value}';
    if (_cachedIcons.containsKey(cacheKey)) {
      return _cachedIcons[cacheKey]!;
    }

    try {
      final pictureInfo = await vg.loadPicture(SvgAssetLoader(assetPath), null);

      final ratio = ui.PlatformDispatcher.instance.views.first.devicePixelRatio;
      final widthPx = (width * ratio).toInt();
      final heightPx = (height * ratio).toInt();

      final recorder = ui.PictureRecorder();
      final canvas = ui.Canvas(recorder);
      canvas.scale(
        widthPx / pictureInfo.size.width,
        heightPx / pictureInfo.size.height,
      );

      // Apply color filter using saveLayer
      canvas.saveLayer(
        null,
        ui.Paint()
          ..colorFilter = ui.ColorFilter.mode(color, ui.BlendMode.srcIn),
      );
      canvas.drawPicture(pictureInfo.picture);
      canvas.restore();

      final picture = recorder.endRecording();
      final image = await picture.toImage(widthPx, heightPx);
      final bytes = await image.toByteData(format: ui.ImageByteFormat.png);

      if (bytes != null) {
        final icon = BitmapDescriptor.fromBytes(bytes.buffer.asUint8List());
        _cachedIcons[cacheKey] = icon;
        return icon;
      }

      return BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed);
    } catch (e) {
      debugPrint('Error loading marker: $e');
      return BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed);
    }
  }

  static void clearCache() {
    _cachedIcons.clear();
  }
}
