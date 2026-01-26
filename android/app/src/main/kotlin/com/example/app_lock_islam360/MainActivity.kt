package com.example.app_lock_islam360

import android.app.NotificationChannel
import android.app.NotificationManager
import android.os.Build
import android.os.Bundle
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
import com.example.app_lock_islam360.native.AppListHelper
import com.example.app_lock_islam360.native.AppMonitorHelper
import com.example.app_lock_islam360.native.OverlayHelper

class MainActivity : FlutterActivity() {
    private val CHANNEL = "com.example.app_lock_islam360/native"

    private lateinit var appListHelper: AppListHelper
    private lateinit var appMonitorHelper: AppMonitorHelper
    private lateinit var overlayHelper: OverlayHelper
    private lateinit var accessibilityHelper: com.example.app_lock_islam360.native.AccessibilityHelper

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        // Create notification channel for foreground service (required for Android 8.0+)
        createNotificationChannel()

        // Initialize native helpers
        appListHelper = AppListHelper(packageManager)
        appMonitorHelper = AppMonitorHelper(this)
        overlayHelper = OverlayHelper(this)
        accessibilityHelper = com.example.app_lock_islam360.native.AccessibilityHelper(this)

        // Set up MethodChannel
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL).setMethodCallHandler { call, result ->
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

                else -> {
                    result.notImplemented()
                }
            }
        }
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
