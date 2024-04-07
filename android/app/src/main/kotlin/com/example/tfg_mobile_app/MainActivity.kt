package com.example.tfg_mobile_app

import android.content.pm.PackageInfo
import android.content.pm.PackageManager
import android.content.pm.PermissionInfo

class AppPermissionsManager {
    companion object {
        fun getPermissionsForPackage(packageName: String, packageManager: PackageManager): List<String> {
            val permissions = mutableListOf<String>()
            try {
                val packageInfo: PackageInfo = packageManager.getPackageInfo(packageName, PackageManager.GET_PERMISSIONS)
                packageInfo.requestedPermissions?.forEach { permission ->
                    try {
                        val permissionInfo: PermissionInfo? = packageManager.getPermissionInfo(permission, 0)
                        permissionInfo?.name?.let { permissions.add(it) }
                    } catch (e: PackageManager.NameNotFoundException) {
                        e.printStackTrace()
                    }
                }
            } catch (e: PackageManager.NameNotFoundException) {
                e.printStackTrace()
            }
            return permissions
        }
    }
}

