package com.example.app_lock_islam360

import android.Manifest
import android.app.NotificationChannel
import android.app.NotificationManager
import android.content.Context
import android.content.Intent
import android.content.pm.PackageManager
import android.os.Build
import android.os.Bundle
import android.os.Handler
import android.os.Looper
import android.util.Log
import androidx.core.app.ActivityCompat
import androidx.core.content.ContextCompat
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
import com.example.app_lock_islam360.native.AppListHelper
import com.example.app_lock_islam360.native.AppMonitorHelper
import com.example.app_lock_islam360.native.OverlayHelper

class MainActivity : FlutterActivity() {
    private val CHANNEL = "com.example.app_lock_islam360/native"
    private val TAG = "MainActivity"
    private val NOTIFICATION_PERMISSION_REQUEST_CODE = 1001

    private lateinit var appListHelper: AppListHelper
    private lateinit var appMonitorHelper: AppMonitorHelper
    private lateinit var overlayHelper: OverlayHelper
    private lateinit var accessibilityHelper: com.example.app_lock_islam360.native.AccessibilityHelper

    companion object {
        // Static reference to the Flutter MethodChannel for reverse communication (Native → Flutter)
        private var flutterChannel: MethodChannel? = null
        private var appContext: Context? = null
        private val mainHandler = Handler(Looper.getMainLooper())

        // Pending lock screen data (used when activity needs to be launched first)
        private var pendingPackageName: String? = null
        private var pendingAppName: String? = null

        /**
         * Trigger Flutter lock screen from Accessibility Service
         * Called when a locked app is detected
         * This will bring the Flutter Activity to foreground and then navigate to lock screen
         */
        fun triggerFlutterLockScreen(packageName: String, appName: String) {
            Log.d("MainActivity", "Triggering Flutter lock screen for $packageName ($appName)")

            // Store pending data
            pendingPackageName = packageName
            pendingAppName = appName

            // If Flutter channel is available, invoke it directly and bring activity to front
            if (appContext != null) {
                // Launch the activity to bring it to foreground IMMEDIATELY
                // These flags ensure the activity comes to front and stays there
                val intent = Intent(appContext, MainActivity::class.java).apply {
                    flags = Intent.FLAG_ACTIVITY_NEW_TASK or
                            Intent.FLAG_ACTIVITY_CLEAR_TOP or
                            Intent.FLAG_ACTIVITY_SINGLE_TOP
                    addFlags(Intent.FLAG_ACTIVITY_EXCLUDE_FROM_RECENTS)
                    putExtra("LOCK_PACKAGE_NAME", packageName)
                    putExtra("LOCK_APP_NAME", appName)
                }
                appContext?.startActivity(intent)
                Log.d("MainActivity", "Started activity intent for lock screen")
            } else {
                Log.w("MainActivity", "App context not available, cannot show lock screen")
            }
        }

        /**
         * Check if we can trigger Flutter lock screen
         * Just need the app context - the activity will be launched and Flutter will initialize
         */
        fun isFlutterReady(): Boolean = appContext != null

        /**
         * Get pending lock screen data (if any)
         */
        fun getPendingLockData(): Pair<String?, String?> = Pair(pendingPackageName, pendingAppName)

        /**
         * Clear pending lock data
         */
        fun clearPendingLockData() {
            pendingPackageName = null
            pendingAppName = null
        }
    }

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        // Create notification channel for foreground service (required for Android 8.0+)
        createNotificationChannel()

        // Store app context for static access
        appContext = applicationContext

        // Initialize native helpers
        appListHelper = AppListHelper(packageManager)
        appMonitorHelper = AppMonitorHelper(this)
        overlayHelper = OverlayHelper(this)
        accessibilityHelper = com.example.app_lock_islam360.native.AccessibilityHelper(this)

        // Set up MethodChannel and store reference for reverse communication
        val channel = MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL)
        flutterChannel = channel // Store static reference

        // Check if there's pending lock screen data (from accessibility service)
        // This handles the case when activity was not running and was freshly started
        val pendingData = getPendingLockData()
        if (pendingData.first != null && pendingData.second != null) {
            Log.d(TAG, "Found pending lock data, sending to Flutter: ${pendingData.first} (${pendingData.second})")
            mainHandler.postDelayed({
                flutterChannel?.invokeMethod("showLockScreen", mapOf(
                    "packageName" to pendingData.first,
                    "appName" to pendingData.second
                ))
                clearPendingLockData()
            }, 500) // Give Flutter a moment to fully initialize
        }

        // Also check the intent that started this activity
        handleLockScreenIntent(intent)

        channel.setMethodCallHandler { call, result ->
            when (call.method) {
                // App List Methods
                "getInstalledApps" -> {
                    try {
                        val includeSystemApps = call.argument<Boolean>("includeSystemApps") ?: false
                        val apps = appListHelper.getInstalledApps(includeSystemApps)
                        result.success(apps)
                    } catch (e: Exception) {
                        result.error("GET_APPS_ERROR", e.message, null)
                    }
                }
                "searchApps" -> {
                    try {
                        val query = call.argument<String>("query") ?: ""
                        val includeSystemApps = call.argument<Boolean>("includeSystemApps") ?: false
                        val apps = appListHelper.searchApps(query, includeSystemApps)
                        result.success(apps)
                    } catch (e: Exception) {
                        result.error("SEARCH_APPS_ERROR", e.message, null)
                    }
                }
                "getAppByPackageName" -> {
                    try {
                        val packageName = call.argument<String>("packageName")
                        if (packageName != null) {
                            val app = appListHelper.getAppByPackageName(packageName)
                            result.success(app)
                        } else {
                            result.error("INVALID_ARGUMENT", "packageName is required", null)
                        }
                    } catch (e: Exception) {
                        result.error("GET_APP_ERROR", e.message, null)
                    }
                }

                // App Monitor Methods
                "hasUsageStatsPermission" -> {
                    result.success(appMonitorHelper.hasUsageStatsPermission())
                }
                "requestUsageStatsPermission" -> {
                    appMonitorHelper.requestUsageStatsPermission()
                    result.success(null)
                }
                "getForegroundAppPackageName" -> {
                    val packageName = appMonitorHelper.getForegroundAppPackageName()
                    result.success(packageName)
                }
                "isAppInForeground" -> {
                    val packageName = call.argument<String>("packageName")
                    if (packageName != null) {
                        result.success(appMonitorHelper.isAppInForeground(packageName))
                    } else {
                        result.error("INVALID_ARGUMENT", "packageName is required", null)
                    }
                }

                // Overlay Methods
                "hasOverlayPermission" -> {
                    result.success(overlayHelper.hasOverlayPermission())
                }
                "requestOverlayPermission" -> {
                    overlayHelper.requestOverlayPermission(this)
                    result.success(null)
                }
                "showLockScreen" -> {
                    try {
                        val appName = call.argument<String>("appName") ?: "App"
                        overlayHelper.showLockScreen(appName)
                        result.success(null)
                    } catch (e: SecurityException) {
                        result.error("OVERLAY_PERMISSION_DENIED", e.message ?: "Overlay permission not granted", null)
                    } catch (e: Exception) {
                        result.error("SHOW_OVERLAY_ERROR", e.message, null)
                    }
                }
                "closeOverlay" -> {
                    overlayHelper.closeOverlay()
                    result.success(null)
                }
                "isOverlayShowing" -> {
                    result.success(overlayHelper.isOverlayShowing())
                }

                // Accessibility Service Methods
                "isAccessibilityServiceEnabled" -> {
                    result.success(accessibilityHelper.isAccessibilityServiceEnabled())
                }
                "requestAccessibilityServicePermission" -> {
                    accessibilityHelper.requestAccessibilityServicePermission()
                    result.success(null)
                }
                "updateLockedAppsForAccessibility" -> {
                    try {
                        val appsList = call.argument<List<String>>("apps") ?: emptyList()
                        val appsSet: Set<String> = appsList.toSet()
                        accessibilityHelper.updateLockedApps(appsSet)
                        result.success(null)
                    } catch (e: Exception) {
                        result.error("UPDATE_APPS_ERROR", e.message, null)
                    }
                }
                "updateLockEnabledForAccessibility" -> {
                    try {
                        val enabled = call.argument<Boolean>("enabled") ?: false
                        accessibilityHelper.updateLockEnabled(enabled)
                        result.success(null)
                    } catch (e: Exception) {
                        result.error("UPDATE_ENABLED_ERROR", e.message, null)
                    }
                }

                // Lock Screen Methods
                "unlockAndContinue" -> {
                    try {
                        val packageName = call.argument<String>("packageName")
                        if (packageName != null) {
                            // Mark app as unlocked so user can use it
                            accessibilityHelper.unlockApp(packageName)
                            // Close any native overlay if showing
                            overlayHelper.closeOverlay()
                            Log.d(TAG, "Unlocked app: $packageName")
                            result.success(null)
                        } else {
                            result.error("INVALID_ARGUMENT", "packageName is required", null)
                        }
                    } catch (e: Exception) {
                        result.error("UNLOCK_ERROR", e.message, null)
                    }
                }
                "minimizeApp" -> {
                    // Move the activity to back to let user continue using the unlocked app
                    Log.d(TAG, "Minimizing app to return to locked app")
                    moveTaskToBack(true)
                    result.success(null)
                }

                // Notification Permission Methods (Android 13+)
                "hasNotificationPermission" -> {
                    val hasPermission = if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.TIRAMISU) {
                        ContextCompat.checkSelfPermission(
                            this,
                            Manifest.permission.POST_NOTIFICATIONS
                        ) == PackageManager.PERMISSION_GRANTED
                    } else {
                        // Notification permission not required before Android 13
                        true
                    }
                    result.success(hasPermission)
                }
                "requestNotificationPermission" -> {
                    if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.TIRAMISU) {
                        ActivityCompat.requestPermissions(
                            this,
                            arrayOf(Manifest.permission.POST_NOTIFICATIONS),
                            NOTIFICATION_PERMISSION_REQUEST_CODE
                        )
                    }
                    result.success(null)
                }

                else -> {
                    result.notImplemented()
                }
            }
        }
    }

    override fun onNewIntent(intent: Intent) {
        super.onNewIntent(intent)
        setIntent(intent)
        handleLockScreenIntent(intent)
    }

    private fun handleLockScreenIntent(intent: Intent?) {
        intent?.let {
            val packageName = it.getStringExtra("LOCK_PACKAGE_NAME")
            val appName = it.getStringExtra("LOCK_APP_NAME")
            if (packageName != null && appName != null) {
                Log.d(TAG, "Handling lock screen intent for $packageName ($appName)")

                // Clear the extras immediately so we don't handle them again
                // (e.g., when user opens app from recents or launcher)
                it.removeExtra("LOCK_PACKAGE_NAME")
                it.removeExtra("LOCK_APP_NAME")

                // Give Flutter a moment to be ready, then invoke
                mainHandler.postDelayed({
                    flutterChannel?.invokeMethod("showLockScreen", mapOf(
                        "packageName" to packageName,
                        "appName" to appName
                    ))
                }, 100)
            }
        }
    }

    override fun onDestroy() {
        super.onDestroy()
        // Clear flutter channel when activity is destroyed
        // BUT keep appContext - it's applicationContext which survives activity lifecycle
        flutterChannel = null
        // Note: Don't clear appContext - it's the application context and we need it
        // to launch the activity from the accessibility service
    }

    private fun createNotificationChannel() {
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
            val channelId = "app_lock_monitor"
            val channelName = "App Lock Monitor"
            val channelDescription = "Monitors apps to show lock screen when needed"
            val importance = NotificationManager.IMPORTANCE_LOW // Low importance to reduce notification noise
            
            val channel = NotificationChannel(channelId, channelName, importance).apply {
                description = channelDescription
                setShowBadge(false)
            }
            
            val notificationManager = getSystemService(NotificationManager::class.java)
            notificationManager.createNotificationChannel(channel)
        }
    }
}
