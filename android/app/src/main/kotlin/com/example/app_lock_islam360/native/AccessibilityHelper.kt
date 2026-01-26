package com.example.app_lock_islam360.native

import android.accessibilityservice.AccessibilityServiceInfo
import android.content.Context
import android.content.Intent
import android.provider.Settings
import android.util.Log
import android.view.accessibility.AccessibilityManager

/**
 * Helper class to manage Accessibility Service for app locking
 */
class AccessibilityHelper(private val context: Context) {

    companion object {
        private const val TAG = "AccessibilityHelper"
        private const val PREFS_NAME = "app_lock_prefs"
        private const val KEY_LOCKED_APPS = "locked_apps"
        private const val KEY_LOCK_ENABLED = "lock_enabled"
        private const val KEY_UNLOCKED_APPS = "unlocked_apps" // Set of currently unlocked apps (no time limit)
    }

    /**
     * Check if Accessibility Service is enabled
     */
    fun isAccessibilityServiceEnabled(): Boolean {
        val accessibilityManager = context.getSystemService(Context.ACCESSIBILITY_SERVICE) as? AccessibilityManager
        val enabledServices = accessibilityManager?.getEnabledAccessibilityServiceList(AccessibilityServiceInfo.FEEDBACK_ALL_MASK)
        
        val serviceName = "${context.packageName}/${AppLockAccessibilityService::class.java.name}"
        val isEnabled = enabledServices?.any { 
            it.resolveInfo.serviceInfo.name == AppLockAccessibilityService::class.java.name 
        } ?: false
        
        Log.d(TAG, "Accessibility Service enabled: $isEnabled")
        return isEnabled
    }

    /**
     * Request Accessibility Service permission (opens settings)
     */
    fun requestAccessibilityServicePermission() {
        Log.d(TAG, "Requesting Accessibility Service permission...")
        val intent = Intent(Settings.ACTION_ACCESSIBILITY_SETTINGS)
        intent.flags = Intent.FLAG_ACTIVITY_NEW_TASK
        context.startActivity(intent)
    }

    /**
     * Update locked apps list in SharedPreferences
     * This is used by the Accessibility Service to check which apps are locked
     */
    fun updateLockedApps(lockedApps: Set<String>) {
        val prefs = context.getSharedPreferences(PREFS_NAME, Context.MODE_PRIVATE)
        // Convert Kotlin Set to MutableSet for SharedPreferences (putStringSet expects MutableSet)
        val mutableSet = lockedApps.toMutableSet()
        prefs.edit()
            .putStringSet(KEY_LOCKED_APPS, mutableSet)
            .apply()
        Log.d(TAG, "Updated locked apps list: $lockedApps (${lockedApps.size} apps)")
    }

    /**
     * Update lock enabled state
     */
    fun updateLockEnabled(enabled: Boolean) {
        val prefs = context.getSharedPreferences(PREFS_NAME, Context.MODE_PRIVATE)
        prefs.edit()
            .putBoolean(KEY_LOCK_ENABLED, enabled)
            .apply()
        Log.d(TAG, "Updated lock enabled state: $enabled")
    }

    /**
     * Get current locked apps list
     */
    fun getLockedApps(): Set<String> {
        val prefs = context.getSharedPreferences(PREFS_NAME, Context.MODE_PRIVATE)
        // getStringSet returns MutableSet<String>?, convert to immutable Set
        val mutableSet = prefs.getStringSet(KEY_LOCKED_APPS, null)
        return mutableSet?.toSet() ?: emptySet()
    }

    /**
     * Get current lock enabled state
     */
    fun isLockEnabled(): Boolean {
        val prefs = context.getSharedPreferences(PREFS_NAME, Context.MODE_PRIVATE)
        return prefs.getBoolean(KEY_LOCK_ENABLED, false)
    }

    /**
     * Unlock an app (stays unlocked while app is in use, locks again when app is killed/resumed)
     * @param packageName The package to unlock
     */
    fun unlockApp(packageName: String) {
        val prefs = context.getSharedPreferences(PREFS_NAME, Context.MODE_PRIVATE)
        val unlockedApps = prefs.getStringSet(KEY_UNLOCKED_APPS, null)?.toMutableSet() ?: mutableSetOf()
        unlockedApps.add(packageName)
        
        prefs.edit()
            .putStringSet(KEY_UNLOCKED_APPS, unlockedApps)
            .apply()
        
        Log.d(TAG, "Unlocked $packageName - will stay unlocked while in use")
    }

    /**
     * Check if an app is currently unlocked
     * @param packageName The package to check
     * @return true if app is unlocked
     */
    fun isUnlocked(packageName: String): Boolean {
        val prefs = context.getSharedPreferences(PREFS_NAME, Context.MODE_PRIVATE)
        val unlockedApps = prefs.getStringSet(KEY_UNLOCKED_APPS, null) ?: return false
        val isUnlocked = unlockedApps.contains(packageName)
        if (isUnlocked) {
            Log.d(TAG, "App $packageName is unlocked - allowing access")
        }
        return isUnlocked
    }

    /**
     * Lock an app again (remove from unlocked set)
     * Called when app goes to background or is killed
     * @param packageName The package to lock
     */
    fun lockApp(packageName: String) {
        val prefs = context.getSharedPreferences(PREFS_NAME, Context.MODE_PRIVATE)
        val unlockedApps = prefs.getStringSet(KEY_UNLOCKED_APPS, null)?.toMutableSet() ?: mutableSetOf()
        unlockedApps.remove(packageName)
        
        prefs.edit()
            .putStringSet(KEY_UNLOCKED_APPS, unlockedApps)
            .apply()
        
        Log.d(TAG, "Locked $packageName again - will show lock screen on next open")
    }
}
