package com.example.tfg_mobile_app

import android.annotation.SuppressLint
import android.content.pm.PackageManager
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
import android.provider.Settings

class MainActivity : FlutterActivity() {

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        val channel = MethodChannel(flutterEngine.dartExecutor.binaryMessenger, "flutter_channel")

        channel.setMethodCallHandler { call, result ->
            when (call.method) {
                "getAppPermissionStatuses" -> {
                    val permissions = getAppPermissionStatuses()
                    result.success(permissions)
                }
                "retrieveDeviceID" -> {
                    val idDevice = retrieveDeviceID()
                    result.success(idDevice)
                }
                "detectPermissionGroupChanges" ->{
                    val oldPermissions = call.argument<List<Map<String, Any>>>("oldPermissions")
                    val changes = detectPermissionGroupChanges(oldPermissions ?: emptyList())
                    result.success(changes)
                }
                "getAppPermissions" -> {
                    val permissions = getAppPermissions()
                    result.success(permissions)
                }
                "getPermissionsGroupStatus" -> {
                    val permissions = getPermissionsGroupStatus()
                    result.success(permissions)
                }
                else -> {
                    result.notImplemented()
                }
            }
        }
    }

    // Obtain permission group statuses for all installed applications

    private fun getAppPermissionStatuses(): List<Map<String, Any>> {
        val pm = packageManager
        val permissionGroupMap = mapOf(
            "ACTIVITY_RECOGNITION" to listOf(
                "android.permission.ACTIVITY_RECOGNITION"
            ),
            "CALENDAR" to listOf(
                "android.permission.READ_CALENDAR",
                "android.permission.WRITE_CALENDAR"
            ),
            "CALL_LOG" to listOf(
                "android.permission.READ_CALL_LOG",
                "android.permission.WRITE_CALL_LOG"
            ),
            "CAMERA" to listOf(
                "android.permission.CAMERA"
            ),
            "CONTACTS" to listOf(
                "android.permission.READ_CONTACTS",
                "android.permission.WRITE_CONTACTS",
                "android.permission.GET_ACCOUNTS"
            ),
            "LOCATION" to listOf(
                "android.permission.ACCESS_FINE_LOCATION",
                "android.permission.ACCESS_COARSE_LOCATION",
                "android.permission.ACCESS_BACKGROUND_LOCATION"
            ),
            "MICROPHONE" to listOf(
                "android.permission.RECORD_AUDIO"
            ),
            "NEARBY_DEVICES" to listOf(
                "android.permission.BLUETOOTH_CONNECT",
                "android.permission.BLUETOOTH_ADVERTISE",
                "android.permission.BLUETOOTH_SCAN",
                "android.permission.UWB_RANGING"
            ),
            "NOTIFICATIONS" to listOf(
                "android.permission.POST_NOTIFICATIONS"
            ),
            "PHONE" to listOf(
                "android.permission.READ_PHONE_STATE",
                "android.permission.READ_PHONE_NUMBERS",
                "android.permission.CALL_PHONE",
                "android.permission.READ_CALL_LOG",
                "android.permission.WRITE_CALL_LOG",
                "android.permission.ADD_VOICEMAIL",
                "android.permission.USE_SIP",
                "android.permission.PROCESS_OUTGOING_CALLS",
                "android.permission.ACCEPT_HANDOVER"
            ),
            "READ_MEDIA_AURAL" to listOf(
                "android.permission.READ_MEDIA_AUDIO"
            ),
            "READ_MEDIA_VISUAL" to listOf(
                "android.permission.ACCESS_MEDIA_LOCATION",
                "android.permission.READ_MEDIA_IMAGES",
                "android.permission.READ_MEDIA_VIDEO"
            ),
            "SENSORS" to listOf(
                "android.permission.BODY_SENSORS",
                "android.permission.BODY_SENSORS_BACKGROUND"
            ),
            "SMS" to listOf(
                "android.permission.SEND_SMS",
                "android.permission.RECEIVE_SMS",
                "android.permission.READ_SMS",
                "android.permission.RECEIVE_WAP_PUSH",
                "android.permission.RECEIVE_MMS"
            ),
            "STORAGE" to listOf(
                "android.permission.READ_EXTERNAL_STORAGE",
                "android.permission.WRITE_EXTERNAL_STORAGE"
            )
        )


        val alwaysActiveGroups = setOf("ACTIVITY_RECOGNITION", "CALENDAR", "CALL_LOG", "CONTACTS", "NEARBY_DEVICES", "NOTIFICATIONS", "PHONE", "READ_MEDIA_AURAL", "READ_MEDIA_VISUAL", "SENSORS", "SMS", "STORAGE")
        val inUseGroups = setOf("CAMERA", "MICROPHONE")

        val installedApps = pm.getInstalledApplications(0)
        val appPermissions = mutableListOf<Map<String, Any>>()

        for (app in installedApps) {
            val appPermissionStatus = mutableMapOf<String, Any>()
            appPermissionStatus["appName"] = app.loadLabel(pm).toString()
            appPermissionStatus["packageName"] = app.packageName

            val packageInfo = pm.getPackageInfo(app.packageName, PackageManager.GET_PERMISSIONS)
            val requestedPermissions = packageInfo.requestedPermissions?.toSet() ?: emptySet()

            val groupStatuses = mutableMapOf<String, String>()
            permissionGroupMap.forEach { (groupName, permissions) ->
                var isGranted = false
                var isDenied = false
                var allNotRequested = true
                var backgroundLocationGranted = false  // Variable to track the specific background location permission

                permissions.forEach { permission ->
                    if (requestedPermissions.contains(permission)) {
                        allNotRequested = false
                        val checkStatus = pm.checkPermission(permission, app.packageName)
                        if (checkStatus == PackageManager.PERMISSION_GRANTED) {
                            isGranted = true
                            if (permission == "android.permission.ACCESS_BACKGROUND_LOCATION") {
                                backgroundLocationGranted = true  // Only set this if the specific permission is granted
                            }
                        } else if (checkStatus == PackageManager.PERMISSION_DENIED) {
                            isDenied = true
                        }
                    }
                }

                val status = when {
                    groupName == "LOCATION" && backgroundLocationGranted -> "Always"
                    groupName == "LOCATION" && isGranted -> "While in use"
                    isGranted && alwaysActiveGroups.contains(groupName) -> "Always"
                    isGranted && inUseGroups.contains(groupName) -> "While in use"
                    isDenied -> "Denied"
                    allNotRequested -> "Not requested"
                    else -> "Unknown"
                }
                groupStatuses[groupName] = status
            }

            // Adjust "READ_MEDIA_AURAL" and "READ_MEDIA_VISUAL" permissions based on "STORAGE" for Android 12 or lower
            if (android.os.Build.VERSION.SDK_INT <= android.os.Build.VERSION_CODES.S && groupStatuses["STORAGE"] == "Always") {
                groupStatuses["READ_MEDIA_AURAL"] = "Always"
                groupStatuses["READ_MEDIA_VISUAL"] = "Always"
            }

            appPermissionStatus["permissionGroups"] = groupStatuses
            appPermissions.add(appPermissionStatus)
        }

        return appPermissions

    }

    // Detects changes in the permissions of the applications
    private fun detectPermissionGroupChanges(previousPermissions: List<Map<String, Any>>): List<String> {
        val pm = packageManager
        val actualPermissions = getAppPermissionStatuses()
        val changes = mutableListOf<String>()

        val previousPermissionsMap = previousPermissions.associateBy { it["packageName"] as String }
        val actualPermissionsMap = actualPermissions.associateBy { it["packageName"] as String }

        for ((packageName, actualPermissionStatus) in actualPermissionsMap) {
            if (previousPermissionsMap.containsKey(packageName)) {
                val previousGroups =
                    (previousPermissionsMap[packageName]?.get("permissionGroups") as Map<String, String>)
                val actualGroups = actualPermissionStatus["permissionGroups"] as Map<String, String>
                for ((groupName, actualStatus) in actualGroups) {
                    val previousStatus = previousGroups[groupName]
                    if (previousStatus != actualStatus) {
                        changes.add("$packageName,$groupName,$previousStatus,$actualStatus")
                    }
                }
            } else {
                val actualGroups = actualPermissionStatus["permissionGroups"] as Map<String, String>
                for ((groupName, actualStatus) in actualGroups) {
                    changes.add("$packageName,$groupName,null,$actualStatus")
                }
            }
        }

        for ((packageName, previousPermissionStatus) in previousPermissionsMap) {
            if (!actualPermissionsMap.containsKey(packageName)) {
                val previousGroups = previousPermissionStatus["permissionGroups"] as Map<String, String>
                for ((groupName, previousStatus) in previousGroups) {
                    changes.add("$packageName,$groupName,$previousStatus,null")
                }
            }
        }

        return changes
    }









    // Retrieves all permissions from all applications
    private fun getAppPermissions(): List<Map<String, Any>> {
        val pm = packageManager

        // Definir el mapa entre grupos de permisos y permisos concretos
        val permissionGroupMap = mapOf(
            "CALENDAR" to listOf(
                "android.permission.READ_CALENDAR",
                "android.permission.WRITE_CALENDAR"),

            "CAMERA" to listOf(
                "android.permission.CAMERA"),

            "CONTACTS" to listOf(
                "android.permission.READ_CONTACTS",
                "android.permission.WRITE_CONTACTS",
                "android.permission.GET_ACCOUNTS"),

            "LOCATION" to listOf(
                "android.permission.ACCESS_FINE_LOCATION",
                "android.permission.ACCESS_COARSE_LOCATION"),

            "MICROPHONE" to listOf(
                "android.permission.RECORD_AUDIO"),

            "PHONE" to listOf(
                "android.permission.READ_PHONE_STATE",
                "android.permission.CALL_PHONE",
                "android.permission.READ_CALL_LOG",
                "android.permission.WRITE_CALL_LOG",
                "android.permission.ADD_VOICEMAIL",
                "android.permission.USE_SIP",
                "android.permission.PROCESS_OUTGOING_CALLS"
            ),

            "SENSORS" to listOf("android.permission.BODY_SENSORS"),

            "SMS" to listOf(
                "android.permission.SEND_SMS",
                "android.permission.RECEIVE_SMS",
                "android.permission.READ_SMS",
                "android.permission.RECEIVE_WAP_PUSH",
                "android.permission.RECEIVE_MMS"
            ),

            "STORAGE" to listOf(
                "android.permission.READ_EXTERNAL_STORAGE",
                "android.permission.WRITE_EXTERNAL_STORAGE"),

            "NOTIFICATIONS" to listOf(
                "android.permission.POST_NOTIFICATIONS")
        )

        // Obtener todas las aplicaciones del dispositivo
        val installedApps = pm.getInstalledApplications(0)
        val appPermissions = mutableListOf<Map<String, Any>>()

        for (app in installedApps) {
            val appPermissionStatus = mutableMapOf<String, Any>()
            appPermissionStatus["appName"] = app.loadLabel(pm).toString()
            appPermissionStatus["packageName"] = app.packageName

            val groupStatuses = mutableMapOf<String, String>()

            for ((groupName, permissionList) in permissionGroupMap) {
                var isGranted = false
                var isDenied = false
                var allNotRequested = true
                var backgroundLocationGranted = false

                for (permission in permissionList) {
                    val checkStatus = pm.checkPermission(permission, app.packageName)

                    if (checkStatus == PackageManager.PERMISSION_GRANTED) {
                        isGranted = true
                        allNotRequested = false
                        if (permission == "android.permission.ACCESS_BACKGROUND_LOCATION") {
                            backgroundLocationGranted = true
                        }
                    }

                    if (checkStatus == PackageManager.PERMISSION_DENIED) {
                        if (pm.getPackageInfo(app.packageName, PackageManager.GET_PERMISSIONS).requestedPermissions?.contains(permission) == true) {
                            isDenied = true
                            allNotRequested = false
                        }
                    }
                }

                val status = when {
                    groupName == "LOCATION" && backgroundLocationGranted -> "siempre activo"
                    groupName == "LOCATION" && isGranted && !backgroundLocationGranted -> "activo en uso"
                    isGranted -> "concedido"
                    isDenied -> "denegado"
                    allNotRequested -> "no solicitado"
                    else -> "desconocido"
                }
                groupStatuses[groupName] = status
            }

            appPermissionStatus["permissionGroups"] = groupStatuses
            appPermissions.add(appPermissionStatus)
        }

        return appPermissions
    }

    // Retrieves the permission group status from all applications
    private fun getPermissionsGroupStatus(): List<Map<String, Any>> {
        val pm = packageManager
        val installedApps = pm.getInstalledApplications(0)

        val appPermissionsList = mutableListOf<Map<String, Any>>()

        for (app in installedApps) {
            val appInfo = mutableMapOf<String, Any>()
            appInfo["appName"] = app.loadLabel(pm).toString()
            appInfo["packageName"] = app.packageName

            try {
                val packageInfo = pm.getPackageInfo(app.packageName, PackageManager.GET_PERMISSIONS)
                val requestedPermissions = packageInfo.requestedPermissions ?: emptyArray()

                val permissionStatuses = mutableListOf<Map<String, Any>>()

                for (permission in requestedPermissions) {
                    val permissionInfo = mutableMapOf<String, Any>()
                    permissionInfo["permissionName"] = permission

                    val checkStatus = pm.checkPermission(permission, app.packageName)
                    if (checkStatus == PackageManager.PERMISSION_GRANTED) {
                        permissionInfo["status"] = "Concedido"
                    } else if (checkStatus == PackageManager.PERMISSION_DENIED) {
                        // Comprueba si la versión del OS es al menos Marshmallow (API level 23)
                        if (android.os.Build.VERSION.SDK_INT >= android.os.Build.VERSION_CODES.M) {
                            // Asegúrate de que this se refiere a una instancia de una Activity
                            if (shouldShowRequestPermissionRationale(permission)) {
                                permissionInfo["status"] = "Preguntar siempre"
                            } else {
                                permissionInfo["status"] = "Denegado"
                            }
                        } else {
                            // En versiones anteriores a Marshmallow, no se puede saber si "preguntar siempre"
                            permissionInfo["status"] = "Denegado"
                        }
                    } else {
                        permissionInfo["status"] = "Desconocido"
                    }

                    permissionStatuses.add(permissionInfo)
                }

                appInfo["requestedPermissions"] = permissionStatuses

            } catch (e: Exception) {
                appInfo["requestedPermissions"] = listOf("Error al obtener permisos: ${e.message}")
            }

            appPermissionsList.add(appInfo)
        }

        return appPermissionsList
    }






    @SuppressLint("HardwareIds")
    private fun retrieveDeviceID(): String {
        return Settings.Secure.getString(contentResolver, Settings.Secure.ANDROID_ID)
    }
}








