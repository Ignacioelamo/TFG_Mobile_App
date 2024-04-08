package com.example.tfg_mobile_app

import android.content.pm.PackageInfo
import android.content.pm.PackageManager
import android.content.pm.PermissionInfo
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.MethodChannel.MethodCallHandler
import io.flutter.plugins.GeneratedPluginRegistrant

class MainActivity: FlutterActivity() {


    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        val channel = "flutter_channel"
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, channel).
        setMethodCallHandler { call, result ->
            when (call.method) {
                "prueba" -> {
                    result.success(prueba())
                }
                else -> {
                    result.notImplemented()
                }
            }
        }
    }

    private fun prueba(): String {
        val cadena = "ya funciona"
        return cadena
    }




}






