package com.example.app_lock_islam360.native

import android.app.ActivityManager
import android.app.AppOpsManager
import android.app.usage.UsageEvents
import android.app.usage.UsageStats
import android.app.usage.UsageStatsManager
import android.content.Context
import android.content.Intent
import android.os.Build
import android.provider.Settings
import android.util.Log

/**
 * Native Android helper to monitor app usage and detect foreground app
 * This replaces the broken usage_stats package
 */
class AppMonitorHelper(private val context: Context) {

    private val usageStatsManager: UsageStatsManager? =
        context.getSystemService(Context.USAGE_STATS_SERVICE) as? UsageStatsManager

    companion object {
        private const val TAG = "AppMonitorHelper"
    }

    /**
     * Check if usage stats permission is granted
     * Uses AppOpsManager for proper permission check (more reliable)
     */
    fun hasUsageStatsPermission(): Boolean {
        if (usageStatsManager == null) {
            Log.d(TAG, "UsageStatsManager is null")
            return false
        }
        
        // Use AppOpsManager to check permission properly
        val appOps = context.getSystemService(Context.APP_OPS_SERVICE) as? AppOpsManager
        if (appOps != null) {
            val mode = appOps.checkOpNoThrow(
                AppOpsManager.OPSTR_GET_USAGE_STATS,
                android.os.Process.myUid(),
                context.packageName
            )
            val hasPermission = mode == AppOpsManager.MODE_ALLOWED
            Log.d(TAG, "hasUsageStatsPermission (AppOpsManager): $hasPermission (mode: $mode)")
            
            if (!hasPermission) {
                return false
            }
        } else {
            Log.w(TAG, "AppOpsManager is null, falling back to query check")
        }
        
        // Double-check by trying to query (some devices need this)
        val time = System.currentTimeMillis()
        val startTime = time - 60000 // Last 60 seconds - longer window
        
        return try {
            val stats = usageStatsManager.queryUsageStats(
                UsageStatsManager.INTERVAL_BEST,
                startTime,
                time
            )
            val hasData = stats != null && stats.isNotEmpty()
            Log.d(TAG, "hasUsageStatsPermission (query check): $hasData (stats count: ${stats?.size ?: 0})")
            hasData
        } catch (e: SecurityException) {
            Log.d(TAG, "hasUsageStatsPermission: false (SecurityException: ${e.message})")
            false
        } catch (e: Exception) {
            Log.e(TAG, "Error checking permission: ${e.message}", e)
            false
        }
    }

    /**
     * Request usage stats permission (opens settings)
     */
    fun requestUsageStatsPermission() {
        Log.d(TAG, "Requesting usage stats permission...")
        val intent = Intent(Settings.ACTION_USAGE_ACCESS_SETTINGS)
        intent.flags = Intent.FLAG_ACTIVITY_NEW_TASK
        context.startActivity(intent)
    }

    /**
     * Get current foreground app package name
     * Uses UsageEvents for real-time detection (more accurate than UsageStats)
     * Falls back to ActivityManager for Android < 10
     * @return Package name of the foreground app, or null if not available
     */
    fun getForegroundAppPackageName(): String? {
        if (usageStatsManager == null) {
            Log.d(TAG, "UsageStatsManager is null")
            // Try ActivityManager fallback for older Android
            return getForegroundAppViaActivityManager()
        }

        if (!hasUsageStatsPermission()) {
            Log.d(TAG, "No usage stats permission, trying ActivityManager fallback...")
            return getForegroundAppViaActivityManager()
        }

        val time = System.currentTimeMillis()
        // Use longer time window - UsageStats might have delay
        val startTime = time - 30000 // Last 30 seconds
        
        // Try using UsageEvents first (more accurate for real-time detection)
        try {
            val events = usageStatsManager.queryEvents(startTime, time)
            var lastForegroundEvent: UsageEvents.Event? = null
            var eventCount = 0
            
            // Iterate through events to find the most recent MOVE_TO_FOREGROUND
            while (events.hasNextEvent()) {
                val event = UsageEvents.Event()
                if (events.getNextEvent(event)) {
                    eventCount++
                    if (event.eventType == UsageEvents.Event.MOVE_TO_FOREGROUND) {
                        lastForegroundEvent = event
                        Log.d(TAG, "Found MOVE_TO_FOREGROUND event for: ${event.packageName}")
                    }
                }
            }
            
            Log.d(TAG, "Total events found: $eventCount")
            
            if (lastForegroundEvent != null) {
                val packageName = lastForegroundEvent.packageName
                val timeSinceEvent = time - lastForegroundEvent.timeStamp
                Log.d(TAG, "Found foreground app via UsageEvents: $packageName (${timeSinceEvent}ms ago)")
                
                // Return if event was recent (within last 10 seconds - more lenient)
                if (timeSinceEvent < 10000) {
                    return packageName
                } else {
                    Log.d(TAG, "Event too old (${timeSinceEvent}ms), trying UsageStats fallback...")
                }
            } else {
                Log.d(TAG, "No MOVE_TO_FOREGROUND events found in $eventCount events, trying UsageStats...")
            }
        } catch (e: SecurityException) {
            Log.e(TAG, "SecurityException querying UsageEvents - no permission: ${e.message}")
            return null
        } catch (e: Exception) {
            Log.e(TAG, "Error querying UsageEvents: ${e.message}", e)
        }

        // Fallback to UsageStats with longer time window
        try {
            val stats = usageStatsManager.queryUsageStats(
                UsageStatsManager.INTERVAL_BEST,
                startTime,
                time
            )

            if (stats == null || stats.isEmpty()) {
                Log.d(TAG, "Usage stats list is empty or null")
                return null
            }

            Log.d(TAG, "Found ${stats.size} usage stats entries")
            
            // Log all apps for debugging
            stats.forEach { stat ->
                Log.d(TAG, "  - ${stat.packageName}: lastUsed=${stat.lastTimeUsed}, totalTime=${stat.totalTimeInForeground}")
            }
            
            // Find the most recently used app (highest lastTimeUsed)
            var mostRecent: UsageStats? = null
            for (usageStats in stats) {
                // Filter out our own app
                if (usageStats.packageName == context.packageName) {
                    continue
                }
                
                if (mostRecent == null || usageStats.lastTimeUsed > mostRecent.lastTimeUsed) {
                    mostRecent = usageStats
                }
            }

            if (mostRecent == null) {
                Log.d(TAG, "No recent app found (all might be our own app)")
                return null
            }

            val packageName = mostRecent.packageName
            val lastTimeUsed = mostRecent.lastTimeUsed
            val timeSinceUsed = time - lastTimeUsed
            
            Log.d(TAG, "Most recent app via UsageStats: $packageName (last used ${timeSinceUsed}ms ago)")
            
            // Return if app was used recently (within last 10 seconds - more lenient)
            if (timeSinceUsed < 10000) {
                return packageName
            } else {
                Log.d(TAG, "App was used too long ago (${timeSinceUsed}ms), might not be foreground")
                return null
            }
        } catch (e: SecurityException) {
            Log.e(TAG, "SecurityException querying UsageStats - no permission: ${e.message}")
            return null
        } catch (e: Exception) {
            Log.e(TAG, "Error querying UsageStats: ${e.message}", e)
            return null
        }
    }

    /**
     * Check if a specific package is currently in foreground
     */
    fun isAppInForeground(packageName: String): Boolean {
        return getForegroundAppPackageName() == packageName
    }

    /**
     * Fallback method using ActivityManager (deprecated but works on some devices)
     * Only works for Android < 10 or if UsageStats fails
     */
    @Suppress("DEPRECATION")
    private fun getForegroundAppViaActivityManager(): String? {
        return try {
            val activityManager = context.getSystemService(Context.ACTIVITY_SERVICE) as? ActivityManager
            if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.Q) {
                // Android 10+ - getRunningTasks is restricted
                Log.d(TAG, "ActivityManager.getRunningTasks not available on Android 10+")
                null
            } else {
                val tasks = activityManager?.getRunningTasks(1)
                val topTask = tasks?.firstOrNull()
                val packageName = topTask?.topActivity?.packageName
                Log.d(TAG, "Foreground app via ActivityManager: $packageName")
                packageName
            }
        } catch (e: Exception) {
            Log.e(TAG, "Error getting foreground app via ActivityManager: ${e.message}", e)
            null
        }
    }
}
