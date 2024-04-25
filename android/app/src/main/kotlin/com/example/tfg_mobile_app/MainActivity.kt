package com.example.tfg_mobile_app

import android.annotation.SuppressLint
import android.content.pm.PackageManager
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
import android.content.pm.ApplicationInfo
import android.provider.Settings

class MainActivity : FlutterActivity() {

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        val channel = MethodChannel(flutterEngine.dartExecutor.binaryMessenger, "flutter_channel")

        channel.setMethodCallHandler { call, result ->
            when (call.method) {
                "getAllPermissionsGroup" -> {
                    val permissions = getAllPermissionsGroup()
                    result.success(permissions)
                }
                "getID_Device" -> {
                    val deviceId = getID_Device()
                    result.success(deviceId)
                }
                "getAllPermissions" -> {
                    val permissions = getAllPermissions()
                    result.success(permissions)
                }
                "getAllPermissionsOfTheApps" -> {
                    val permissions = getAllPermissionsOfTheApps()
                    result.success(permissions)
                }
                else -> {
                    result.notImplemented()
                }
            }
        }
    }

    fun getAllPermissionsGroup(): List<Map<String, Any>> {
        val pm = packageManager
        val permissionGroupMap = mapOf(
            "ACTIVITY_RECOFNITION" to listOf(
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
                "android.permission.CAMERA"),
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
                "android.permission.RECORD_AUDIO"),
            "NEARBY_DEVICES" to listOf(
                "android.permission.BLUETOOTH_CONNECT",
                "android.permission.BLUETOOTH_ADVERTISE",
                "android.permission.BLUETOOTH_SCAN",
                "android.permission.UWB_RANGING"
            ),
            "NOTIFICATIONS" to listOf(
                "android.permission.POST_NOTIFICATIONS"),
            "PHONE" to listOf(
                "android.permission.READ_PHONE_STATE",
                "android.permission.READ_PHONE_NUMBERS",
                "android.permission.CALL_PHONE",
                "android.permission.READ_CALL_LOG",
                "android.permission.WRITE_CALL_LOG",
                "android.permission.ADD_VOICEMAIL",
                "android.permission.USE_SIP",
                "android.permission.PROCESS_OUTGOING_CALLS"
            ),
            "READ_MEDIA_AURAL" to listOf(
                "android.permission.READ_MEDIA_AUDIO",
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
            ),




        )

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

                for (permission in permissionList) {
                    val checkStatus = pm.checkPermission(permission, app.packageName)

                    if (checkStatus == PackageManager.PERMISSION_GRANTED) {
                        isGranted = true
                        allNotRequested = false
                        break
                    }

                    if (checkStatus == PackageManager.PERMISSION_DENIED) {
                        if (pm.getPackageInfo(app.packageName, PackageManager.GET_PERMISSIONS).requestedPermissions?.contains(permission) == true) {
                            isDenied = true
                            allNotRequested = false
                        }
                    }
                }

                groupStatuses[groupName] = when {
                    isGranted -> "concedido"
                    isDenied -> "denegado"
                    allNotRequested -> "no solicitado"
                    else -> "desconocido"
                }
            }

            appPermissionStatus["permissionGroups"] = groupStatuses
            appPermissions.add(appPermissionStatus)
        }

        return appPermissions
    }


    //Funcion para obtener todos los permisos de las aplicaciones individuales
    fun getAllPermissions(): List<Map<String, Any>> {
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

        // Almacenar el estado de cada grupo de permisos para cada aplicación
        val appPermissions = mutableListOf<Map<String, Any>>()

        for (app in installedApps) {
            val appPermissionStatus = mutableMapOf<String, Any>()
            appPermissionStatus["appName"] = app.loadLabel(pm).toString()
            appPermissionStatus["packageName"] = app.packageName

            val groupStatuses = mutableMapOf<String, Map<String, String>>()

            for ((groupName, permissionList) in permissionGroupMap) {
                val statusMap = mutableMapOf<String, String>()

                for (permission in permissionList) {
                    val checkStatus = pm.checkPermission(permission, app.packageName)

                    val status = when (checkStatus) {
                        PackageManager.PERMISSION_GRANTED -> "concedido"
                        PackageManager.PERMISSION_DENIED -> {
                            if (pm.getPackageInfo(app.packageName, PackageManager.GET_PERMISSIONS).requestedPermissions?.contains(permission) == true) {
                                "denegado"
                            } else {
                                "no solicitado"
                            }
                        }
                        else -> "desconocido"
                    }

                    statusMap[permission] = status
                }

                groupStatuses[groupName] = statusMap
            }

            appPermissionStatus["permissionGroups"] = groupStatuses
            appPermissions.add(appPermissionStatus)
        }

        return appPermissions
    }

    fun getAllPermissionsOfTheApps(): List<Map<String, Any>> {
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
                    val status = when (checkStatus) {
                        PackageManager.PERMISSION_GRANTED -> "Concedido"
                        PackageManager.PERMISSION_DENIED -> "Denegado"
                        else -> "Desconocido"
                    }

                    permissionInfo["status"] = status
                    permissionStatuses.add(permissionInfo)
                }

                appInfo["requestedPermissions"] = permissionStatuses

            } catch (e: Exception) {
                appInfo["requestedPermissions"] = listOf("Error al obtener permisos")
            }

            appPermissionsList.add(appInfo)
        }

        return appPermissionsList
    }



    @SuppressLint("HardwareIds")
    fun getID_Device(): String {
        return Settings.Secure.getString(contentResolver, Settings.Secure.ANDROID_ID)
    }
}








