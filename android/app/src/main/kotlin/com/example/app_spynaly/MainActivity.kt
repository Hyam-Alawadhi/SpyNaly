package com.example.app_spynaly


import android.content.pm.PackageManager
import android.content.pm.ApplicationInfo
import android.os.Bundle
import io.flutter.embedding.android.FlutterActivity
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugins.GeneratedPluginRegistrant

class MainActivity: FlutterActivity() {
    private val CHANNEL = "app.permissions/scan"

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        GeneratedPluginRegistrant.registerWith(flutterEngine!!)

        MethodChannel(flutterEngine!!.dartExecutor, CHANNEL).setMethodCallHandler { call, result ->
            if (call.method == "getInstalledApps") {
                val apps = getInstalledApps()
                result.success(apps)
            } else {
                result.notImplemented()
            }
        }
    }

    private fun getInstalledApps(): List<Map<String, Any>> {
        val appsList = mutableListOf<Map<String, Any>>()
        val packageManager = packageManager
        val installedApps = packageManager.getInstalledApplications(PackageManager.GET_META_DATA)

        for (appInfo in installedApps) {
            val permissions = packageManager.getPackageInfo(appInfo.packageName, PackageManager.GET_PERMISSIONS).requestedPermissions
            val app = mapOf(
                "appName" to appInfo.loadLabel(packageManager).toString(),
                "packageName" to appInfo.packageName,
                "permissions" to permissions?.toList() ?: emptyList<String>()
            )
            appsList.add(app)
        }
        return appsList
    }
}
