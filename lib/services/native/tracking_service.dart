import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Method channel bridge to the Kotlin Accessibility + UsageStats service
class TrackingService {
  static const MethodChannel _channel =
      MethodChannel('com.scrollbattle/tracking');

  static const EventChannel _statsChannel =
      EventChannel('com.scrollbattle/stats_stream');

  /// Check if Accessibility Service is enabled
  Future<bool> isAccessibilityEnabled() async {
    try {
      return await _channel.invokeMethod<bool>('isAccessibilityEnabled') ??
          false;
    } on PlatformException {
      return false;
    }
  }

  /// Open Accessibility Settings
  Future<void> openAccessibilitySettings() async {
    await _channel.invokeMethod('openAccessibilitySettings');
  }

  /// Check if Usage Stats permission is granted
  Future<bool> isUsageStatsPermissionGranted() async {
    try {
      return await _channel
              .invokeMethod<bool>('isUsageStatsPermissionGranted') ??
          false;
    } on PlatformException {
      return false;
    }
  }

  /// Open Usage Stats Settings
  Future<void> openUsageStatsSettings() async {
    await _channel.invokeMethod('openUsageStatsSettings');
  }

  /// Check if overlay permission is granted
  Future<bool> isOverlayPermissionGranted() async {
    try {
      return await _channel
              .invokeMethod<bool>('isOverlayPermissionGranted') ??
          false;
    } on PlatformException {
      return false;
    }
  }

  /// Open overlay permission settings
  Future<void> openOverlaySettings() async {
    await _channel.invokeMethod('openOverlaySettings');
  }

  /// Start the foreground tracking service
  Future<void> startTrackingService(String userId) async {
    await _channel.invokeMethod('startTrackingService', {'userId': userId});
  }

  /// Stop the foreground tracking service
  Future<void> stopTrackingService() async {
    await _channel.invokeMethod('stopTrackingService');
  }

  /// Get today's usage stats from UsageStatsManager
  Future<Map<String, int>> getTodayUsageStats() async {
    try {
      final result = await _channel
          .invokeMapMethod<String, int>('getTodayUsageStats');
      return result ?? {};
    } on PlatformException {
      return {};
    }
  }

  /// Stream of live stats updates from the accessibility service
  Stream<Map<String, dynamic>> get statsStream {
    return _statsChannel.receiveBroadcastStream().map((event) {
      return Map<String, dynamic>.from(event as Map);
    });
  }

  /// Show the floating overlay bubble
  Future<void> showOverlay() async {
    await _channel.invokeMethod('showOverlay');
  }

  /// Hide the floating overlay bubble
  Future<void> hideOverlay() async {
    await _channel.invokeMethod('hideOverlay');
  }

  /// Update overlay stats
  Future<void> updateOverlayStats({
    required int reels,
    required int shorts,
    required int seconds,
  }) async {
    await _channel.invokeMethod('updateOverlayStats', {
      'reels': reels,
      'shorts': shorts,
      'seconds': seconds,
    });
  }
}

final trackingServiceProvider = Provider<TrackingService>((ref) {
  return TrackingService();
});
