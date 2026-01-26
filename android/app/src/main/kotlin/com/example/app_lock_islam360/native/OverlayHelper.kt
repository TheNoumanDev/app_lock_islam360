package com.example.app_lock_islam360.native

import android.app.Activity
import android.app.ActivityManager
import android.content.Context
import android.content.Intent
import android.net.Uri
import android.os.Build
import android.provider.Settings
import android.util.Log
import android.view.Gravity
import android.view.LayoutInflater
import android.view.View
import android.view.WindowManager
import android.widget.FrameLayout
import com.example.app_lock_islam360.R

/**
 * Native Android helper to show overlay windows for lock screen
 * This replaces the broken system_alert_window package
 */
class OverlayHelper(private val context: Context) {

    companion object {
        private const val TAG = "OverlayHelper"
        const val REQUEST_OVERLAY_PERMISSION = 1001
    }

    private var overlayView: View? = null
    private var windowManager: WindowManager? = null
    private var currentLockedPackage: String? = null // Track which package currently has overlay

    init {
        windowManager = context.getSystemService(Context.WINDOW_SERVICE) as? WindowManager
    }

    /**
     * Check if overlay permission is granted
     */
    fun hasOverlayPermission(): Boolean {
        val hasPermission = if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.M) {
            Settings.canDrawOverlays(context)
        } else {
            true // Permission not needed for older versions
        }
        Log.d(TAG, "hasOverlayPermission: $hasPermission")
        return hasPermission
    }

    /**
     * Request overlay permission (opens settings)
     */
    fun requestOverlayPermission(activity: Activity) {
        Log.d(TAG, "Requesting overlay permission...")
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.M) {
            val intent = Intent(
                Settings.ACTION_MANAGE_OVERLAY_PERMISSION,
                Uri.parse("package:${context.packageName}")
            )
            activity.startActivityForResult(intent, REQUEST_OVERLAY_PERMISSION)
        }
    }

    /**
     * Show overlay window
     * @param view The view to display in overlay
     */
    fun showOverlay(view: View) {
        if (!hasOverlayPermission()) {
            return
        }

        closeOverlay() // Close any existing overlay

        val params = WindowManager.LayoutParams(
            WindowManager.LayoutParams.MATCH_PARENT,
            WindowManager.LayoutParams.MATCH_PARENT,
            if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
                WindowManager.LayoutParams.TYPE_APPLICATION_OVERLAY
            } else {
                @Suppress("DEPRECATION")
                WindowManager.LayoutParams.TYPE_PHONE
            },
            WindowManager.LayoutParams.FLAG_NOT_FOCUSABLE or
                    WindowManager.LayoutParams.FLAG_NOT_TOUCH_MODAL or
                    WindowManager.LayoutParams.FLAG_WATCH_OUTSIDE_TOUCH,
            android.graphics.PixelFormat.TRANSLUCENT
        ).apply {
            gravity = Gravity.CENTER
        }

        try {
            windowManager?.addView(view, params)
            overlayView = view
        } catch (e: Exception) {
            e.printStackTrace()
        }
    }

    /**
     * Show lock screen overlay with app name
     * @param appName The name of the locked app
     * @param packageName The package name of the locked app (for tracking)
     * @throws SecurityException if overlay permission is not granted
     */
    fun showLockScreen(appName: String, packageName: String? = null) {
        Log.d(TAG, "showLockScreen called for app: $appName")
        
        if (!hasOverlayPermission()) {
            val errorMsg = "Cannot show lock screen: No overlay permission. User must grant 'Display over other apps' permission."
            Log.e(TAG, errorMsg)
            throw SecurityException(errorMsg)
        }

        Log.d(TAG, "Closing any existing overlay...")
        closeOverlay() // Close any existing overlay

        Log.d(TAG, "Inflating lock screen layout...")
        // Inflate the lock screen layout
        val inflater = LayoutInflater.from(context)
        val view = inflater.inflate(R.layout.lock_screen_overlay, null)

        // Update the message with app name
        val messageView = view.findViewById<android.widget.TextView>(R.id.lockMessage)
        messageView?.text = "This app ($appName) is protected"
        Log.d(TAG, "Updated lock screen message for: $appName")

        // Set up unlock button to temporarily unlock the app
        val unlockButton = view.findViewById<android.widget.Button>(R.id.unlockButton)
        unlockButton?.setOnClickListener {
            Log.d(TAG, "Unlock button clicked for package: $packageName")
            
            // Unlock the app (stays unlocked while in use, locks again when app is killed/resumed)
            if (packageName != null) {
                val accessibilityHelper = com.example.app_lock_islam360.native.AccessibilityHelper(context)
                accessibilityHelper.unlockApp(packageName)
                Log.d(TAG, "Unlocked $packageName - app will stay unlocked while in use")
            }
            
            // Close overlay - app will now be accessible
            closeOverlay()
            Log.d(TAG, "Overlay closed - app is now accessible")
        }

        // Make the overlay block all touches
        view.setOnTouchListener { _, _ -> true }

        // Show the overlay with proper flags to block touches
        val params = WindowManager.LayoutParams(
            WindowManager.LayoutParams.MATCH_PARENT,
            WindowManager.LayoutParams.MATCH_PARENT,
            if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
                WindowManager.LayoutParams.TYPE_APPLICATION_OVERLAY
            } else {
                @Suppress("DEPRECATION")
                WindowManager.LayoutParams.TYPE_PHONE
            },
            WindowManager.LayoutParams.FLAG_LAYOUT_IN_SCREEN or
                    WindowManager.LayoutParams.FLAG_LAYOUT_INSET_DECOR or
                    WindowManager.LayoutParams.FLAG_NOT_TOUCH_MODAL or
                    WindowManager.LayoutParams.FLAG_WATCH_OUTSIDE_TOUCH,
            android.graphics.PixelFormat.TRANSLUCENT
        ).apply {
            gravity = Gravity.CENTER
        }

        try {
            Log.d(TAG, "Adding overlay view to WindowManager...")
            windowManager?.addView(view, params)
            overlayView = view
            currentLockedPackage = packageName // Track which package has overlay
            Log.d(TAG, "✅ Lock screen overlay shown successfully for package: $packageName")
        } catch (e: Exception) {
            Log.e(TAG, "❌ Error showing lock screen overlay: ${e.message}", e)
            e.printStackTrace()
        }
    }

    /**
     * Close overlay window
     */
    fun closeOverlay() {
        overlayView?.let { view ->
            try {
                val closedPackage = currentLockedPackage
                Log.d(TAG, "Closing overlay for package: $closedPackage")
                windowManager?.removeView(view)
                overlayView = null
                currentLockedPackage = null // Clear tracked package
                Log.d(TAG, "✅ Overlay closed successfully")
            } catch (e: Exception) {
                Log.e(TAG, "❌ Error closing overlay: ${e.message}", e)
                e.printStackTrace()
                // Clear state even on error
                overlayView = null
                currentLockedPackage = null
            }
        } ?: run {
            Log.d(TAG, "No overlay to close")
        }
    }

    /**
     * Check if overlay is currently showing
     */
    fun isOverlayShowing(): Boolean {
        val isShowing = overlayView != null
        Log.d(TAG, "isOverlayShowing: $isShowing (package: $currentLockedPackage)")
        return isShowing
    }

    /**
     * Check if overlay is showing for a specific package
     */
    fun isOverlayShowingForPackage(packageName: String): Boolean {
        val isShowing = overlayView != null && currentLockedPackage == packageName
        Log.d(TAG, "isOverlayShowingForPackage($packageName): $isShowing")
        return isShowing
    }
}
