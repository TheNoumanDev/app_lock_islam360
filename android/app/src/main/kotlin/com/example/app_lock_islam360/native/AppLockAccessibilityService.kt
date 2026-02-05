package com.example.app_lock_islam360.native

import android.accessibilityservice.AccessibilityService
import android.accessibilityservice.AccessibilityServiceInfo
import android.content.pm.PackageManager
import android.util.Log
import android.view.accessibility.AccessibilityEvent
import android.content.SharedPreferences
import com.example.app_lock_islam360.MainActivity

/**
 * Accessibility Service to intercept app launches and show lock screen
 * This provides faster, more reliable app locking than UsageStats polling
 */
class AppLockAccessibilityService : AccessibilityService() {

    companion object {
        private const val TAG = "AppLockAccessibility"
        private const val PREFS_NAME = "app_lock_prefs"
        private const val KEY_LOCKED_APPS = "locked_apps"
        private const val KEY_LOCK_ENABLED = "lock_enabled"
    }

    private var overlayHelper: OverlayHelper? = null
    private var lastLockedAppPackage: String? = null
    private var lastLockTime: Long = 0
    private val COOLDOWN_PERIOD_MS = 3000L // 3 seconds cooldown
    private var lastForegroundPackage: String? = null // Track last foreground app to detect app switches

    override fun onServiceConnected() {
        super.onServiceConnected()
        Log.d(TAG, "✅ Accessibility Service connected")
        
        // Configure the service
        val info = AccessibilityServiceInfo().apply {
            eventTypes = AccessibilityEvent.TYPE_WINDOW_STATE_CHANGED
            feedbackType = AccessibilityServiceInfo.FEEDBACK_GENERIC
            flags = AccessibilityServiceInfo.FLAG_INCLUDE_NOT_IMPORTANT_VIEWS
            notificationTimeout = 0
            packageNames = null // Monitor all packages
        }
        setServiceInfo(info)
        
        // Initialize overlay helper
        overlayHelper = OverlayHelper(this)
        
        Log.d(TAG, "Accessibility Service configured and ready")
    }

    override fun onAccessibilityEvent(event: AccessibilityEvent?) {
        if (event == null) return
        
        // Only process window state changes
        if (event.eventType != AccessibilityEvent.TYPE_WINDOW_STATE_CHANGED) {
            return
        }

        val packageName = event.packageName?.toString()
        if (packageName == null || packageName.isEmpty()) {
            return
        }

        // Skip our own app
        if (packageName == this.packageName) {
            return
        }

        Log.d(TAG, "Window state changed: $packageName")

        // Check if lock is enabled
        val prefs = getSharedPreferences(PREFS_NAME, MODE_PRIVATE)
        val isLockEnabled = prefs.getBoolean(KEY_LOCK_ENABLED, false)
        
        if (!isLockEnabled) {
            Log.d(TAG, "App lock is disabled, allowing $packageName")
            return
        }

        val accessibilityHelper = com.example.app_lock_islam360.native.AccessibilityHelper(this)

        // If a different app comes to foreground, lock the previous unlocked app
        // This handles the case when user switches away from an unlocked app
        if (lastForegroundPackage != null && lastForegroundPackage != packageName) {
            // Previous app went to background - lock it again if it was unlocked
            if (accessibilityHelper.isUnlocked(lastForegroundPackage!!)) {
                Log.d(TAG, "App $lastForegroundPackage went to background - locking it again")
                accessibilityHelper.lockApp(lastForegroundPackage!!)
            }
        }
        lastForegroundPackage = packageName

        // Get locked apps list (SharedPreferences returns MutableSet, convert to immutable Set)
        val mutableSet = prefs.getStringSet(KEY_LOCKED_APPS, null)
        val lockedAppsSet = mutableSet?.toSet() ?: emptySet()
        
        // Check if app is currently unlocked (stays unlocked while in use)
        if (accessibilityHelper.isUnlocked(packageName)) {
            Log.d(TAG, "App $packageName is unlocked, allowing access")
            return
        }
        
        if (lockedAppsSet.contains(packageName)) {
            // PRIMARY CHECK: Skip if overlay is already showing for this specific package
            if (overlayHelper?.isOverlayShowingForPackage(packageName) == true) {
                Log.d(TAG, "Overlay already showing for $packageName, skipping duplicate lock")
                return
            }
            
            // SECONDARY CHECK: Cooldown as backup (in case overlay state check fails)
            val currentTime = System.currentTimeMillis()
            if (packageName == lastLockedAppPackage && (currentTime - lastLockTime < COOLDOWN_PERIOD_MS)) {
                Log.d(TAG, "App $packageName was recently locked (cooldown), skipping to prevent duplicate")
                return
            }
            
            Log.d(TAG, "🔒 LOCKED APP DETECTED via Accessibility: $packageName")

            // Get app name from PackageManager
            val appName = try {
                val pm = packageManager
                val appInfo = pm.getApplicationInfo(packageName, 0)
                pm.getApplicationLabel(appInfo).toString()
            } catch (e: Exception) {
                // Fallback to package name if we can't get app name
                packageName.split(".").lastOrNull() ?: packageName
            }

            lastLockedAppPackage = packageName
            lastLockTime = currentTime

            // Try to trigger Flutter lock screen first (preferred - has better UI)
            if (MainActivity.isFlutterReady()) {
                Log.d(TAG, "📱 Triggering Flutter lock screen for $packageName ($appName)")
                MainActivity.triggerFlutterLockScreen(packageName, appName)
            } else {
                // Fallback to native overlay if Flutter app is not running
                Log.d(TAG, "Flutter not ready, using native overlay for $packageName")
                overlayHelper?.let { helper ->
                    if (helper.hasOverlayPermission()) {
                        helper.showLockScreen(appName, packageName)
                        Log.d(TAG, "✅ Native lock screen shown for $packageName ($appName)")
                    } else {
                        Log.w(TAG, "⚠️ Cannot show lock screen: No overlay permission")
                    }
                }
            }
        } else {
            Log.d(TAG, "App $packageName is not locked, allowing access")
        }
    }


    override fun onInterrupt() {
        Log.d(TAG, "Accessibility Service interrupted")
    }

    override fun onDestroy() {
        super.onDestroy()
        Log.d(TAG, "Accessibility Service destroyed")
        overlayHelper = null
    }
}
