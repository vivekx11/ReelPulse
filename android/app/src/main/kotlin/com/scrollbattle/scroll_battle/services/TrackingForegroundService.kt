package com.scrollbattle.scroll_battle.services

import android.app.*
import android.content.Context
import android.content.Intent
import android.os.IBinder
import androidx.core.app.NotificationCompat
import com.scrollbattle.scroll_battle.R
import com.scrollbattle.scroll_battle.TrackingEventBus

/**
 * Foreground service that keeps tracking alive in the background.
 * Listens to TrackingEventBus and syncs counts to Firestore via
 * the Flutter method channel.
 */
class TrackingForegroundService : Service() {

    companion object {
        const val CHANNEL_ID = "scroll_battle_tracking"
        const val NOTIFICATION_ID = 1001
        const val EXTRA_USER_ID = "user_id"

        fun start(context: Context, userId: String) {
            val intent = Intent(context, TrackingForegroundService::class.java)
                .putExtra(EXTRA_USER_ID, userId)
            context.startForegroundService(intent)
        }

        fun stop(context: Context) {
            context.stopService(
                Intent(context, TrackingForegroundService::class.java)
            )
        }
    }

    private var userId: String = ""
    private var reelCount = 0
    private var shortCount = 0

    private val reelListener: () -> Unit = {
        reelCount++
        updateNotification()
        TrackingEventBus.emitStats(reelCount, shortCount)
    }

    private val shortListener: () -> Unit = {
        shortCount++
        updateNotification()
        TrackingEventBus.emitStats(reelCount, shortCount)
    }

    override fun onCreate() {
        super.onCreate()
        createNotificationChannel()
        TrackingEventBus.addReelListener(reelListener)
        TrackingEventBus.addShortListener(shortListener)
    }

    override fun onStartCommand(intent: Intent?, flags: Int, startId: Int): Int {
        userId = intent?.getStringExtra(EXTRA_USER_ID) ?: ""
        startForeground(NOTIFICATION_ID, buildNotification())
        return START_STICKY
    }

    override fun onDestroy() {
        super.onDestroy()
        TrackingEventBus.removeReelListener(reelListener)
        TrackingEventBus.removeShortListener(shortListener)
    }

    override fun onBind(intent: Intent?): IBinder? = null

    private fun createNotificationChannel() {
        val channel = NotificationChannel(
            CHANNEL_ID,
            "ScrollBattle Tracking",
            NotificationManager.IMPORTANCE_LOW
        ).apply {
            description = "Tracks your Reels and Shorts usage"
            setShowBadge(false)
        }
        val manager = getSystemService(NotificationManager::class.java)
        manager.createNotificationChannel(channel)
    }

    private fun buildNotification(): Notification {
        return NotificationCompat.Builder(this, CHANNEL_ID)
            .setContentTitle("ScrollBattle is tracking")
            .setContentText("Reels: $reelCount · Shorts: $shortCount")
            .setSmallIcon(android.R.drawable.ic_menu_view)
            .setOngoing(true)
            .setSilent(true)
            .build()
    }

    private fun updateNotification() {
        val manager = getSystemService(NotificationManager::class.java)
        manager.notify(NOTIFICATION_ID, buildNotification())
    }
}
