package com.scrollbattle.scroll_battle

import android.app.AppOpsManager
import android.app.usage.UsageStatsManager
import android.content.Context
import android.content.Intent
import android.net.Uri
import android.os.Build
import android.os.Process
import android.provider.Settings
import android.view.accessibility.AccessibilityManager
import com.scrollbattle.scroll_battle.services.TrackingForegroundService
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.EventChannel
import io.flutter.plugin.common.MethodChannel
import java.util.Calendar

class MainActivity : FlutterActivity() {

    companion object {
        private const val METHOD_CHANNEL = "com.scrollbattle/tracking"
        private const val EVENT_CHANNEL = "com.scrollbattle/stats_stream"

        private const val INSTAGRAM_PACKAGE = "com.instagram.android"
        private const val YOUTUBE_PACKAGE = "com.google.android.youtube"
    }

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        // ── Method Channel ────────────────────────────────────────────────────
        MethodChannel(
            flutterEngine.dartExecutor.binaryMessenger,
            METHOD_CHANNEL
        ).setMethodCallHandler { call, result ->
            when (call.method) {

                "isAccessibilityEnabled" ->
                    result.success(isAccessibilityServiceEnabled())

                "openAccessibilitySettings" -> {
                    startActivity(Intent(Settings.ACTION_ACCESSIBILITY_SETTINGS))
                    result.success(null)
                }

                "isUsageStatsPermissionGranted" ->
                    result.success(isUsageStatsPermissionGranted())

                "openUsageStatsSettings" -> {
                    startActivity(Intent(Settings.ACTION_USAGE_ACCESS_SETTINGS))
                    result.success(null)
                }

                "isOverlayPermissionGranted" ->
                    result.success(Settings.canDrawOverlays(this))

                "openOverlaySettings" -> {
                    val intent = Intent(
                        Settings.ACTION_MANAGE_OVERLAY_PERMISSION,
                        Uri.parse("package:$packageName")
                    )
                    startActivity(intent)
                    result.success(null)
                }

                "startTrackingService" -> {
                    val userId = call.argument<String>("userId") ?: ""
                    TrackingForegroundService.start(this, userId)
                    result.success(null)
                }

                "stopTrackingService" -> {
                    TrackingForegroundService.stop(this)
                    result.success(null)
                }

                "getTodayUsageStats" -> {
                    result.success(getTodayUsageStats())
                }

                "showOverlay" -> {
                    // Overlay is handled by flutter_overlay_window package
                    result.success(null)
                }

                "hideOverlay" -> {
                    result.success(null)
                }

                "updateOverlayStats" -> {
                    // Forward to overlay window if open
                    result.success(null)
                }

                else -> result.notImplemented()
            }
        }

        // ── Event Channel (live stats stream) ─────────────────────────────────
        EventChannel(
            flutterEngine.dartExecutor.binaryMessenger,
            EVENT_CHANNEL
        ).setStreamHandler(object : EventChannel.StreamHandler {
            override fun onListen(arguments: Any?, events: EventChannel.EventSink?) {
                TrackingEventBus.eventSink = events
            }

            override fun onCancel(arguments: Any?) {
                TrackingEventBus.eventSink = null
            }
        })
    }

    // ── Helpers ───────────────────────────────────────────────────────────────

    private fun isAccessibilityServiceEnabled(): Boolean {
        val am = getSystemService(Context.ACCESSIBILITY_SERVICE) as AccessibilityManager
        val enabledServices = Settings.Secure.getString(
            contentResolver,
            Settings.Secure.ENABLED_ACCESSIBILITY_SERVICES
        ) ?: return false
        val serviceName =
            "$packageName/com.scrollbattle.scroll_battle.services.ScrollAccessibilityService"
        return enabledServices.contains(serviceName)
    }

    private fun isUsageStatsPermissionGranted(): Boolean {
        val appOps = getSystemService(Context.APP_OPS_SERVICE) as AppOpsManager
        val mode = appOps.checkOpNoThrow(
            AppOpsManager.OPSTR_GET_USAGE_STATS,
            Process.myUid(),
            packageName
        )
        return mode == AppOpsManager.MODE_ALLOWED
    }

    /**
     * Returns today's foreground usage in seconds for Instagram and YouTube.
     */
    private fun getTodayUsageStats(): Map<String, Int> {
        if (!isUsageStatsPermissionGranted()) return emptyMap()

        val usm = getSystemService(Context.USAGE_STATS_SERVICE) as UsageStatsManager
        val cal = Calendar.getInstance().apply {
            set(Calendar.HOUR_OF_DAY, 0)
            set(Calendar.MINUTE, 0)
            set(Calendar.SECOND, 0)
            set(Calendar.MILLISECOND, 0)
        }
        val startTime = cal.timeInMillis
        val endTime = System.currentTimeMillis()

        val stats = usm.queryUsageStats(
            UsageStatsManager.INTERVAL_DAILY,
            startTime,
            endTime
        )

        val result = mutableMapOf<String, Int>()
        stats?.forEach { stat ->
            when (stat.packageName) {
                INSTAGRAM_PACKAGE ->
                    result["instagram"] =
                        (stat.totalTimeInForeground / 1000).toInt()
                YOUTUBE_PACKAGE ->
                    result["youtube"] =
                        (stat.totalTimeInForeground / 1000).toInt()
            }
        }
        return result
    }
}
