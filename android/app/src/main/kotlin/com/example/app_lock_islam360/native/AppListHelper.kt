package com.example.app_lock_islam360.native

import android.content.pm.ApplicationInfo
import android.content.pm.PackageManager
import android.graphics.Bitmap
import android.graphics.drawable.BitmapDrawable
import android.graphics.drawable.Drawable
import android.util.Base64
import java.io.ByteArrayOutputStream

/**
 * Native Android helper to get installed apps using PackageManager
 * This replaces the broken device_apps package
 */
class AppListHelper(private val packageManager: PackageManager) {

    /**
     * Get all installed applications
     * @param includeSystemApps Whether to include system apps
     * @return List of app information maps
     */
    fun getInstalledApps(includeSystemApps: Boolean = false): List<Map<String, Any?>> {
        val apps = mutableListOf<Map<String, Any?>>()
        
        try {
            val packages = packageManager.getInstalledPackages(
                PackageManager.GET_META_DATA or PackageManager.GET_ACTIVITIES
            )

            for (packageInfo in packages) {
                val appInfo = packageInfo.applicationInfo ?: continue
                
                // Filter system apps if needed
                if (!includeSystemApps && (appInfo.flags and ApplicationInfo.FLAG_SYSTEM) != 0) {
                    continue
                }

                // Skip if no launch intent
                val launchIntent = packageManager.getLaunchIntentForPackage(packageInfo.packageName)
                if (launchIntent == null) {
                    continue
                }

                val appName = packageManager.getApplicationLabel(appInfo).toString()
                val icon = packageManager.getApplicationIcon(packageInfo.packageName)
                val iconBase64 = drawableToBase64(icon)

                apps.add(mapOf(
                    "packageName" to packageInfo.packageName,
                    "appName" to appName,
                    "iconBase64" to iconBase64,
                    "isSystemApp" to ((appInfo.flags and ApplicationInfo.FLAG_SYSTEM) != 0),
                    "versionName" to (packageInfo.versionName ?: ""),
                    "versionCode" to packageInfo.longVersionCode
                ))
            }
        } catch (e: Exception) {
            e.printStackTrace()
        }

        return apps
    }

    /**
     * Search apps by name
     */
    fun searchApps(query: String, includeSystemApps: Boolean = false): List<Map<String, Any?>> {
        val allApps = getInstalledApps(includeSystemApps)
        if (query.isEmpty()) {
            return allApps
        }

        val lowerQuery = query.lowercase()
        return allApps.filter { 
            (it["appName"] as? String)?.lowercase()?.contains(lowerQuery) == true
        }
    }

    /**
     * Get app by package name
     */
    fun getAppByPackageName(packageName: String): Map<String, Any?>? {
        return try {
            val packageInfo = packageManager.getPackageInfo(packageName, 0)
            val appInfo = packageInfo.applicationInfo ?: return null
            val appName = packageManager.getApplicationLabel(appInfo).toString()
            val icon = packageManager.getApplicationIcon(packageName)
            val iconBase64 = drawableToBase64(icon)

            mapOf(
                "packageName" to packageName,
                "appName" to appName,
                "iconBase64" to iconBase64,
                "isSystemApp" to ((appInfo.flags and ApplicationInfo.FLAG_SYSTEM) != 0),
                "versionName" to (packageInfo.versionName ?: ""),
                "versionCode" to packageInfo.longVersionCode
            )
        } catch (e: Exception) {
            null
        }
    }

    /**
     * Convert Drawable to Base64 string for Flutter
     */
    private fun drawableToBase64(drawable: Drawable): String? {
        return try {
            val bitmap = when (drawable) {
                is BitmapDrawable -> drawable.bitmap
                else -> {
                    val bitmap = Bitmap.createBitmap(
                        drawable.intrinsicWidth,
                        drawable.intrinsicHeight,
                        Bitmap.Config.ARGB_8888
                    )
                    val canvas = android.graphics.Canvas(bitmap)
                    drawable.setBounds(0, 0, canvas.width, canvas.height)
                    drawable.draw(canvas)
                    bitmap
                }
            }

            val outputStream = ByteArrayOutputStream()
            bitmap.compress(Bitmap.CompressFormat.PNG, 100, outputStream)
            val byteArray = outputStream.toByteArray()
            Base64.encodeToString(byteArray, Base64.NO_WRAP)
        } catch (e: Exception) {
            null
        }
    }
}
