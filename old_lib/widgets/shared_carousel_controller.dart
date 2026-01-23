import 'dart:async';
import 'package:flutter/foundation.dart';

/// Shared controller for synchronizing multiple PropertyImageCarousel instances.
/// All carousels listen to the same timer tick, so they stay in sync.
class SharedCarouselController extends ChangeNotifier {
  static final SharedCarouselController _instance =
      SharedCarouselController._internal();

  factory SharedCarouselController() => _instance;

  SharedCarouselController._internal() {
    _startTimer();
  }

  Timer? _timer;
  int _currentTick = 0;

  static const Duration _interval = Duration(seconds: 3);

  void _startTimer() {
    _timer?.cancel();
    _timer = Timer.periodic(_interval, (_) {
      _currentTick++;
      notifyListeners();
    });
  }

  int get currentTick => _currentTick;

  @override
  void dispose() {
    _timer?.cancel();
    _timer = null;
    super.dispose();
  }
}


