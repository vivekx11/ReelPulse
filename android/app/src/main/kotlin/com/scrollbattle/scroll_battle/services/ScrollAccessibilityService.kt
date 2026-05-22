package com.scrollbattle.scroll_battle.services

import android.accessibilityservice.AccessibilityService
import android.accessibilityservice.AccessibilityServiceInfo
import android.content.Intent
import android.view.accessibility.AccessibilityEvent
import android.view.accessibility.AccessibilityNodeInfo
import com.scrollbattle.scroll_battle.TrackingEventBus

/**
 * Accessibility Service that detects Instagram Reels and YouTube Shorts
 * by monitoring window content changes and scroll events.
 */
class ScrollAccessibilityService : AccessibilityService() {

    companion object {
        const val INSTAGRAM_PACKAGE = "com.instagram.android"
        const val YOUTUBE_PACKAGE = "com.google.android.youtube"

        // Instagram Reels view IDs (may change with app updates)
        private val REEL_VIEW_IDS = setOf(
            "com.instagram.android:id/clips_viewer_view_pager",
            "com.instagram.android:id/reel_viewer_root",
        )

        // YouTube Shorts view IDs
        private val SHORTS_VIEW_IDS = setOf(
            "com.google.android.youtube:id/reel_player_page_container",
            "com.google.android.youtube:id/shorts_container",
        )
    }

    private var lastReelScrollTime = 0L
    private var lastShortScrollTime = 0L
    private val scrollDebounceMs = 800L // minimum ms between counts

    override fun onServiceConnected() {
        super.onServiceConnected()
        val info = AccessibilityServiceInfo().apply {
            eventTypes = AccessibilityEvent.TYPE_VIEW_SCROLLED or
                    AccessibilityEvent.TYPE_WINDOW_CONTENT_CHANGED or
                    AccessibilityEvent.TYPE_WINDOW_STATE_CHANGED
            feedbackType = AccessibilityServiceInfo.FEEDBACK_GENERIC
            flags = AccessibilityServiceInfo.FLAG_REPORT_VIEW_IDS or
                    AccessibilityServiceInfo.FLAG_INCLUDE_NOT_IMPORTANT_VIEWS
            packageNames = arrayOf(INSTAGRAM_PACKAGE, YOUTUBE_PACKAGE)
            notificationTimeout = 100
        }
        serviceInfo = info
    }

    override fun onAccessibilityEvent(event: AccessibilityEvent?) {
        event ?: return
        val pkg = event.packageName?.toString() ?: return
        val now = System.currentTimeMillis()

        when (pkg) {
            INSTAGRAM_PACKAGE -> handleInstagramEvent(event, now)
            YOUTUBE_PACKAGE -> handleYouTubeEvent(event, now)
        }
    }

    private fun handleInstagramEvent(event: AccessibilityEvent, now: Long) {
        if (event.eventType != AccessibilityEvent.TYPE_VIEW_SCROLLED) return

        val source = event.source ?: return
        val viewId = source.viewIdResourceName ?: ""

        if (REEL_VIEW_IDS.any { viewId.contains(it) } ||
            isReelsScreen(source)
        ) {
            if (now - lastReelScrollTime > scrollDebounceMs) {
                lastReelScrollTime = now
                TrackingEventBus.onReelScrolled()
            }
        }
        source.recycle()
    }

    private fun handleYouTubeEvent(event: AccessibilityEvent, now: Long) {
        if (event.eventType != AccessibilityEvent.TYPE_VIEW_SCROLLED) return

        val source = event.source ?: return
        val viewId = source.viewIdResourceName ?: ""

        if (SHORTS_VIEW_IDS.any { viewId.contains(it) } ||
            isShortsScreen(source)
        ) {
            if (now - lastShortScrollTime > scrollDebounceMs) {
                lastShortScrollTime = now
                TrackingEventBus.onShortScrolled()
            }
        }
        source.recycle()
    }

    /**
     * Heuristic: check if the current Instagram screen is the Reels tab
     * by looking for characteristic node text/descriptions.
     */
    private fun isReelsScreen(node: AccessibilityNodeInfo): Boolean {
        return try {
            val root = rootInActiveWindow ?: return false
            val reelNodes = root.findAccessibilityNodeInfosByViewId(
                "com.instagram.android:id/clips_viewer_view_pager"
            )
            reelNodes.isNotEmpty()
        } catch (e: Exception) {
            false
        }
    }

    /**
     * Heuristic: check if the current YouTube screen is the Shorts player.
     */
    private fun isShortsScreen(node: AccessibilityNodeInfo): Boolean {
        return try {
            val root = rootInActiveWindow ?: return false
            val shortsNodes = root.findAccessibilityNodeInfosByViewId(
                "com.google.android.youtube:id/reel_player_page_container"
            )
            shortsNodes.isNotEmpty()
        } catch (e: Exception) {
            false
        }
    }

    override fun onInterrupt() {
        // Service interrupted – no action needed
    }
}
