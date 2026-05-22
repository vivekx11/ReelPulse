package com.scrollbattle.scroll_battle

import io.flutter.plugin.common.EventChannel

/**
 * Simple in-process event bus that bridges the Accessibility Service
 * (which runs in a separate thread) to the Flutter EventChannel sink.
 */
object TrackingEventBus {

    private val reelListeners = mutableListOf<() -> Unit>()
    private val shortListeners = mutableListOf<() -> Unit>()

    // Flutter EventChannel sink – set by MainActivity
    var eventSink: EventChannel.EventSink? = null

    private var reelCount = 0
    private var shortCount = 0

    fun onReelScrolled() {
        reelCount++
        reelListeners.forEach { it() }
    }

    fun onShortScrolled() {
        shortCount++
        shortListeners.forEach { it() }
    }

    fun emitStats(reels: Int, shorts: Int) {
        reelCount = reels
        shortCount = shorts
        eventSink?.success(
            mapOf(
                "reels" to reels,
                "shorts" to shorts,
            )
        )
    }

    fun addReelListener(listener: () -> Unit) {
        reelListeners.add(listener)
    }

    fun removeReelListener(listener: () -> Unit) {
        reelListeners.remove(listener)
    }

    fun addShortListener(listener: () -> Unit) {
        shortListeners.add(listener)
    }

    fun removeShortListener(listener: () -> Unit) {
        shortListeners.remove(listener)
    }

    fun resetCounts() {
        reelCount = 0
        shortCount = 0
    }

    fun getCounts() = Pair(reelCount, shortCount)
}
