package com.imparty.live

import android.app.NotificationChannel
import android.app.NotificationManager
import android.app.PendingIntent
import android.app.Service
import android.content.Intent
import android.content.pm.PackageManager
import android.content.pm.ServiceInfo
import android.os.Build
import android.os.IBinder
import android.content.BroadcastReceiver
import android.content.IntentFilter
import android.content.Context
import androidx.core.app.NotificationCompat
import androidx.core.content.ContextCompat
import java.net.HttpURLConnection
import java.net.URL

class ForegroundService : Service() {

    private val CHANNEL_ID = "channel"
    private val CHANNEL_NAME = "channel name"
    private val CHANNEL_DESC = "channel desc"

    private var isReceiverRegistered = false

    private val receiver = object : BroadcastReceiver() {
        override fun onReceive(context: Context?, intent: Intent?) {
            intent?.let {
                if (it.action == ACTION_HIDE_NOTIFICATION) {
                    stopForeground(true)
                    stopSelf()
                }
            }
        }
    }

    override fun onCreate() {
        super.onCreate()
    }

    override fun onBind(intent: Intent): IBinder? {
        return null
    }

    override fun onStartCommand(intent: Intent?, flags: Int, startId: Int): Int {
        val filter = IntentFilter(ACTION_HIDE_NOTIFICATION)
        // ContextCompat dispatches to the correct registerReceiver overload per
        // SDK internally. Using it (instead of a manual SDK_INT gate on the 3-arg
        // platform overload) avoids the $$ExternalSyntheticApiModelOutline desugar
        // stub that throws NoSuchMethodError on inconsistent OEM/older ROMs. The
        // receiver only handles ACTION_HIDE_NOTIFICATION sent by this app, so it
        // is NOT_EXPORTED.
        if (!isReceiverRegistered) {
            ContextCompat.registerReceiver(
                this, receiver, filter, ContextCompat.RECEIVER_NOT_EXPORTED
            )
            isReceiverRegistered = true
        }

        val notificationTitle = intent?.getStringExtra("notification-title") ?: "Live Voice Room 🔥"
        val notificationDes = intent?.getStringExtra("notification-des") ?: "Tap to return to the app"

        createNotificationChannel()

        val launcher = launcherActivity
        val appIntent: Intent = if (launcher.isNotEmpty()) {
            try {
                Intent(this, Class.forName(launcher))
            } catch (e: Exception) {
                packageManager.getLaunchIntentForPackage(packageName) ?: Intent()
            }
        } else {
            packageManager.getLaunchIntentForPackage(packageName) ?: Intent()
        }

        appIntent.action = Intent.ACTION_MAIN
        appIntent.addCategory(Intent.CATEGORY_LAUNCHER)

        val pendingIntent = if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.M) {
            PendingIntent.getActivity(
                this, 0, appIntent,
                PendingIntent.FLAG_IMMUTABLE or PendingIntent.FLAG_UPDATE_CURRENT
            )
        } else {
            PendingIntent.getActivity(this, 0, appIntent, PendingIntent.FLAG_UPDATE_CURRENT)
        }

        val context = applicationContext
        val appInfo = context.packageManager.getApplicationInfo(context.packageName, PackageManager.GET_META_DATA)
        val applicationName = appInfo.labelRes
        val appName = if (applicationName != 0) {
            context.getString(applicationName)
        } else {
            appInfo.nonLocalizedLabel.toString()
        }

        val builder = NotificationCompat.Builder(context, CHANNEL_ID)
            .setSmallIcon(R.mipmap.ic_launcher)
            .setContentTitle(notificationTitle)
            .setContentText(notificationDes)
            .setPriority(NotificationCompat.PRIORITY_MIN)
            .setCategory(NotificationCompat.CATEGORY_SERVICE)
            .setSilent(true)
            .setContentIntent(pendingIntent)
            .setOngoing(true)
            .setAutoCancel(true)

        // Android 14+ (targetSdk 34+) requires an explicit foregroundServiceType
        // on startForeground, and background mic CAPTURE (not just playback) is
        // only permitted while a service is actively running with the
        // MICROPHONE type — declaring it in the manifest is not enough, it must
        // be passed here too. This was MEDIA_PLAYBACK-only, which is why
        // playback (hearing others) kept working after backgrounding/minimizing
        // but the local mic went silent (others stopped hearing the user) —
        // the OS was never granted background mic access. RECORD_AUDIO is only
        // requested by speakers (audience users may never have granted it), so
        // MICROPHONE is added to the type set only when that permission is
        // actually held, to avoid the SecurityException the old comment here
        // was avoiding. Guarded so a failure can never crash room entry.
        try {
            if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.Q) {
                val hasMicPermission = ContextCompat.checkSelfPermission(
                    this, android.Manifest.permission.RECORD_AUDIO
                ) == PackageManager.PERMISSION_GRANTED
                val serviceType = if (hasMicPermission) {
                    ServiceInfo.FOREGROUND_SERVICE_TYPE_MEDIA_PLAYBACK or
                        ServiceInfo.FOREGROUND_SERVICE_TYPE_MICROPHONE
                } else {
                    ServiceInfo.FOREGROUND_SERVICE_TYPE_MEDIA_PLAYBACK
                }
                startForeground(ID, builder.build(), serviceType)
            } else {
                startForeground(ID, builder.build())
            }
        } catch (e: Exception) {
            // If the OS refuses the foreground promotion, fall back to running as a
            // plain started service so onTaskRemoved still fires for quit_room.
            try {
                startForeground(ID, builder.build())
            } catch (_: Exception) {
            }
        }
        return START_STICKY
    }

    /// App swiped from recents: fire the quit_room backend cleanup before the
    /// process dies (the Dart isolate is already gone). Mirrors the iOS
    /// AppDelegate.applicationWillTerminate path.
    override fun onTaskRemoved(rootIntent: Intent?) {
        try {
            val prefs = getSharedPreferences("room_prefs", Context.MODE_PRIVATE)
            val roomId = prefs.getString("room_id", null)
            val token = prefs.getString("room_token", null)
            val lang = prefs.getString("room_language_code", "en") ?: "en"
            val apiBaseUrl = prefs.getString("api_base_url", null)
            // No hardcoded host: the URL is built from the runtime base persisted
            // by Dart. Without it there is nothing to call (white-label).
            if (!roomId.isNullOrEmpty() && !token.isNullOrEmpty() &&
                !apiBaseUrl.isNullOrEmpty()) {
                sendQuitRoom(apiBaseUrl, roomId, token, lang)
                prefs.edit().clear().apply()
            }
        } catch (_: Exception) {
        }
        stopSelf()
        super.onTaskRemoved(rootIntent)
    }

    private fun sendQuitRoom(apiBaseUrl: String, roomId: String, token: String, lang: String) {
        val thread = Thread {
            var conn: HttpURLConnection? = null
            try {
                // apiBaseUrl is the runtime backend base (e.g. https://host/api),
                // persisted by Dart from EndPoints.baseURL. No client literal.
                val base = apiBaseUrl.trimEnd('/')
                val url = URL("$base/rooms/quit_room")
                conn = (url.openConnection() as HttpURLConnection).apply {
                    requestMethod = "POST"
                    connectTimeout = 5000
                    readTimeout = 5000
                    doOutput = true
                    setRequestProperty("Accept", "application/json")
                    setRequestProperty("Content-Type", "application/json; charset=utf-8")
                    setRequestProperty("Authorization", "Bearer $token")
                    setRequestProperty("X-localization", if (lang == "ar") "ar" else "en")
                }
                conn.outputStream.use { it.write("{\"room_id\":\"$roomId\"}".toByteArray(Charsets.UTF_8)) }
                conn.responseCode // force the request to be sent
            } catch (_: Exception) {
            } finally {
                conn?.disconnect()
            }
        }
        thread.start()
        // Give the request a short window to complete before the process is killed.
        thread.join(4500)
    }


    val launcherActivity: String
        get() {
            val intent = Intent(Intent.ACTION_MAIN, null)
            intent.addCategory(Intent.CATEGORY_LAUNCHER)
            intent.setPackage(packageName)
            val pm = application.packageManager
            val info = pm.queryIntentActivities(intent, 0)
            return if (info.isNullOrEmpty()) {
                ""
            } else {
                info[0].activityInfo.name
            }
        }

    override fun onDestroy() {
        stopForeground(true)
        // Guard + try/catch: if the receiver was never registered (onStartCommand
        // never ran) or was already unregistered, unregisterReceiver throws
        // IllegalArgumentException "Receiver not registered".
        if (isReceiverRegistered) {
            try {
                unregisterReceiver(receiver)
            } catch (_: IllegalArgumentException) {
            } finally {
                isReceiverRegistered = false
            }
        }
        stopSelf()
        super.onDestroy()
    }

    private fun createNotificationChannel() {
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
            val name: CharSequence = CHANNEL_NAME
            val description = CHANNEL_DESC
            val importance = NotificationManager.IMPORTANCE_MIN
            val channel = NotificationChannel(CHANNEL_ID, name, importance)
            channel.description = description
            channel.setSound(null, null)
            channel.enableVibration(false)
            val notificationManager = getSystemService(NotificationManager::class.java)
            notificationManager.createNotificationChannel(channel)
        }
    }

    companion object {
        private const val ID = 65532
        const val ACTION_HIDE_NOTIFICATION = "com.imparty.live.ACTION_HIDE_NOTIFICATION"
    }
}
