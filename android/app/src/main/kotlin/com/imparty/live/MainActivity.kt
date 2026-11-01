package com.imparty.live

import android.app.Activity
import android.app.ActivityManager
import android.content.Context
import android.content.Intent
import android.content.res.Configuration
import android.net.Uri
import android.graphics.Color
import android.os.Build
import android.os.Bundle
import android.os.Handler
import android.os.Looper
import android.util.Log
import android.view.WindowManager
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
import java.util.concurrent.Executors

class MainActivity : FlutterActivity() {

    private val MEMORY_CHANNEL = "device_memory_channel"
    private val BACKGROUND_SERVICE_CHANNEL = "background_service"
    private val ROOM_SERVICE_CHANNEL = "room_service_channel"
    private val PIP_STATE_CHANNEL = "pip_state_channel"
    private val VOICE_FX_CHANNEL = "miva/voice_fx"
    // 🔵 File Picker Channel
    private val FILE_PICKER_CHANNEL = "file_picker_channel"
    private val PICK_FILE_REQUEST = 1001
    private var pendingFilePickerResult: MethodChannel.Result? = null

    private val executor = Executors.newSingleThreadExecutor()
    private val mainHandler = Handler(Looper.getMainLooper())

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        // Transparent system navigation bar with no contrast scrim, so the
        // app's bottom bar image shows under the phone's back/home buttons.
        window.addFlags(WindowManager.LayoutParams.FLAG_DRAWS_SYSTEM_BAR_BACKGROUNDS)
        window.clearFlags(WindowManager.LayoutParams.FLAG_TRANSLUCENT_NAVIGATION)
        window.navigationBarColor = Color.TRANSPARENT
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.Q) {
            window.isNavigationBarContrastEnforced = false
        }
        // Let Flutter draw behind the navigation bar (edge-to-edge).
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.R) {
            window.setDecorFitsSystemWindows(false)
        }
    }

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        // ===============================
        // 🧠 Memory Channel
        // ===============================
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, MEMORY_CHANNEL)
            .setMethodCallHandler { call, result ->
                if (call.method == "getAvailableMemory") {
                    executor.execute {
                        try {
                            val memoryMB = getAvailableMemoryInMB()
                            mainHandler.post { result.success(memoryMB) }
                        } catch (e: Exception) {
                            mainHandler.post {
                                result.error("ERROR", "Failed: ${e.message}", null)
                            }
                        }
                    }
                } else result.notImplemented()
            }

        // ===============================
        // ⚙️ Background Service Channel
        // ===============================
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, BACKGROUND_SERVICE_CHANNEL)
            .setMethodCallHandler { call, result ->
                when (call.method) {
                    "startService" -> {
                        val title = call.argument<String>("notification-title")
                        val des = call.argument<String>("notification-des")
                        val intent = Intent(this, ForegroundService::class.java)
                        intent.putExtra("notification-title", title)
                        intent.putExtra("notification-des", des)
                        startService(intent)
                        result.success("Started!")
                    }

                    "hideNotification" -> {
                        val intent = Intent(ForegroundService.ACTION_HIDE_NOTIFICATION)
                        sendBroadcast(intent)
                        result.success("Notification Hidden")
                    }

                    "stopService" -> {
                        stopService(Intent(this, ForegroundService::class.java))
                        result.success("Stopped!")
                    }

                    else -> result.notImplemented()
                }
            }

        // ===============================
        // 🎧 Room Service Channel (app-kill cleanup + background audio)
        // ===============================
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, ROOM_SERVICE_CHANNEL)
            .setMethodCallHandler { call, result ->
                when (call.method) {
                    "startRoomService" -> {
                        val roomId = call.argument<String>("room_id") ?: ""
                        val token = call.argument<String>("token") ?: ""
                        val lang = call.argument<String>("language_code") ?: "en"
                        val roomType = call.argument<String>("room_type") ?: "audio"
                        val apiBaseUrl = call.argument<String>("api_base_url") ?: ""

                        // Persist credentials so onTaskRemoved can POST quit_room
                        // after the Dart isolate is gone. api_base_url is the
                        // runtime backend base (white-label) used to build the URL.
                        getSharedPreferences("room_prefs", Context.MODE_PRIVATE)
                            .edit()
                            .putString("room_id", roomId)
                            .putString("room_token", token)
                            .putString("room_language_code", lang)
                            .putString("room_type", roomType)
                            .putString("api_base_url", apiBaseUrl)
                            .apply()

                        // Start the mediaPlayback foreground service to keep the
                        // process alive (and audio playing) while backgrounded.
                        val intent = Intent(this, ForegroundService::class.java)
                        startService(intent)
                        result.success("Room service started")
                    }

                    "stopRoomService" -> {
                        getSharedPreferences("room_prefs", Context.MODE_PRIVATE)
                            .edit()
                            .clear()
                            .apply()
                        stopService(Intent(this, ForegroundService::class.java))
                        result.success("Room service stopped")
                    }

                    else -> result.notImplemented()
                }
            }

        // ===============================
        // 📁 File Picker Channel
        // ===============================
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, FILE_PICKER_CHANNEL)
            .setMethodCallHandler { call, result ->
                if (call.method == "pickFile") {
                    // Reply to any previous pending pick so its Result is never
                    // left unanswered (and never replied to twice later).
                    pendingFilePickerResult?.success(null)
                    pendingFilePickerResult = result
                    val intent = Intent(Intent.ACTION_GET_CONTENT)
                    intent.type = "image/*"
                    intent.addCategory(Intent.CATEGORY_OPENABLE)
                    intent.putExtra(Intent.EXTRA_ALLOW_MULTIPLE, false)
                    startActivityForResult(Intent.createChooser(intent, "Select Image"), PICK_FILE_REQUEST)
                } else {
                    result.notImplemented()
                }
            }

        // ===============================
        // 🎤 Voice FX (room Mixer: music effect / EQ / voice changer)
        // ===============================
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, VOICE_FX_CHANNEL)
            .setMethodCallHandler { call, result ->
                when (call.method) {
                    "set" -> {
                        VoiceFxProcessor.configure(
                            music = call.argument<Int>("music") ?: 0,
                            eq = call.argument<Int>("eq") ?: 0,
                            voice = call.argument<Int>("voice") ?: 0,
                        )
                        // false until the room's WebRTC engine exists; Dart
                        // retries after joining.
                        result.success(VoiceFxProcessor.attach())
                    }
                    else -> result.notImplemented()
                }
            }
    }

    // ===============================
    // 📁 File Picker Result Handler
    // ===============================
    override fun onActivityResult(requestCode: Int, resultCode: Int, data: Intent?) {
        super.onActivityResult(requestCode, resultCode, data)

        if (requestCode == PICK_FILE_REQUEST) {
            // Detach the pending result before replying so a duplicate
            // onActivityResult delivery can never reply to the same Result twice
            // (which throws IllegalStateException: Reply already submitted).
            val pending = pendingFilePickerResult
            pendingFilePickerResult = null
            if (pending != null) {
                if (resultCode == Activity.RESULT_OK && data != null) {
                    pending.success(data.data?.toString())
                } else {
                    pending.success(null)
                }
            }
        }
    }

    // ==================================
    // PiP state change notification to Flutter
    override fun onPictureInPictureModeChanged(isInPiP: Boolean, newConfig: Configuration) {
        super.onPictureInPictureModeChanged(isInPiP, newConfig)
        flutterEngine?.dartExecutor?.binaryMessenger?.let { messenger ->
            MethodChannel(messenger, PIP_STATE_CHANNEL)
                .invokeMethod(if (isInPiP) "enteredPiP" else "exitedPiP", null)
        }
    }

    private fun getAvailableMemoryInMB(): Int {
        val mgr = getSystemService(ACTIVITY_SERVICE) as ActivityManager
        val info = ActivityManager.MemoryInfo()
        mgr.getMemoryInfo(info)
        return (info.availMem / 1024 / 1024).toInt()
    }

    override fun onDestroy() {
        super.onDestroy()
        stopService(Intent(this, ForegroundService::class.java))
    }
}
